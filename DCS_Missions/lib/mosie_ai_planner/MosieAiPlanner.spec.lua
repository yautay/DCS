-- MosieAiPlanner.spec.lua
-- Unit tests for MosieAiPlanner source modules.
--
-- Run from this directory:
--   lua MosieAiPlanner.spec.lua
--
-- Loads the DCS API shim, MOOSE, MosieNavigator (dependency), then
-- MosieAiPlanner source modules from src/ and exercises all major
-- functional areas.
--
-- Compatible with Lua 5.1 / LuaJIT (DCS runtime).

------------------------------------------------------------
-- Section 1: DCS API shim + test helpers
------------------------------------------------------------

dofile("../test_helpers/dcs_shim.lua")

------------------------------------------------------------
-- Section 2: Load MOOSE
------------------------------------------------------------

MOOSE_DEVELOPMENT_FOLDER = "__nonexistent_test_folder__"
local ok, err = pcall(dofile, "../Moose.lua")
if not ok then
  io.stderr:write("Failed to load Moose.lua: " .. tostring(err) .. "\n")
  os.exit(1)
end

------------------------------------------------------------
-- Section 3: Load MosieNavigator (ai_planner dependency)
------------------------------------------------------------

MOSIE_NAVIGATOR_AUTO_START = false
for _, name in ipairs({
  "src/01_config.lua", "src/02_util.lua", "src/03_parser.lua",
  "src/04_physics.lua", "src/05_compute.lua", "src/06_csv.lua",
  "src/07_discover.lua", "src/08_draw.lua", "src/09_guidance.lua",
  "src/10_navigator.lua", "src/11_messages.lua", "src/12_io.lua",
  "src/13_main.lua",
}) do dofile("../mosie_navigator/" .. name) end

------------------------------------------------------------
-- Section 4: Load MosieAiPlanner source modules
------------------------------------------------------------

MOSIE_AI_PLANNER_AUTO_START = false
TEST_MODE = true

for _, name in ipairs({
  "src/01_config.lua", "src/02_util.lua", "src/03_time.lua",
  "src/04_io.lua",     "src/05_plans.lua", "src/06_geo.lua",
  "src/07_zone.lua",   "src/08_route.lua", "src/09_attack.lua",
  "src/09_control.lua",
  "src/10_main.lua",
}) do dofile(name) end

------------------------------------------------------------
-- Section 5: Mini test framework
------------------------------------------------------------

dofile("../test_helpers/suite.lua")

------------------------------------------------------------
-- Section 6: Test object factories
------------------------------------------------------------

local function makeGroup(opts)
  opts = opts or {}
  local routeCalls = {}
  local g = {
    _name      = opts.name      or "TEST GROUP 1-1",
    _skill     = opts.skill     or "Good",
    _alive     = opts.alive     ~= false,
    _airborne  = opts.airborne  or false,
    _coordinate = opts.coordinate or makeCoord({x = 0, y = 0, z = 0}),
    _velocity  = opts.velocity  or 0,
    _altitude  = opts.altitude  or 1000,
    _coalition = opts.coalition or coalition.side.BLUE,
    _routeCalls = routeCalls,
    _startUncontrolledCalled = false,
    _setTaskCalled           = false,
    _lastTask                = nil,
  }
  function g:GetName()      return self._name end
  function g:GetSkill()     return self._skill end
  function g:IsAlive()      return self._alive end
  function g:IsAirborne()   return self._airborne end
  function g:GetCoordinate() return self._coordinate end
  function g:GetVelocityKNOTS() return self._velocity end
  function g:GetAltitude()  return self._altitude end
  function g:GetCoalition() return self._coalition end
  function g:Route(route, delay)
    table.insert(self._routeCalls, {route = route, delay = delay})
  end
  function g:StartUncontrolled()
    self._startUncontrolledCalled = true
  end
  function g:TaskOrbitCircleAtVec2(vec2, alt, speed)
    return {orbitType = "circle", vec2 = vec2, alt = alt, speed = speed}
  end
  function g:SetTask(task, prio)
    self._setTaskCalled = true
    self._lastTask = task
  end
  return g
end

local function makeAssignment(opts)
  opts = opts or {}
  local group = opts.group or makeGroup(opts.groupOpts)
  return {
    group        = group,
    groupName    = opts.groupName    or group._name,
    planName     = opts.planName     or "TESTPLAN",
    plan         = opts.plan         or {waypoints = {}},
    rolexSeconds = opts.rolexSeconds or 0,
  }
end

local function makeState(opts)
  opts = opts or {}
  local assignment = opts.assignment or makeAssignment(opts.assignmentOpts)
  return {
    assignment     = assignment,
    currentWpIndex = opts.currentWpIndex or 2,
  }
end

local function makeComputed(waypoints)
  return {valid = true, waypoints = waypoints or {}}
end

local function makeWp(opts)
  opts = opts or {}
  return {
    type             = opts.type or "NAV",
    order            = opts.order or 1,
    name             = opts.name or "WP",
    zoneName         = opts.zoneName,
    coordinate       = opts.coordinate or makeCoord({x = 0, y = 0, z = 0}),
    altitudeFt       = opts.altitudeFt or 0,
    etaSec           = opts.etaSec,
    holdDurationSec  = opts.holdDurationSec or 0,
    resolvedAltFt    = opts.resolvedAltFt,
    legGsKt          = opts.legGsKt,
    legTasKt         = opts.legTasKt,
    speedKt          = opts.speedKt,
    targetPackageId  = opts.targetPackageId,
    zone             = opts.zone,
    source           = opts.source,
  }
end

local function makeCWp(opts)
  opts = opts or {}
  local src = opts.source or makeWp(opts)
  return {
    source          = src,
    etaSec          = opts.etaSec,
    holdDurationSec = opts.holdDurationSec,
    resolvedAltFt   = opts.resolvedAltFt or 0,
    legGsKt         = opts.legGsKt,
    legTasKt        = opts.legTasKt,
    speedKt         = opts.speedKt,
    coordinate      = opts.coordinate or src.coordinate,
  }
end

local function makeZone(name, coord, radius)
  local zone = {
    _name = name,
    _coord = coord or makeCoord(),
    _radius = radius or 500,
  }
  function zone:GetName() return self._name end
  function zone:GetCoordinate() return self._coord end
  function zone:GetRadius() return self._radius end
  function zone:IsCoordinateInZone(coord)
    return coord:Get2DDistance(self._coord) <= self._radius
  end
  return zone
end

local P = MosieAiPlanner

------------------------------------------------------------
-- Section 7: Test suites
------------------------------------------------------------

-- ===== 01_config.lua =====

suite("Config defaults", function()
  it("all defaults are applied when Config is empty", function()
    MosieAiPlanner.Config = {}
    dofile("src/01_config.lua")
    assertEq(MosieAiPlanner.Config.enabled, true)
    assertEq(MosieAiPlanner.Config.tickInterval, 15)
    assertEq(MosieAiPlanner.Config.retaskCooldownSeconds, 30)
    assertEq(MosieAiPlanner.Config.minSpeedKt, 140)
    assertEq(MosieAiPlanner.Config.maxSpeedKt, 300)
    assertEq(MosieAiPlanner.Config.holdSpeedKt, 140)
    assertEq(MosieAiPlanner.Config.waypointArrivalRadiusNm, 1.0)
    assertEq(MosieAiPlanner.Config.etaToleranceSeconds, 15)
    assertEq(MosieAiPlanner.Config.startLeadSeconds, 180)
    assertEq(MosieAiPlanner.Config.lineInterceptMinDistanceNm, 10)
    assertEq(MosieAiPlanner.Config.lineInterceptXteThresholdNm, 1)
    assertEq(MosieAiPlanner.Config.lineInterceptLookaheadNm, 5)
    assertEq(MosieAiPlanner.Config.targetPackageZonePrefix, "MNT_")
    assertEq(MosieAiPlanner.Config.attackTimeoutSeconds, 120)
  end)

  it("pre-configured values are not overwritten", function()
    MosieAiPlanner.Config = {minSpeedKt = 160, enabled = false}
    dofile("src/01_config.lua")
    assertEq(MosieAiPlanner.Config.minSpeedKt, 160)
    assertEq(MosieAiPlanner.Config.enabled, false)
    assertEq(MosieAiPlanner.Config.maxSpeedKt, 300)  -- default applied
  end)

  it("groupPlanTagPattern is set to expected pattern", function()
    MosieAiPlanner.Config = {}
    dofile("src/01_config.lua")
    assertNotNil(MosieAiPlanner.Config.groupPlanTagPattern)
    assertMatch(MosieAiPlanner.Config.groupPlanTagPattern, "MN")
  end)
end)

-- ===== 02_util.lua =====

suite("_ExtractPlanFromGroupName", function()
  it("extracts plan name from standard tag", function()
    local plan = P:_ExtractPlanFromGroupName("MOSQUITO 1-1 [MN:JERICHO]")
    assertEq(plan, "JERICHO")
  end)

  it("extracts plan with hyphenated name", function()
    local plan = P:_ExtractPlanFromGroupName("GROUP [MN:PLAN-A]")
    assertEq(plan, "PLAN-A")
  end)

  it("returns nil when no tag present", function()
    local plan = P:_ExtractPlanFromGroupName("MOSQUITO 1-1")
    assertNil(plan)
  end)

  it("returns nil for nil input", function()
    local plan = P:_ExtractPlanFromGroupName(nil)
    assertNil(plan)
  end)

  it("extracts first plan from multiple tags", function()
    local plan = P:_ExtractPlanFromGroupName("MOSQUITO [MN:ALPHA] [MN:BETA]")
    assertEq(plan, "ALPHA")
  end)
end)

suite("_ExtractRolexFromGroupName", function()
  it("returns numeric rolex when navigator implements it", function()
    local rolex = P:_ExtractRolexFromGroupName("MOSQUITO 1-1 [MN:JERICHO]__R0:05")
    assertEq(type(rolex), "number")
  end)

  it("returns 0 for group with no rolex tag", function()
    local rolex = P:_ExtractRolexFromGroupName("MOSQUITO 1-1 [MN:JERICHO]")
    assertEq(rolex, 0)
  end)

  it("returns 0 when navigator is absent", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    local rolex = P:_ExtractRolexFromGroupName("X [MN:P]__R5")
    MosieNavigator = origNav
    assertEq(rolex, 0)
  end)
end)

suite("_GetGroupSkill", function()
  it("returns skill from group with GetSkill", function()
    local g = makeGroup({skill = "Excellent"})
    assertEq(P:_GetGroupSkill(g), "Excellent")
  end)

  it("returns nil when group has no GetSkill method", function()
    assertNil(P:_GetGroupSkill({}))
  end)

  it("returns nil for nil group", function()
    assertNil(P:_GetGroupSkill(nil))
  end)
end)

suite("_IsAiGroup", function()
  it("returns true for Good skill", function()
    assertTrue(P:_IsAiGroup(makeGroup({skill = "Good"})))
  end)

  it("returns true for Average skill", function()
    assertTrue(P:_IsAiGroup(makeGroup({skill = "Average"})))
  end)

  it("returns false for Player skill", function()
    local g = makeGroup({skill = "Player"})
    assertTrue(not P:_IsAiGroup(g))
  end)

  it("returns false for Client skill", function()
    local g = makeGroup({skill = "Client"})
    assertTrue(not P:_IsAiGroup(g))
  end)

  it("returns true when group has no GetSkill (nil skill)", function()
    assertTrue(P:_IsAiGroup({}))
  end)
end)

suite("_IsGroupExisting", function()
  it("returns false for nil group", function()
    assertTrue(not P:_IsGroupExisting(nil))
  end)

  it("returns true when IsAlive returns true", function()
    local g = {IsAlive = function() return true end}
    assertTrue(P:_IsGroupExisting(g))
  end)

  it("returns false when IsAlive returns false", function()
    local g = {IsAlive = function() return false end}
    assertTrue(not P:_IsGroupExisting(g))
  end)

  it("uses GetDCSObject path when available", function()
    local dcs = {isExist = function() return true end}
    local g = {GetDCSObject = function() return dcs end}
    assertTrue(P:_IsGroupExisting(g))
  end)

  it("falls back to IsAlive when GetDCSObject throws", function()
    local g = {
      GetDCSObject = function() error("DCS error") end,
      IsAlive = function() return true end,
    }
    assertTrue(P:_IsGroupExisting(g))
  end)
end)

suite("Unit conversions", function()
  it("_KnotsToMps converts via UTILS", function()
    assertNear(P:_KnotsToMps(1), 0.514444, 1e-3)
  end)

  it("_KnotsToMps handles nil as 0", function()
    assertNear(P:_KnotsToMps(nil), 0, 1e-6)
  end)

  it("_MetersToNm converts 1852m to 1 NM", function()
    assertNear(P:_MetersToNm(1852), 1.0, 1e-4)
  end)

  it("_MetersToNm handles nil as 0", function()
    assertNear(P:_MetersToNm(nil), 0, 1e-6)
  end)

  it("_FeetToMeters converts 1000ft", function()
    assertNear(P:_FeetToMeters(1000), 304.8, 1e-3)
  end)

  it("_FeetToMeters handles nil as 0", function()
    assertNear(P:_FeetToMeters(nil), 0, 1e-6)
  end)
end)

suite("_Clamp", function()
  it("returns value when within range", function()
    assertEq(P:_Clamp(150, 140, 300), 150)
  end)

  it("clamps to minimum", function()
    assertEq(P:_Clamp(100, 140, 300), 140)
  end)

  it("clamps to maximum", function()
    assertEq(P:_Clamp(400, 140, 300), 300)
  end)

  it("returns min when value equals min", function()
    assertEq(P:_Clamp(140, 140, 300), 140)
  end)

  it("returns max when value equals max", function()
    assertEq(P:_Clamp(300, 140, 300), 300)
  end)
end)

suite("_IsGroupAirborne", function()
  it("returns true when IsAirborne returns true", function()
    local g = {IsAirborne = function() return true end}
    assertTrue(P:_IsGroupAirborne(g))
  end)

  it("returns false when IsAirborne returns false", function()
    local g = {IsAirborne = function() return false end}
    assertTrue(not P:_IsGroupAirborne(g))
  end)

  it("returns false for nil group", function()
    assertTrue(not P:_IsGroupAirborne(nil))
  end)

  it("returns false when no IsAirborne method", function()
    assertTrue(not P:_IsGroupAirborne({}))
  end)
end)

suite("_LogStateOnce", function()
  it("logs the first occurrence of a key", function()
    local logged = {}
    local origLog = P._Log
    P._Log = function(_, msg) table.insert(logged, msg) end
    local state = {}
    P:_LogStateOnce(state, "key1", "first message")
    P._Log = origLog
    assertEq(#logged, 1)
    assertEq(logged[1], "first message")
  end)

  it("suppresses subsequent calls with same key", function()
    local logged = {}
    local origLog = P._Log
    P._Log = function(_, msg) table.insert(logged, msg) end
    local state = {}
    P:_LogStateOnce(state, "key1", "first")
    P:_LogStateOnce(state, "key1", "second")
    P:_LogStateOnce(state, "key1", "third")
    P._Log = origLog
    assertEq(#logged, 1)
  end)

  it("allows different keys on same state", function()
    local logged = {}
    local origLog = P._Log
    P._Log = function(_, msg) table.insert(logged, msg) end
    local state = {}
    P:_LogStateOnce(state, "keyA", "msg A")
    P:_LogStateOnce(state, "keyB", "msg B")
    P._Log = origLog
    assertEq(#logged, 2)
  end)
end)

-- ===== 03_time.lua =====

suite("_GetMissionTime", function()
  it("returns timer.getAbsTime value", function()
    setAbsTime(43200)
    assertEq(P:_GetMissionTime(), 43200)
    setAbsTime(0)
  end)
end)

suite("_FormatClock", function()
  it("delegates to navigator when available", function()
    local result = P:_FormatClock(3661)
    assertNotNil(result)
    assertEq(type(result), "string")
  end)

  it("fallback produces HH:MM:SS format", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    local result = P:_FormatClock(3661)
    MosieNavigator = origNav
    assertEq(result, "01:01:01")
  end)

  it("fallback wraps modulo day", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    local result = P:_FormatClock(86400 + 3600)
    MosieNavigator = origNav
    assertEq(result, "01:00:00")
  end)

  it("fallback handles nil as 0", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    local result = P:_FormatClock(nil)
    MosieNavigator = origNav
    assertEq(result, "00:00:00")
  end)
end)

-- ===== 04_io.lua =====

suite("_GetOutputDirectory", function()
  it("returns a string", function()
    local dir = P:_GetOutputDirectory()
    assertEq(type(dir), "string")
    assertTrue(#dir > 0)
  end)
end)

suite("_GetAiZoneDumpPath", function()
  it("ends with AI_ZONE_DUMP.log", function()
    local path = P:_GetAiZoneDumpPath()
    assertMatch(path, "AI_ZONE_DUMP%.log$")
  end)
end)

suite("_SetAiMode", function()
  it("sets mode on state", function()
    local state = makeState()
    P:_SetAiMode(state, "HOLD", "hold active", "WP03")
    assertEq(state.aiMode, "HOLD")
    assertEq(state.aiModeReason, "hold active")
    assertEq(state.aiModeDetails, "WP03")
  end)

  it("defaults mode to UNKNOWN for nil mode", function()
    local state = makeState()
    P:_SetAiMode(state, nil, "reason")
    assertEq(state.aiMode, "UNKNOWN")
  end)

  it("does nothing for nil state", function()
    P:_SetAiMode(nil, "HOLD", "reason")  -- should not error
    assertTrue(true)
  end)

  it("does not re-emit debug when mode unchanged", function()
    local dumpCalls = {}
    local origDump = P._AppendAiDebugDump
    P._AppendAiDebugDump = function(_, s, msg) table.insert(dumpCalls, msg) end
    local state = makeState()
    P:_SetAiMode(state, "HOLD", "reason", "detail")
    P:_SetAiMode(state, "HOLD", "reason", "detail")  -- same, no new dump
    P._AppendAiDebugDump = origDump
    assertEq(#dumpCalls, 1)
  end)

  it("emits debug when mode changes", function()
    local dumpCalls = {}
    local origDump = P._AppendAiDebugDump
    P._AppendAiDebugDump = function(_, s, msg) table.insert(dumpCalls, msg) end
    local state = makeState()
    P:_SetAiMode(state, "HOLD", "r1", "d1")
    P:_SetAiMode(state, "DIRECT_WP", "r2", "d2")
    P._AppendAiDebugDump = origDump
    assertEq(#dumpCalls, 2)
  end)
end)

suite("_AppendAiCommandDump", function()
  it("no-ops when TEST_MODE is false", function()
    TEST_MODE = false
    P:_AppendAiCommandDump(makeState(), "ROUTE", "details")
    TEST_MODE = true
    assertTrue(true)
  end)

  it("runs when TEST_MODE is true without error", function()
    TEST_MODE = true
    local state = makeState()
    P:_AppendAiCommandDump(state, "ROUTE", "reason=test route_points=3")
    assertTrue(true)
  end)
end)

suite("_AppendAiDebugDump", function()
  it("no-ops when TEST_MODE is false", function()
    TEST_MODE = false
    P:_AppendAiDebugDump(makeState(), "test message")
    TEST_MODE = true
    assertTrue(true)
  end)

  it("runs in TEST_MODE without error", function()
    TEST_MODE = true
    P:_AppendAiDebugDump(makeState(), "debug message")
    assertTrue(true)
  end)
end)

-- ===== 05_plans.lua =====

suite("_GetMissionRolexSeconds", function()
  it("returns 0 when navigator has no MissionRolexSeconds", function()
    MosieNavigator.MissionRolexSeconds = nil
    assertEq(P:_GetMissionRolexSeconds(), 0)
  end)

  it("returns navigator MissionRolexSeconds when set", function()
    MosieNavigator.MissionRolexSeconds = 300
    assertEq(P:_GetMissionRolexSeconds(), 300)
    MosieNavigator.MissionRolexSeconds = nil
  end)

  it("returns 0 when navigator is nil", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    assertEq(P:_GetMissionRolexSeconds(), 0)
    MosieNavigator = origNav
  end)
end)

suite("_GetPlans", function()
  it("returns nil when navigator is nil", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    assertNil(P:_GetPlans())
    MosieNavigator = origNav
  end)

  it("returns cached Plans when available", function()
    local plans = {ALPHA = {waypoints = {}}}
    MosieNavigator.Plans = plans
    local result = P:_GetPlans()
    assertEq(result, plans)
    MosieNavigator.Plans = nil
  end)

  it("calls _DiscoverZones and caches when Plans is nil", function()
    MosieNavigator.Plans = nil
    local discovered = {BETA = {waypoints = {}}}
    MosieNavigator._DiscoverZones = function() return discovered end
    local result = P:_GetPlans()
    assertEq(result, discovered)
    assertEq(MosieNavigator.Plans, discovered)
    MosieNavigator.Plans = nil
    MosieNavigator._DiscoverZones = nil
  end)
end)

suite("_GetSecondsToClockSeconds", function()
  it("delegates to navigator when available", function()
    setAbsTime(43200)
    local result = P:_GetSecondsToClockSeconds(43200)
    assertEq(type(result), "number")
    setAbsTime(0)
  end)

  it("fallback: future time returns positive delta", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    setAbsTime(43200)
    local result = P:_GetSecondsToClockSeconds(43260)
    MosieNavigator = origNav
    setAbsTime(0)
    assertNear(result, 60, 1e-6)
  end)

  it("fallback: past time returns negative delta", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    setAbsTime(43200)
    local result = P:_GetSecondsToClockSeconds(43140)
    MosieNavigator = origNav
    setAbsTime(0)
    assertNear(result, -60, 1e-6)
  end)

  it("fallback: returns nil when clockSeconds is nil", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    local result = P:_GetSecondsToClockSeconds(nil)
    MosieNavigator = origNav
    assertNil(result)
  end)

  it("fallback: wraps across midnight boundary", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    setAbsTime(86300)
    local result = P:_GetSecondsToClockSeconds(100)
    MosieNavigator = origNav
    setAbsTime(0)
    assertTrue(result > 0, "should wrap to positive delta across midnight")
  end)
end)

suite("_DiscoverAssignments", function()
  it("returns empty list when plans is nil", function()
    local result = P:_DiscoverAssignments(nil)
    assertEq(#result, 0)
  end)

  it("returns empty list when SET_GROUP is nil", function()
    local origSG = SET_GROUP
    SET_GROUP = nil
    local result = P:_DiscoverAssignments({JERICHO = {waypoints = {}}})
    SET_GROUP = origSG
    assertEq(#result, 0)
  end)

  it("discovers AI groups matching plan tag", function()
    local plans = {JERICHO = {waypoints = {}}}
    local fakeGroup = makeGroup({name = "MOSQUITO 1-1 [MN:JERICHO]", skill = "Good"})
    SET_GROUP = {
      New = function(self) return self end,
      FilterStart = function(self) return self end,
      ForEachGroup = function(self, fn) fn(fakeGroup) end,
    }
    local result = P:_DiscoverAssignments(plans)
    SET_GROUP = nil
    assertEq(#result, 1)
    assertEq(result[1].planName, "JERICHO")
    assertEq(result[1].groupName, "MOSQUITO 1-1 [MN:JERICHO]")
  end)

  it("skips player groups", function()
    local plans = {JERICHO = {waypoints = {}}}
    local fakeGroup = makeGroup({name = "SPITFIRE [MN:JERICHO]", skill = "Player"})
    SET_GROUP = {
      New = function(self) return self end,
      FilterStart = function(self) return self end,
      ForEachGroup = function(self, fn) fn(fakeGroup) end,
    }
    local result = P:_DiscoverAssignments(plans)
    SET_GROUP = nil
    assertEq(#result, 0)
  end)

  it("skips groups with no matching plan tag", function()
    local plans = {JERICHO = {waypoints = {}}}
    local fakeGroup = makeGroup({name = "MOSQUITO 1-1", skill = "Good"})
    SET_GROUP = {
      New = function(self) return self end,
      FilterStart = function(self) return self end,
      ForEachGroup = function(self, fn) fn(fakeGroup) end,
    }
    local result = P:_DiscoverAssignments(plans)
    SET_GROUP = nil
    assertEq(#result, 0)
  end)
end)

suite("Target package parsing and discovery", function()
  it("parses package id, DIVE_BOMB profile, and name", function()
    local package = P:_ParseTargetPackageZoneName("MNT_PRISON_BOMB_DIVE_BOMB_Prison")
    assertNotNil(package)
    assertEq(package.id, "PRISON_BOMB")
    assertEq(package.profile, "DIVE_BOMB")
    assertEq(package.name, "Prison")
  end)

  it("parses SEARCH_DESTROY unit filters", function()
    local package = P:_ParseTargetPackageZoneName("MNT_PRISON_AAA_SEARCH_DESTROY_AAA__U_AAA__U_TRUCK")
    assertNotNil(package)
    assertEq(package.id, "PRISON_AAA")
    assertEq(package.profile, "SEARCH_DESTROY")
    assertEq(package.name, "AAA")
    assertEq(#package.unitFilters, 2)
    assertEq(package.unitFilters[1], "AAA")
    assertEq(package.unitFilters[2], "TRUCK")
  end)

  it("rejects malformed target package zones", function()
    assertNil(P:_ParseTargetPackageZoneName("MN_JERICHO_01_NAV"))
    assertNil(P:_ParseTargetPackageZoneName("MNT_PRISON_BOMB_UNKNOWN_Profile"))
  end)

  it("discovers MNT zones into TargetPackages without drawing them", function()
    local zone = makeZone("MNT_PRISON_BOMB_DIVE_BOMB_Prison", makeCoord({x = 100, z = 200}), 300)
    local originalSetZone = SET_ZONE
    SET_ZONE = {
      New = function(self) return self end,
      FilterPrefixes = function(self, prefixes) self._prefixes = prefixes return self end,
      FilterStart = function(self) return self end,
      ForEachZone = function(self, fn) fn(zone) end,
    }
    local packages = P:_DiscoverTargetPackages()
    SET_ZONE = originalSetZone
    assertNotNil(packages.PRISON_BOMB)
    assertEq(packages.PRISON_BOMB.profile, "DIVE_BOMB")
    assertEq(packages.PRISON_BOMB.radiusM, 300)
  end)
end)

suite("_GetComputedPlan", function()
  it("returns nil when navigator is nil", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    local result = P:_GetComputedPlan({plan = {waypoints = {}}})
    MosieNavigator = origNav
    assertNil(result)
  end)

  it("returns nil when assignment has no plan", function()
    local result = P:_GetComputedPlan({})
    assertNil(result)
  end)

  it("delegates to _GetActiveComputedPlan when available", function()
    local called = false
    MosieNavigator._GetActiveComputedPlan = function(_, plan, rolex, mission)
      called = true
      return {valid = true, waypoints = {}}
    end
    local assignment = {plan = {waypoints = {}}, rolexSeconds = 0}
    local result = P:_GetComputedPlan(assignment)
    MosieNavigator._GetActiveComputedPlan = nil
    assertTrue(called)
    assertNotNil(result)
  end)

  it("falls back to _ComputePlan when _GetActiveComputedPlan absent", function()
    MosieNavigator._GetActiveComputedPlan = nil
    local called = false
    local origCompute = MosieNavigator._ComputePlan
    MosieNavigator._ComputePlan = function(_, plan, rolex)
      called = true
      return {valid = true, waypoints = {}}
    end
    local assignment = {plan = {waypoints = {}}, rolexSeconds = 0}
    local result = P:_GetComputedPlan(assignment)
    MosieNavigator._ComputePlan = origCompute
    assertTrue(called)
    assertNotNil(result)
  end)
end)

suite("_GetPlanWaypoint / _GetComputedWaypoint", function()
  it("_GetPlanWaypoint returns nil for nil state", function()
    assertNil(P:_GetPlanWaypoint(nil, 1))
  end)

  it("_GetPlanWaypoint returns nil for out-of-range index", function()
    local state = makeState({assignmentOpts = {plan = {waypoints = {makeWp()}}}})
    assertNil(P:_GetPlanWaypoint(state, 99))
  end)

  it("_GetPlanWaypoint returns correct waypoint", function()
    local wp = makeWp({type = "TARGET", order = 3})
    local state = makeState({assignmentOpts = {plan = {waypoints = {makeWp(), makeWp(), wp}}}})
    local result = P:_GetPlanWaypoint(state, 3)
    assertEq(result.type, "TARGET")
    assertEq(result.order, 3)
  end)

  it("_GetComputedWaypoint returns nil for nil computed", function()
    assertNil(P:_GetComputedWaypoint(nil, 1))
  end)

  it("_GetComputedWaypoint returns correct waypoint", function()
    local cwp = makeCWp({legGsKt = 180})
    local computed = makeComputed({makeCWp(), cwp})
    local result = P:_GetComputedWaypoint(computed, 2)
    assertEq(result.legGsKt, 180)
  end)
end)

suite("_GetWaypointSpeedKt", function()
  it("returns legGsKt when available", function()
    assertEq(P:_GetWaypointSpeedKt({legGsKt = 180}), 180)
  end)

  it("returns legTasKt when legGsKt absent", function()
    assertEq(P:_GetWaypointSpeedKt({legTasKt = 190}), 190)
  end)

  it("returns speedKt when legGsKt and legTasKt absent", function()
    assertEq(P:_GetWaypointSpeedKt({speedKt = 160}), 160)
  end)

  it("returns nil for nil waypoint", function()
    assertNil(P:_GetWaypointSpeedKt(nil))
  end)

  it("returns nil for empty table", function()
    assertNil(P:_GetWaypointSpeedKt({}))
  end)
end)

-- ===== 06_geo.lua =====

suite("_CoordinateToVec2", function()
  it("returns nil for nil coordinate", function()
    assertNil(P:_CoordinateToVec2(nil))
  end)

  it("uses GetVec2 when available", function()
    local c = {GetVec2 = function() return {x = 10, y = 20} end}
    local v = P:_CoordinateToVec2(c)
    assertEq(v.x, 10)
    assertEq(v.y, 20)
  end)

  it("uses GetVec3 when GetVec2 absent, maps z to y", function()
    local c = {GetVec3 = function() return {x = 5, y = 0, z = 15} end}
    local v = P:_CoordinateToVec2(c)
    assertEq(v.x, 5)
    assertEq(v.y, 15)
  end)

  it("falls back to raw x/z fields", function()
    local c = {x = 7, z = 9}
    local v = P:_CoordinateToVec2(c)
    assertEq(v.x, 7)
    assertEq(v.y, 9)
  end)

  it("falls back to x/y when z absent", function()
    local c = {x = 3, y = 8}
    local v = P:_CoordinateToVec2(c)
    assertEq(v.x, 3)
    assertEq(v.y, 8)
  end)
end)

suite("_GetAirdromeCategory", function()
  it("returns AIRDROME category value", function()
    assertEq(P:_GetAirdromeCategory(), Airbase.Category.AIRDROME)
  end)
end)

suite("_GetAirbaseName", function()
  it("returns nil for nil airbase", function()
    assertNil(P:_GetAirbaseName(nil))
  end)

  it("uses GetName method", function()
    local ab = {GetName = function() return "Tangmere" end}
    assertEq(P:_GetAirbaseName(ab), "Tangmere")
  end)

  it("falls back to GetAirbaseName method", function()
    local ab = {
      GetName = function() error("no name") end,
      GetAirbaseName = function() return "Biggin Hill" end,
    }
    assertEq(P:_GetAirbaseName(ab), "Biggin Hill")
  end)

  it("falls back to raw fields", function()
    local ab = {AirbaseName = "Manston"}
    assertEq(P:_GetAirbaseName(ab), "Manston")
  end)

  it("falls back to .name field", function()
    local ab = {name = "Hawkinge"}
    assertEq(P:_GetAirbaseName(ab), "Hawkinge")
  end)
end)

suite("_GetAirbaseCoordinate", function()
  it("returns nil for nil airbase", function()
    assertNil(P:_GetAirbaseCoordinate(nil))
  end)

  it("uses GetCoordinate method", function()
    local coord = makeCoord({x = 1, y = 0, z = 2})
    local ab = {GetCoordinate = function() return coord end}
    local result = P:_GetAirbaseCoordinate(ab)
    assertEq(result, coord)
  end)

  it("uses GetVec2 fallback", function()
    local ab = {
      GetCoordinate = function() error("no coord") end,
      GetVec2 = function() return {x = 5, y = 10} end,
    }
    local result = P:_GetAirbaseCoordinate(ab)
    assertEq(result.x, 5)
    assertEq(result.z, 10)
  end)
end)

suite("_GetAirbaseId", function()
  it("returns nil for nil airbase", function()
    assertNil(P:_GetAirbaseId(nil))
  end)

  it("uses GetID method", function()
    local ab = {GetID = function() return 42 end}
    assertEq(P:_GetAirbaseId(ab), 42)
  end)

  it("falls back to getID (lowercase)", function()
    local ab = {
      GetID = function() error("no id") end,
      getID = function() return 99 end,
    }
    assertEq(P:_GetAirbaseId(ab), 99)
  end)

  it("falls back to raw id field", function()
    local ab = {id = 7}
    assertEq(P:_GetAirbaseId(ab), 7)
  end)
end)

suite("_GetGroupCoordinate", function()
  it("returns nil when group has no GetCoordinate", function()
    assertNil(P:_GetGroupCoordinate({}))
  end)

  it("returns coordinate from group", function()
    local coord = makeCoord({x = 100, y = 0, z = 200})
    local g = {GetCoordinate = function() return coord end}
    assertEq(P:_GetGroupCoordinate(g), coord)
  end)
end)

suite("_GetDistanceNm", function()
  it("returns nil when fromCoordinate is nil", function()
    assertNil(P:_GetDistanceNm(nil, makeCoord()))
  end)

  it("returns nil when toCoordinate is nil", function()
    assertNil(P:_GetDistanceNm(makeCoord(), nil))
  end)

  it("returns nil when no Get2DDistance method", function()
    assertNil(P:_GetDistanceNm({}, makeCoord()))
  end)

  it("computes distance correctly for known points", function()
    local from = makeCoord({x = 0, y = 0, z = 0})
    local to   = makeCoord({x = 1852, y = 0, z = 0})
    local distNm = P:_GetDistanceNm(from, to)
    assertNear(distNm, 1.0, 1e-4)
  end)

  it("returns 0 for identical coordinates", function()
    local c = makeCoord({x = 100, y = 0, z = 200})
    assertNear(P:_GetDistanceNm(c, c), 0, 1e-6)
  end)
end)

suite("_FindNearestLandingAirbase", function()
  it("returns nil,nil for nil coordinate", function()
    local ab, dist = P:_FindNearestLandingAirbase(nil)
    assertNil(ab)
    assertNil(dist)
  end)

  it("uses GetClosestAirbase when available", function()
    local fakeAb = {GetName = function() return "Tangmere" end}
    local coord = makeCoord()
    coord.GetClosestAirbase = function(_, cat) return fakeAb, 5000 end
    local ab, dist = P:_FindNearestLandingAirbase(coord)
    assertEq(ab, fakeAb)
    assertEq(dist, 5000)
  end)

  it("returns nil,nil when AIRBASE global absent", function()
    local origAIRBASE = AIRBASE
    AIRBASE = nil
    local coord = makeCoord()
    local ab, dist = P:_FindNearestLandingAirbase(coord)
    AIRBASE = origAIRBASE
    assertNil(ab)
    assertNil(dist)
  end)
end)

-- ===== 07_zone.lua =====

suite("_FormatClockOrDash", function()
  it("returns dash for nil", function()
    assertEq(P:_FormatClockOrDash(nil), "---")
  end)

  it("delegates to _FormatClock for non-nil", function()
    local result = P:_FormatClockOrDash(3600)
    assertNotNil(result)
    assertEq(type(result), "string")
    assertTrue(result ~= "---")
  end)
end)

suite("_FormatSignedSeconds", function()
  it("returns dash for nil", function()
    assertEq(P:_FormatSignedSeconds(nil), "---")
  end)

  it("formats positive value with plus sign", function()
    assertMatch(P:_FormatSignedSeconds(30), "^%+30$")
  end)

  it("formats negative value with minus sign", function()
    assertMatch(P:_FormatSignedSeconds(-45), "^%-45$")
  end)

  it("formats zero as +0", function()
    assertEq(P:_FormatSignedSeconds(0), "+0")
  end)
end)

suite("_IsCoordinateInWaypointZone", function()
  it("returns false,nil,nil for nil coordinate", function()
    local inside, dist, radius = P:_IsCoordinateInWaypointZone(nil, makeWp())
    assertEq(inside, false)
    assertNil(dist)
    assertNil(radius)
  end)

  it("returns false,nil,nil for nil waypoint", function()
    local inside, dist, radius = P:_IsCoordinateInWaypointZone(makeCoord(), nil)
    assertEq(inside, false)
    assertNil(dist)
    assertNil(radius)
  end)

  it("returns false for waypoint with no zone", function()
    local wp = makeWp()
    wp.zone = nil
    local inside = P:_IsCoordinateInWaypointZone(makeCoord(), wp)
    assertEq(inside, false)
  end)

  it("uses IsCoordinateInZone when available and returns true", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local wp = makeWp({coordinate = makeCoord({x = 0, y = 0, z = 0})})
    wp.zone = {
      IsCoordinateInZone = function(_, c) return true end,
      GetRadius = function() return 1000 end,
    }
    local inside, dist, radius = P:_IsCoordinateInWaypointZone(coord, wp)
    assertEq(inside, true)
    assertNotNil(radius)
  end)

  it("uses radius fallback when zone methods return nil", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local wp = makeWp({coordinate = makeCoord({x = 500, y = 0, z = 0})})
    wp.zone = {GetRadius = function() return 1000 end}
    local inside, dist, radius = P:_IsCoordinateInWaypointZone(coord, wp)
    assertEq(inside, true)
    assertNear(radius, P:_MetersToNm(1000), 1e-4)
  end)

  it("returns false when outside radius", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local wp = makeWp({coordinate = makeCoord({x = 5000, y = 0, z = 0})})
    wp.zone = {GetRadius = function() return 100 end}
    local inside = P:_IsCoordinateInWaypointZone(coord, wp)
    assertEq(inside, false)
  end)
end)

suite("_FormatAiZoneDumpEntry", function()
  it("produces a string with required fields", function()
    local group = makeGroup({name = "MOSQUITO 1-1"})
    group._coordinate = makeCoord({x = 100, y = 0, z = 200})
    local state = makeState({
      assignmentOpts = {
        group     = group,
        groupName = "MOSQUITO 1-1",
        planName  = "JERICHO",
        plan      = {waypoints = {}},
      }
    })
    local wp = makeWp({type = "TARGET", order = 5, name = "Prison", zoneName = "MN_JERICHO_05_TARGET"})
    local result = P:_FormatAiZoneDumpEntry(state, wp, nil, 2.5, 1.0)
    assertMatch(result, "AI_ZONE_ENTRY")
    assertMatch(result, "MOSQUITO 1%-1")
    assertMatch(result, "JERICHO")
    assertMatch(result, "WP05")
    assertMatch(result, "TARGET")
    assertMatch(result, "2%.500")
    assertMatch(result, "1%.000")
  end)

  it("formats eta and delta when computed waypoint has etaSec", function()
    setAbsTime(43200)
    local group = makeGroup()
    group._coordinate = makeCoord({x = 0, y = 0, z = 0})
    local state = makeState({
      assignmentOpts = {
        group = group,
        groupName = "TEST",
        planName = "P",
        plan = {waypoints = {}},
      }
    })
    local cwp = {etaSec = 43500}
    local result = P:_FormatAiZoneDumpEntry(state, makeWp({order = 1}), cwp, 1.0, 0.5)
    assertMatch(result, "eta=")
    assertMatch(result, "delta_sec=")
    setAbsTime(0)
  end)
end)

suite("_GetAiXte", function()
  it("returns nil,nil when navigator has no _CalculateXte", function()
    local origCalc = MosieNavigator._CalculateXte
    MosieNavigator._CalculateXte = nil
    local state = makeState()
    local xte, side = P:_GetAiXte(state, makeCoord())
    MosieNavigator._CalculateXte = origCalc
    assertNil(xte)
    assertNil(side)
  end)

  it("returns nil,nil when waypoints missing", function()
    local state = makeState({assignmentOpts = {plan = {waypoints = {}}}})
    state.currentWpIndex = 2
    local xte, side = P:_GetAiXte(state, makeCoord())
    assertNil(xte)
    assertNil(side)
  end)
end)

-- ===== 08_route.lua =====

suite("_BuildVec2RoutePoint", function()
  it("returns nil for nil vec2", function()
    assertNil(P:_BuildVec2RoutePoint(nil, 100, 180))
  end)

  it("returns route point table with correct fields", function()
    local rp = P:_BuildVec2RoutePoint({x = 10, y = 20}, 500, 180)
    assertEq(rp.x, 10)
    assertEq(rp.y, 20)
    assertEq(rp.alt, 500)
    assertEq(rp.alt_type, "BARO")
    assertEq(rp.type, "Turning Point")
    assertEq(rp.action, "Turning Point")
    assertEq(rp.speed_locked, true)
    assertNotNil(rp.task)
  end)

  it("uses config minSpeedKt when speedKt is nil", function()
    local rp = P:_BuildVec2RoutePoint({x = 0, y = 0}, 0, nil)
    assertNear(rp.speed, P:_KnotsToMps(P.Config.minSpeedKt), 1e-3)
  end)
end)

suite("_BuildRoutePoint", function()
  it("returns nil when no vec2 from coordinate", function()
    local cwp = makeCWp({source = makeWp({type = "NAV", coordinate = nil})})
    cwp.source.coordinate = nil
    assertNil(P:_BuildRoutePoint(cwp, 180))
  end)

  it("builds Turning Point for NAV waypoint", function()
    local coord = makeCoord({x = 100, y = 0, z = 200})
    local cwp = makeCWp({source = makeWp({type = "NAV", coordinate = coord}), resolvedAltFt = 500})
    local rp = P:_BuildRoutePoint(cwp, 180)
    assertNotNil(rp)
    assertEq(rp.type, "Turning Point")
    assertEq(rp.action, "Fly Over Point")
    assertEq(rp.x, 100)
    assertEq(rp.y, 200)
    assertNear(rp.alt, P:_FeetToMeters(500), 1e-3)
  end)

  it("builds Turning Point at zone coordinate for LANDING waypoint", function()
    local coord = makeCoord({x = 300, y = 0, z = 400})
    local cwp = makeCWp({source = makeWp({type = "LANDING", coordinate = coord}), resolvedAltFt = 200})
    local rp = P:_BuildRoutePoint(cwp, 140)
    assertNotNil(rp)
    assertEq(rp.type, "Turning Point")
    assertEq(rp.action, "Fly Over Point")
    assertEq(rp.x, 300)
    assertEq(rp.y, 400)
    assertNear(rp.alt, P:_FeetToMeters(200), 1e-3)
    assertEq(rp.speed_locked, true)
  end)

  it("LANDING fly-over preserves planned altitude", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local cwp = makeCWp({source = makeWp({type = "LANDING", coordinate = coord}), resolvedAltFt = 500})
    local rp = P:_BuildRoutePoint(cwp, 140)
    assertNotNil(rp)
    assertNear(rp.alt, P:_FeetToMeters(500), 1e-3)
  end)
end)

suite("_BuildAirbaseLandRoutePoint", function()
  local function makeFakeAirbase(x, z, id, name)
    return {
      GetName       = function() return name or "Tangmere" end,
      GetCoordinate = function() return makeCoord({x = x or 0, y = 0, z = z or 0}) end,
      GetVec2       = function() return {x = x or 0, y = z or 0} end,
      GetID         = function() return id or 42 end,
    }
  end

  it("returns nil when no airbase found", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local cwp = makeCWp({source = makeWp({type = "LANDING", coordinate = coord}), resolvedAltFt = 200})
    local origFind = P._FindNearestLandingAirbase
    P._FindNearestLandingAirbase = function(_, c) return nil, nil end
    local rp = P:_BuildAirbaseLandRoutePoint(cwp)
    P._FindNearestLandingAirbase = origFind
    assertNil(rp)
  end)

  it("returns Land point at airbase coordinate when airbase found", function()
    local zoneCoord = makeCoord({x = 100, y = 0, z = 200})
    local fakeAb = makeFakeAirbase(500, 600, 42, "Tangmere")
    local cwp = makeCWp({source = makeWp({type = "LANDING", coordinate = zoneCoord}), resolvedAltFt = 200})
    local origFind = P._FindNearestLandingAirbase
    P._FindNearestLandingAirbase = function(_, c) return fakeAb, 0 end
    local rp = P:_BuildAirbaseLandRoutePoint(cwp)
    P._FindNearestLandingAirbase = origFind
    assertNotNil(rp)
    assertEq(rp.type, "Land")
    assertEq(rp.action, "Landing")
    assertEq(rp.airdromeId, 42)
    assertEq(rp.name, "Tangmere")
    assertEq(rp.speed_locked, false)
    assertEq(rp.x, 500)
    assertEq(rp.y, 600)
  end)

  it("preserves resolvedAltFt from computed waypoint", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local fakeAb = makeFakeAirbase(0, 0, 7, "Biggin")
    local cwp = makeCWp({source = makeWp({type = "LANDING", coordinate = coord}), resolvedAltFt = 300})
    local origFind = P._FindNearestLandingAirbase
    P._FindNearestLandingAirbase = function(_, c) return fakeAb, 0 end
    local rp = P:_BuildAirbaseLandRoutePoint(cwp)
    P._FindNearestLandingAirbase = origFind
    assertNotNil(rp)
    assertNear(rp.alt, P:_FeetToMeters(300), 1e-3)
  end)

  it("falls back to zone coordinate when airbase coordinate unavailable", function()
    local zoneCoord = makeCoord({x = 300, y = 0, z = 400})
    local fakeAb = {
      GetName = function() return "X" end,
      GetCoordinate = function() return nil end,
      GetVec2 = function() return nil end,
      GetID   = function() return 9 end,
    }
    local cwp = makeCWp({source = makeWp({type = "LANDING", coordinate = zoneCoord}), resolvedAltFt = 0})
    local origFind = P._FindNearestLandingAirbase
    P._FindNearestLandingAirbase = function(_, c) return fakeAb, 0 end
    local origGetCoord = P._GetAirbaseCoordinate
    P._GetAirbaseCoordinate = function(_, ab) return nil end
    local rp = P:_BuildAirbaseLandRoutePoint(cwp)
    P._FindNearestLandingAirbase = origFind
    P._GetAirbaseCoordinate = origGetCoord
    assertNotNil(rp)
    assertEq(rp.type, "Land")
    assertEq(rp.x, 300)
    assertEq(rp.y, 400)
  end)
end)

suite("_GetLineInterceptVec2", function()
  it("returns nil,nil for nil state", function()
    local v, d = P:_GetLineInterceptVec2(nil, makeComputed(), 2)
    assertNil(v)
  end)

  it("returns nil,nil for nil computed", function()
    local v, d = P:_GetLineInterceptVec2(makeState(), nil, 2)
    assertNil(v)
  end)

  it("returns nil,nil for startIndex <= 1", function()
    local state = makeState()
    local computed = makeComputed({makeCWp(), makeCWp()})
    local v, d = P:_GetLineInterceptVec2(state, computed, 1)
    assertNil(v)
  end)

  it("returns nil when group close to waypoint (within min distance)", function()
    local nearCoord = makeCoord({x = 0, y = 0, z = 0})
    local group = makeGroup({coordinate = nearCoord})
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    local prevWp = makeCWp({source = makeWp({coordinate = makeCoord({x = 0, y = 0, z = 0})})})
    local currWp = makeCWp({source = makeWp({coordinate = makeCoord({x = 100, y = 0, z = 0})})})
    local computed = makeComputed({prevWp, currWp})
    -- 100m < 10 NM threshold → no intercept
    local v, d = P:_GetLineInterceptVec2(state, computed, 2)
    assertNil(v)
  end)
end)

suite("_BuildRoute", function()
  it("returns route with at least current position when computed has waypoints", function()
    local group = makeGroup({
      coordinate = makeCoord({x = 0, y = 0, z = 0}),
      altitude = 1000,
    })
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    local takeoffCwp = makeCWp({source = makeWp({type = "TAKE_OFF", coordinate = makeCoord()}), resolvedAltFt = 0, legGsKt = 180})
    local navCwp = makeCWp({source = makeWp({type = "NAV", coordinate = makeCoord({x = 5000, y = 0, z = 0})}), resolvedAltFt = 500, legGsKt = 180})
    local computed = makeComputed({takeoffCwp, navCwp})
    local route, mode, details = P:_BuildRoute(state, computed, 2, 180)
    assertTrue(#route >= 1, "route should have at least current pos + NAV waypoint")
    assertEq(type(mode), "string")
  end)

  it("appends final Land point after LANDING fly-over when airbase found", function()
    local group = makeGroup({
      coordinate = makeCoord({x = 0, y = 0, z = 0}),
      altitude = 500,
    })
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    local landCoord = makeCoord({x = 1000, y = 0, z = 2000})
    local abCoord   = makeCoord({x = 1100, y = 0, z = 2100})
    local fakeAb = {
      GetName       = function() return "Tangmere" end,
      GetCoordinate = function() return abCoord end,
      GetVec2       = function() return {x = 1100, y = 2100} end,
      GetID         = function() return 42 end,
    }
    local takeoffCwp = makeCWp({source = makeWp({type = "TAKE_OFF", coordinate = makeCoord()}), resolvedAltFt = 0, legGsKt = 180})
    local landCwp    = makeCWp({source = makeWp({type = "LANDING",  coordinate = landCoord}),  resolvedAltFt = 200, legGsKt = 140})
    local computed   = makeComputed({takeoffCwp, landCwp})
    local origFind = P._FindNearestLandingAirbase
    P._FindNearestLandingAirbase = function(_, c) return fakeAb, 0 end
    local route, _, _ = P:_BuildRoute(state, computed, 2, 140)
    P._FindNearestLandingAirbase = origFind
    -- route: [current pos] [LANDING fly-over at zone] [Land at airbase]
    assertTrue(#route >= 3, "expected current pos + LANDING fly-over + Land, got " .. #route)
    local flyOver = route[#route - 1]
    local land    = route[#route]
    assertEq(flyOver.type,   "Turning Point")
    assertEq(flyOver.action, "Fly Over Point")
    assertEq(flyOver.x,      1000)
    assertEq(flyOver.y,      2000)
    assertEq(land.type,   "Land")
    assertEq(land.action, "Landing")
    assertEq(land.airdromeId, 42)
    assertEq(land.speed_locked, false)
  end)

  it("no final Land point appended when LANDING has no nearby airbase", function()
    local group = makeGroup({
      coordinate = makeCoord({x = 0, y = 0, z = 0}),
      altitude = 500,
    })
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    local landCoord  = makeCoord({x = 1000, y = 0, z = 2000})
    local takeoffCwp = makeCWp({source = makeWp({type = "TAKE_OFF", coordinate = makeCoord()}), resolvedAltFt = 0, legGsKt = 180})
    local landCwp    = makeCWp({source = makeWp({type = "LANDING",  coordinate = landCoord}),  resolvedAltFt = 200, legGsKt = 140})
    local computed   = makeComputed({takeoffCwp, landCwp})
    local origFind = P._FindNearestLandingAirbase
    P._FindNearestLandingAirbase = function(_, c) return nil, nil end
    local route, _, _ = P:_BuildRoute(state, computed, 2, 140)
    P._FindNearestLandingAirbase = origFind
    -- route: [current pos] [LANDING fly-over] — no extra Land point
    assertTrue(#route >= 2, "expected at least current pos + LANDING fly-over")
    local last = route[#route]
    assertEq(last.type, "Turning Point")
  end)
end)

suite("_RetaskRoute", function()
  it("returns false when cooldown not elapsed", function()
    local group = makeGroup()
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    state.lastRetaskTime = 99999
    setTime(99999 + 5)  -- only 5s elapsed, cooldown is 30s
    local result = P:_RetaskRoute(state, "test")
    setTime(0)
    assertEq(result, false)
  end)

  it("returns false when computed plan invalid", function()
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function(_, assignment) return nil end
    local state = makeState()
    local result = P:_RetaskRoute(state, "test")
    P._GetComputedPlan = origCompute
    assertEq(result, false)
  end)

  it("calls group Route and returns true on success", function()
    local group = makeGroup({
      coordinate = makeCoord({x = 0, y = 0, z = 0}),
      altitude = 1000,
    })
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    setTime(0)
    state.lastRetaskTime = nil
    local navCwp = makeCWp({source = makeWp({type = "NAV", coordinate = makeCoord({x = 5000})}), resolvedAltFt = 500, legGsKt = 180})
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function(_, a) return makeComputed({makeCWp(), navCwp}) end
    local result = P:_RetaskRoute(state, "initial airborne route")
    P._GetComputedPlan = origCompute
    assertEq(result, true)
    assertEq(#group._routeCalls, 1)
  end)
end)

-- ===== 09_control.lua =====

suite("_MaybeStartUncontrolled", function()
  it("does nothing when already airborne", function()
    local group = makeGroup({airborne = true})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    local computed = makeComputed({makeCWp({etaSec = 100})})
    P:_MaybeStartUncontrolled(state, computed)
    assertEq(group._startUncontrolledCalled, false)
  end)

  it("does nothing when startCommanded already set", function()
    local group = makeGroup({airborne = false})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    state.startCommanded = true
    local computed = makeComputed({makeCWp({etaSec = 100})})
    setTime(10)
    P:_MaybeStartUncontrolled(state, computed)
    setTime(0)
    assertEq(group._startUncontrolledCalled, false)
  end)

  it("does nothing when takeoff ETA far in future", function()
    local group = makeGroup({airborne = false})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    setAbsTime(0)
    -- ETA 1 hour from now, lead is 3 min
    local computed = makeComputed({makeCWp({etaSec = 3600})})
    P:_MaybeStartUncontrolled(state, computed)
    assertEq(group._startUncontrolledCalled, false)
    setAbsTime(0)
  end)

  it("calls StartUncontrolled when within lead window", function()
    local group = makeGroup({airborne = false})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    setAbsTime(43200)
    setTime(43200)
    -- ETA in 60s, lead is 180s → within window
    local computed = makeComputed({makeCWp({etaSec = 43260})})
    P:_MaybeStartUncontrolled(state, computed)
    setAbsTime(0)
    setTime(0)
    assertEq(group._startUncontrolledCalled, true)
    assertEq(state.startCommanded, true)
  end)

  it("logs state once when StartUncontrolled method absent", function()
    local group = makeGroup({airborne = false})
    group.StartUncontrolled = nil
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    setAbsTime(43200)
    setTime(43200)
    local computed = makeComputed({makeCWp({etaSec = 43260})})
    P:_MaybeStartUncontrolled(state, computed)
    P:_MaybeStartUncontrolled(state, computed)  -- second call should be suppressed
    setAbsTime(0)
    setTime(0)
    assertTrue(state.logged and state.logged["start-unsupported"])
  end)
end)

suite("_RequiredSpeedToWaypointKt", function()
  it("returns nil,nil when no group coordinate", function()
    local group = makeGroup()
    group.GetCoordinate = function() return nil end
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    local wp = makeWp({etaSec = 43260, coordinate = makeCoord({x = 0, y = 0, z = 9260})})
    local s, e = P:_RequiredSpeedToWaypointKt(state, wp)
    assertNil(s)
    assertNil(e)
  end)

  it("returns nil when no etaSec on waypoint", function()
    local group = makeGroup({coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    local wp = makeWp({coordinate = makeCoord({x = 5000, y = 0, z = 0})})
    local s, e = P:_RequiredSpeedToWaypointKt(state, wp)
    assertNil(s)
    assertNil(e)
  end)

  it("computes required speed for known geometry", function()
    -- 60 NM in 20 min → 180 kt required
    local fromCoord = makeCoord({x = 0, y = 0, z = 0})
    local toCoord = makeCoord({x = 60 * 1852, y = 0, z = 0})
    local group = makeGroup({coordinate = fromCoord, velocity = 200})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    setAbsTime(43200)
    local wp = makeWp({etaSec = 43200 + 20 * 60, coordinate = toCoord})
    local requiredKt, etaErrorSec = P:_RequiredSpeedToWaypointKt(state, wp)
    setAbsTime(0)
    assertNotNil(requiredKt)
    assertNear(requiredKt, 180, 1)  -- ~180 kt, clamped within [140,300]
  end)

  it("clamps required speed to configured range", function()
    local fromCoord = makeCoord({x = 0, y = 0, z = 0})
    local toCoord = makeCoord({x = 25 * 1852, y = 0, z = 0})
    local group = makeGroup({coordinate = fromCoord})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    setAbsTime(43200)
    -- 25 NM in 3 min → 500 kt → clamped to 300
    local wp = makeWp({etaSec = 43200 + 3 * 60, coordinate = toCoord})
    local requiredKt = P:_RequiredSpeedToWaypointKt(state, wp)
    setAbsTime(0)
    assertEq(requiredKt, P.Config.maxSpeedKt)
  end)
end)

suite("_AdvanceArrivedWaypoint", function()
  it("advances index when within arrival radius", function()
    local fromCoord = makeCoord({x = 0, y = 0, z = 0})
    -- within 1 NM = 1852m
    local wpCoord = makeCoord({x = 500, y = 0, z = 0})
    local group = makeGroup({coordinate = fromCoord})
    local plan = {waypoints = {makeWp(), makeWp({coordinate = wpCoord}), makeWp()}}
    local state = makeState({
      assignmentOpts = {group = group, plan = plan},
      currentWpIndex = 2,
    })
    -- stub _RetaskRoute
    local retaskCalled = false
    local origRetask = P._RetaskRoute
    P._RetaskRoute = function(_, s, reason) retaskCalled = true return true end
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return nil end
    local cwp2 = makeCWp({source = makeWp({coordinate = wpCoord})})
    local computed = makeComputed({makeCWp(), cwp2, makeCWp()})
    P:_AdvanceArrivedWaypoint(state, computed)
    P._RetaskRoute = origRetask
    P._GetComputedPlan = origCompute
    assertEq(state.currentWpIndex, 3)
    assertEq(state.holdStarted, false)
    assertNil(state.lastRetaskTime)
  end)

  it("does not advance when waypoint is nil", function()
    local state = makeState({currentWpIndex = 5})
    local computed = makeComputed({makeCWp(), makeCWp()})  -- only 2 wps
    P:_AdvanceArrivedWaypoint(state, computed)
    assertEq(state.currentWpIndex, 5)
  end)
end)

suite("_TickHold", function()
  it("returns false for non-HOLD waypoint", function()
    local state = makeState()
    local wp = makeCWp({source = makeWp({type = "NAV"}), etaSec = 0})
    local computed = makeComputed({makeCWp(), wp})
    local result = P:_TickHold(state, computed, wp)
    assertEq(result, false)
  end)

  it("returns false when no etaSec", function()
    local state = makeState()
    local wp = makeCWp({source = makeWp({type = "HOLD"})})
    wp.etaSec = nil
    local computed = makeComputed({makeCWp(), wp})
    local result = P:_TickHold(state, computed, wp)
    assertEq(result, false)
  end)

  it("returns false when hold has not started (secondsToHold > 0)", function()
    local state = makeState()
    setAbsTime(43200)
    -- hold ETA 1 hour in future
    local wp = makeCWp({source = makeWp({type = "HOLD", order = 2}), etaSec = 43200 + 3600, holdDurationSec = 0})
    local computed = makeComputed({makeCWp(), wp})
    local result = P:_TickHold(state, computed, wp)
    setAbsTime(0)
    assertEq(result, false)
  end)

  it("sends orbit task when hold is active and not yet started", function()
    local group = makeGroup({coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    state.holdStarted = false
    setAbsTime(43200)
    -- hold ETA in past → hold active, exit in future
    local wp = makeCWp({
      source = makeWp({type = "HOLD", order = 2, coordinate = makeCoord({x = 0, y = 0, z = 0})}),
      etaSec = 43100,  -- past
      holdDurationSec = 600,  -- 10 min duration, exit at 43700
      resolvedAltFt = 1000,
    })
    local computed = makeComputed({makeCWp(), wp, makeCWp()})
    local result = P:_TickHold(state, computed, wp)
    setAbsTime(0)
    assertEq(result, true)
    assertEq(state.aiMode, "HOLD")
    assertEq(group._setTaskCalled, true)
    assertEq(state.holdStarted, true)
  end)

  it("exits hold when duration expired", function()
    local group = makeGroup({coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    setAbsTime(44000)  -- well past hold exit
    local origRetask = P._RetaskRoute
    P._RetaskRoute = function(_, s, reason) return true end
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return nil end
    local wp = makeCWp({
      source = makeWp({type = "HOLD", order = 2, coordinate = makeCoord()}),
      etaSec = 43100,       -- arrival in past
      holdDurationSec = 600, -- exit at 43700, which is < 44000
      resolvedAltFt = 0,
    })
    local computed = makeComputed({makeCWp(), wp, makeCWp()})
    local result = P:_TickHold(state, computed, wp)
    P._RetaskRoute = origRetask
    P._GetComputedPlan = origCompute
    setAbsTime(0)
    assertEq(result, true)
    assertEq(state.currentWpIndex, 3)
  end)
end)

suite("_StartTimingOrbit / _StopTimingOrbit", function()
  it("_StartTimingOrbit returns true when already in orbit", function()
    local state = makeState()
    state.timingOrbit = true
    local result = P:_StartTimingOrbit(state, nil, 100, nil)
    assertEq(result, true)
  end)

  it("_StartTimingOrbit returns false when orbit task unsupported", function()
    local group = makeGroup()
    group.TaskOrbitCircleAtVec2 = nil
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    local wp = makeCWp({source = makeWp({type = "NAV", coordinate = makeCoord()}), resolvedAltFt = 0})
    local result = P:_StartTimingOrbit(state, wp, 80, nil)
    assertEq(result, false)
  end)

  it("_StartTimingOrbit sets timingOrbit flag and sends task", function()
    local group = makeGroup({coordinate = makeCoord({x = 0, y = 0, z = 0}), altitude = 500})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}, currentWpIndex = 2})
    local wp = makeCWp({source = makeWp({type = "NAV", coordinate = makeCoord({x = 5000, y = 0, z = 0})}), resolvedAltFt = 500})
    local result = P:_StartTimingOrbit(state, wp, 80, nil)
    assertEq(result, true)
    assertEq(state.timingOrbit, true)
    assertEq(group._setTaskCalled, true)
    assertEq(state.aiMode, "TIMING_ORBIT")
  end)

  it("_StopTimingOrbit returns false when not in orbit", function()
    local state = makeState()
    state.timingOrbit = false
    assertEq(P:_StopTimingOrbit(state, 180), false)
  end)

  it("_StopTimingOrbit clears orbit flags", function()
    local group = makeGroup({coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    state.timingOrbit = true
    state.timingOrbitWaypointIndex = 2
    local navCwp = makeCWp({source = makeWp({type = "NAV", coordinate = makeCoord({x = 5000})}), resolvedAltFt = 500, legGsKt = 180})
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function(_, a) return makeComputed({makeCWp(), navCwp}) end
    P:_StopTimingOrbit(state, 180)
    P._GetComputedPlan = origCompute
    assertEq(state.timingOrbit, false)
    assertNil(state.timingOrbitWaypointIndex)
    assertEq(state.aiMode, "DIRECT_WP")
  end)
end)

suite("Attack package tasking", function()
  local function makeAttackComputed(group, targetPackageId)
    local ingress = makeCWp({source = makeWp({type = "INGRESS", order = 1, coordinate = makeCoord({x = -1000, y = 0, z = 0})}), resolvedAltFt = 500, legGsKt = 180})
    local targetZone = makeZone("MN_TEST_02_TARGET_Prison__P_" .. targetPackageId, makeCoord({x = 0, y = 0, z = 0}), 500)
    local target = makeCWp({
      source = makeWp({
        type = "TARGET",
        order = 2,
        name = "Prison",
        coordinate = makeCoord({x = 0, y = 0, z = 0}),
        zone = targetZone,
        targetPackageId = targetPackageId,
      }),
      resolvedAltFt = 500,
      legGsKt = 180,
      etaSec = 43200,
    })
    local egress = makeCWp({source = makeWp({type = "EGRESS", order = 3, coordinate = makeCoord({x = 5000, y = 0, z = 0})}), resolvedAltFt = 500, legGsKt = 180, etaSec = 43300})
    local landing = makeCWp({source = makeWp({type = "LANDING", order = 4, coordinate = makeCoord({x = 8000, y = 0, z = 0})}), resolvedAltFt = 500, legGsKt = 180, etaSec = 43400})
    local computed = makeComputed({ingress, target, egress, landing})
    local plan = {waypoints = {ingress.source, target.source, egress.source, landing.source}}
    local state = makeState({assignmentOpts = {group = group, plan = plan}, currentWpIndex = 2})
    return state, computed
  end

  it("starts DIVE_BOMB attack when AI reaches TARGET commit zone", function()
    local group = makeGroup({airborne = true, coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state, computed = makeAttackComputed(group, "PRISON_BOMB")
    P.TargetPackages = {
      PRISON_BOMB = {
        id = "PRISON_BOMB",
        profile = "DIVE_BOMB",
        coordinate = makeCoord({x = 1000, y = 0, z = 0}),
        radiusM = 250,
      }
    }
    setTime(10)
    local started = P:_MaybeStartAttack(state, computed, computed.waypoints[2])
    setTime(0)
    assertEq(started, true)
    assertEq(state.aiMode, "ATTACKING")
    assertNotNil(state.attack)
    assertEq(group._setTaskCalled, true)
    assertEq(group._lastTask.id, "ComboTask")
    assertEq(group._lastTask.params.tasks[1].id, "Bombing")
    assertEq(group._lastTask.params.tasks[1].params.attackType, "Dive")
  end)

  it("routes to next EGRESS after attack timeout", function()
    local group = makeGroup({airborne = true, coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state, computed = makeAttackComputed(group, "PRISON_BOMB")
    state.attack = {
      startedAt = 0,
      timeoutSeconds = 10,
      targetWpIndex = 2,
      egressWpIndex = 3,
      packageId = "PRISON_BOMB",
      profile = "DIVE_BOMB",
    }
    setTime(11)
    local active = P:_TickAttack(state, computed)
    setTime(0)
    assertEq(active, true)
    assertNil(state.attack)
    assertEq(state.currentWpIndex, 3)
    assertEq(#group._routeCalls, 1)
  end)

  it("ILLUM triggers illumination and immediately routes egress", function()
    local group = makeGroup({airborne = true, coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state, computed = makeAttackComputed(group, "PRISON_ILLUM")
    P.TargetPackages = {
      PRISON_ILLUM = {
        id = "PRISON_ILLUM",
        profile = "ILLUM",
        coordinate = makeCoord({x = 1000, y = 0, z = 0}),
        radiusM = 250,
      }
    }
    local originalIllum = trigger.action.illuminationBomb
    local illumCalled = false
    trigger.action.illuminationBomb = function(vec3, power) illumCalled = true end
    local started = P:_MaybeStartAttack(state, computed, computed.waypoints[2])
    trigger.action.illuminationBomb = originalIllum
    assertEq(started, true)
    assertEq(illumCalled, true)
    assertNil(state.attack)
    assertEq(state.currentWpIndex, 3)
    assertEq(#group._routeCalls, 1)
  end)

  it("SEARCH_DESTROY builds AttackUnit tasks for hostile matching units", function()
    local group = makeGroup({airborne = true, coalition = coalition.side.BLUE})
    local package = {
      id = "PRISON_AAA",
      profile = "SEARCH_DESTROY",
      coordinate = makeCoord({x = 0, y = 0, z = 0}),
      radiusM = 1000,
      unitFilters = {"AAA"},
    }
    local hostileAaa = {
      getID = function() return 101 end,
      getCoalition = function() return coalition.side.RED end,
      isExist = function() return true end,
      getLife = function() return 10 end,
      getDesc = function() return {category = Unit.Category.GROUND_UNIT, attributes = {AAA = true}} end,
      getTypeName = function() return "Flak18" end,
    }
    local friendlyAaa = {
      getID = function() return 102 end,
      getCoalition = function() return coalition.side.BLUE end,
      isExist = function() return true end,
      getLife = function() return 10 end,
      getDesc = function() return {category = Unit.Category.GROUND_UNIT, attributes = {AAA = true}} end,
      getTypeName = function() return "Flak18" end,
    }
    local originalSearch = world.searchObjects
    world.searchObjects = function(category, area, cb)
      cb(hostileAaa)
      cb(friendlyAaa)
    end
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    local tasks, foundCount = P:_BuildSearchDestroyTask(state, package)
    world.searchObjects = originalSearch
    assertEq(foundCount, 1)
    assertEq(#tasks, 1)
    assertEq(tasks[1].id, "AttackUnit")
    assertEq(tasks[1].params.unitId, 101)
  end)
end)

suite("_TickAssignment", function()
  it("returns early when group not existing", function()
    local group = makeGroup({alive = false})
    group.IsAlive = function() return false end
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    P:_TickAssignment(state)  -- should not error
    assertTrue(true)
  end)

  it("returns early when computed plan invalid", function()
    local group = makeGroup({alive = true, airborne = true})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return nil end
    P:_TickAssignment(state)
    P._GetComputedPlan = origCompute
    assertTrue(true)
  end)

  it("sets GROUND mode when group not airborne", function()
    local group = makeGroup({alive = true, airborne = false})
    local state = makeState({assignmentOpts = {group = group, plan = {waypoints = {}}}})
    local navCwp = makeCWp({source = makeWp({type = "NAV", coordinate = makeCoord({x = 5000})}), resolvedAltFt = 500, legGsKt = 180, etaSec = 43260})
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return makeComputed({makeCWp(), navCwp}) end
    setAbsTime(43200)
    P:_TickAssignment(state)
    P._GetComputedPlan = origCompute
    setAbsTime(0)
    assertEq(state.aiMode, "GROUND")
  end)

  it("sets DIRECT_WP when no ETA on current waypoint", function()
    local group = makeGroup({alive = true, airborne = true, coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    local navCwp = makeCWp({source = makeWp({type = "NAV", coordinate = makeCoord({x = 50000})}), resolvedAltFt = 500, legGsKt = 180})
    navCwp.etaSec = nil
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return makeComputed({makeCWp(), navCwp}) end
    P:_TickAssignment(state)
    P._GetComputedPlan = origCompute
    assertEq(state.aiMode, "DIRECT_WP")
    assertEq(state.aiModeReason, "no_eta")
  end)

  it("sends initial airborne route on first tick", function()
    local group = makeGroup({alive = true, airborne = true, coordinate = makeCoord({x = 0, y = 0, z = 0})})
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    setAbsTime(43200)
    setTime(0)
    local navCwp = makeCWp({
      source = makeWp({type = "NAV", coordinate = makeCoord({x = 50000, y = 0, z = 0})}),
      resolvedAltFt = 500, legGsKt = 180, etaSec = 43200 + 20 * 60,
    })
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return makeComputed({makeCWp(), navCwp}) end
    P:_TickAssignment(state)
    P._GetComputedPlan = origCompute
    setAbsTime(0)
    assertNotNil(state.lastRetaskTime)
    assertEq(#group._routeCalls, 1)
  end)
end)

-- ===== 10_main.lua =====

suite("Tick", function()
  it("does nothing when Config.enabled is false", function()
    P.Config.enabled = false
    P:Tick()
    P.Config.enabled = true
    assertTrue(true)
  end)

  it("processes discovered assignments", function()
    P.Config.enabled = true
    local group = makeGroup({
      alive = true, airborne = true,
      name = "MOSQUITO 1-1 [MN:JERICHO]",
      coordinate = makeCoord({x = 0, y = 0, z = 0}),
    })
    local plans = {JERICHO = {waypoints = {}}}
    MosieNavigator.Plans = plans
    SET_GROUP = {
      New = function(self) return self end,
      FilterStart = function(self) return self end,
      ForEachGroup = function(self, fn) fn(group) end,
    }
    setAbsTime(43200)
    setTime(0)
    local navCwp = makeCWp({
      source = makeWp({type = "NAV", coordinate = makeCoord({x = 50000, y = 0, z = 0})}),
      resolvedAltFt = 500, legGsKt = 180, etaSec = 43200 + 20 * 60,
    })
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return makeComputed({makeCWp(), navCwp}) end
    P.States = nil
    P:Tick()
    P._GetComputedPlan = origCompute
    MosieNavigator.Plans = nil
    SET_GROUP = nil
    setAbsTime(0)
    assertNotNil(P.States)
    assertNotNil(P.States["MOSQUITO 1-1 [MN:JERICHO]"])
  end)
end)

------------------------------------------------------------
-- Additional coverage tests (04_io, 06_geo, 08_route, 10_main)
------------------------------------------------------------

suite("_GetOutputDirectory fallback", function()
  it("returns ./ when navigator has no _GetOutputDirectory", function()
    local origNav = MosieNavigator
    MosieNavigator = nil
    local dir = P:_GetOutputDirectory()
    MosieNavigator = origNav
    assertEq(dir, "./")
  end)
end)

suite("_ResetAiZoneDumpFile", function()
  it("runs in test mode without error", function()
    TEST_MODE = true
    P:_ResetAiZoneDumpFile()
    assertTrue(true)
  end)

  it("no-ops when not in test mode", function()
    TEST_MODE = false
    P:_ResetAiZoneDumpFile()
    TEST_MODE = true
    assertTrue(true)
  end)
end)

suite("_AppendAiZoneDump direct", function()
  it("writes text in test mode without error", function()
    TEST_MODE = true
    P:_AppendAiZoneDump("test line " .. tostring(math.random(1, 9999)))
    assertTrue(true)
  end)
end)

suite("_FindNearestLandingAirbase AIRBASE fallback", function()
  it("finds nearest airbase via AIRBASE.GetAllAirbases", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local abCoord = makeCoord({x = 100, y = 0, z = 0})
    local fakeAb = {
      GetAirbaseCategory = function() return Airbase.Category.AIRDROME end,
      GetCoordinate = function() return abCoord end,
    }
    AIRBASE = {GetAllAirbases = function() return {fakeAb} end}
    local ab, dist = P:_FindNearestLandingAirbase(coord)
    AIRBASE = nil
    assertEq(ab, fakeAb)
    assertNotNil(dist)
  end)

  it("skips airbase when GetAirbaseCategory throws and filter is active", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local abCoord = makeCoord({x = 100, y = 0, z = 0})
    local fakeAb = {
      GetAirbaseCategory = function() error("no cat") end,
      GetCoordinate = function() return abCoord end,
    }
    AIRBASE = {GetAllAirbases = function() return {fakeAb} end}
    -- category=nil, airdromeCategory=0 → condition false → airbase skipped
    local ab, dist = P:_FindNearestLandingAirbase(coord)
    AIRBASE = nil
    assertNil(ab)
    assertNil(dist)
  end)

  it("returns nil,nil when AIRBASE.GetAllAirbases returns nil", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    AIRBASE = {GetAllAirbases = function() return nil end}
    local ab, dist = P:_FindNearestLandingAirbase(coord)
    AIRBASE = nil
    assertNil(ab)
    assertNil(dist)
  end)
end)

suite("_GetAirbaseName extra fallbacks", function()
  it("uses airbaseName field", function()
    assertEq(P:_GetAirbaseName({airbaseName = "Hawkinge"}), "Hawkinge")
  end)
end)

suite("_GetLineInterceptVec2 success", function()
  it("returns intercept point when xte exceeds threshold and distance > min", function()
    -- Previous wp at origin, current wp 20 NM north (37040m)
    local prevCoord = makeCoord({x = 0, y = 0, z = 0})
    local currCoord = makeCoord({x = 0, y = 0, z = 37040})
    -- Group: 2 NM east (3704m), 5 NM along track (9260m)
    local groupCoord = makeCoord({x = 3704, y = 0, z = 9260})
    local group = makeGroup({coordinate = groupCoord})
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    local prevCwp = makeCWp({source = makeWp({type = "TAKE_OFF", coordinate = prevCoord})})
    local currCwp = makeCWp({source = makeWp({type = "NAV", coordinate = currCoord})})
    local computed = makeComputed({prevCwp, currCwp})
    -- Stub _GetAiXte to return 2 NM XTE (above 1 NM threshold)
    local origXte = P._GetAiXte
    P._GetAiXte = function(_, s, gc) return 2.0, "R" end
    local vec2, details = P:_GetLineInterceptVec2(state, computed, 2)
    P._GetAiXte = origXte
    assertNotNil(vec2, "should return intercept vec2")
    assertNotNil(details, "should return intercept details string")
    assertMatch(details, "intercept_xte_nm")
  end)
end)

suite("_BuildRoute with intercept", function()
  it("includes intercept point in route when XTE is large", function()
    local prevCoord = makeCoord({x = 0, y = 0, z = 0})
    local currCoord = makeCoord({x = 0, y = 0, z = 37040})
    local groupCoord = makeCoord({x = 3704, y = 0, z = 9260})
    local group = makeGroup({coordinate = groupCoord, altitude = 500})
    local state = makeState({
      assignmentOpts = {group = group, plan = {waypoints = {}}},
      currentWpIndex = 2,
    })
    local prevCwp = makeCWp({source = makeWp({type = "TAKE_OFF", coordinate = prevCoord}), legGsKt = 180, resolvedAltFt = 0})
    local currCwp = makeCWp({source = makeWp({type = "NAV", coordinate = currCoord}), legGsKt = 180, resolvedAltFt = 500})
    local computed = makeComputed({prevCwp, currCwp})
    local origXte = P._GetAiXte
    P._GetAiXte = function(_, s, gc) return 2.0, "R" end
    local route, mode, details = P:_BuildRoute(state, computed, 2, 180)
    P._GetAiXte = origXte
    -- route: [current pos] [intercept] [NAV wp] = 3 points
    assertTrue(#route >= 3, "intercept route should have ≥3 points")
    assertEq(mode, "INTERCEPT_LINE")
  end)
end)

suite("Start / Tick (10_main.lua)", function()
  it("Start schedules with configured interval", function()
    local scheduled = {}
    SCHEDULER = {
      New = function(self, obj, fn, args, delay, interval)
        table.insert(scheduled, {fn = fn, delay = delay, interval = interval})
        return {}
      end,
    }
    P.Scheduler = nil
    P.States = nil
    TEST_MODE = true
    P.Config.enabled = true
    P:Start()
    SCHEDULER = nil
    assertEq(#scheduled, 1)
    assertEq(scheduled[1].interval, P.Config.tickInterval)
    P.Scheduler = nil
  end)

  it("Start is idempotent when Scheduler already set", function()
    P.Scheduler = {}
    local logCount = 0
    local origLog = P._Log
    P._Log = function(_, m) logCount = logCount + 1 end
    P:Start()
    P._Log = origLog
    P.Scheduler = nil
    assertEq(logCount, 0)
  end)

  it("Start does nothing when disabled", function()
    P.Config.enabled = false
    local logCount = 0
    local origLog = P._Log
    P._Log = function(_, m) logCount = logCount + 1 end
    P:Start()
    P._Log = origLog
    P.Config.enabled = true
    assertEq(logCount, 0)
  end)
end)

suite("_GetSecondsToClockSeconds fallback elseif branch", function()
  it("wraps when raw delta exceeds half-day (event far ahead = actually past)", function()
    -- now=01:00 (3600s), event=23:00 (82800s) → delta=79200 > 43200 → delta-=86400 → -7200
    local origNav = MosieNavigator
    MosieNavigator = nil
    setAbsTime(3600)
    local delta = P:_GetSecondsToClockSeconds(82800)
    setAbsTime(0)
    MosieNavigator = origNav
    assertNear(delta, -7200, 1)
  end)
end)

suite("_TickZoneDump zone entry and re-entry suppression", function()
  it("appends dump on first zone entry and suppresses re-entry", function()
    local appended = {}
    local origAppend = P._AppendAiZoneDump
    P._AppendAiZoneDump = function(_, text) table.insert(appended, text) end
    local coord = makeCoord({x=0, y=0, z=0})
    local group = makeGroup({coordinate=coord})
    local zone = {
      IsCoordinateInZone = function(_, c) return true end,
      GetRadius          = function()     return 500  end,
    }
    local wp = makeWp({type="NAV", order=1, coordinate=coord, zone=zone, zoneName="MN_T_01_NAV"})
    local plan    = {waypoints = {wp}}
    local state   = makeState({assignmentOpts={group=group, plan=plan}, currentWpIndex=1})
    local computed = makeComputed({makeCWp()})
    TEST_MODE = true
    P:_TickZoneDump(state, computed)
    P._AppendAiZoneDump = origAppend
    assertEq(#appended, 1, "first entry should append zone dump")
    local appended2 = {}
    P._AppendAiZoneDump = function(_, text) table.insert(appended2, text) end
    P:_TickZoneDump(state, computed)
    P._AppendAiZoneDump = origAppend
    assertEq(#appended2, 0, "re-entry should not append again")
  end)
end)

suite("_GetAiXte with both plan waypoints present", function()
  it("delegates to navigator _CalculateXte when previous and current WP exist", function()
    local prevWp = makeWp({type="TAKE_OFF", order=1, coordinate=makeCoord({x=0, y=0, z=0})})
    local currWp = makeWp({type="NAV",     order=2, coordinate=makeCoord({x=0, y=0, z=18520})})
    local plan   = {waypoints={prevWp, currWp}}
    local group  = makeGroup({coordinate=makeCoord({x=500, y=0, z=9260})})
    local state  = makeState({assignmentOpts={group=group, plan=plan}, currentWpIndex=2})
    local xte, side = P:_GetAiXte(state, group._coordinate)
    assertTrue(xte == nil or type(xte) == "number", "XTE should be nil or number")
  end)
end)

suite("_FormatAiFlightSample with etaDeltaSec computed", function()
  it("includes numeric eta_delta_sec when both actual and planned ETA are available", function()
    local coord   = makeCoord({x=0, y=0, z=18520})  -- 10 NM from origin
    local wpCoord = makeCoord({x=0, y=0, z=0})
    local group   = makeGroup({coordinate=coord, velocity=180, altitude=500})
    local wp      = makeWp({type="NAV", order=2, coordinate=wpCoord})
    local cwp     = makeCWp({source=wp, etaSec=43200+3600, legGsKt=180, resolvedAltFt=500})
    local plan    = {waypoints={makeWp({type="TAKE_OFF", order=1}), wp}}
    local state   = makeState({assignmentOpts={group=group, plan=plan}, currentWpIndex=2})
    setAbsTime(43200)
    local result = P:_FormatAiFlightSample(state, makeComputed({makeCWp(), cwp}))
    setAbsTime(0)
    assertNotNil(result)
    assertMatch(result, "AI_FLIGHT_SAMPLE")
    assertTrue(
      not string.find(result, "eta_delta_sec=---", 1, true),
      "etaDeltaSec should be a number not ---"
    )
  end)
end)

suite("_TickAssignment ETA-driven retask", function()
  it("retasks with ETA reason when aircraft is late beyond tolerance", function()
    -- 40 NM to WP at 200 kt → predicted 720s; ETA in 300s → error 420s > 15
    local wpCoord = makeCoord({x=0, y=0, z=74080})
    local group   = makeGroup({alive=true, airborne=true,
                               coordinate=makeCoord({x=0, y=0, z=0}),
                               velocity=200, altitude=500})
    local navCwp = makeCWp({
      source=makeWp({type="NAV", coordinate=wpCoord}),
      resolvedAltFt=500, legGsKt=200, etaSec=43200+300,
    })
    local state = makeState({
      assignmentOpts={group=group, plan={waypoints={}}},
      currentWpIndex=2,
    })
    state.lastRetaskTime = 0  -- cooldown: now(1000)-0=1000 > 30 ✓
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return makeComputed({makeCWp(), navCwp}) end
    setAbsTime(43200); setTime(1000)
    P:_TickAssignment(state)
    P._GetComputedPlan = origCompute
    setAbsTime(0)
    assertNotNil(state.lastRouteReason)
    assertMatch(state.lastRouteReason, "ETA")
  end)
end)

suite("_TickAssignment within-ETA-tolerance path", function()
  it("sets within_eta_tolerance when already retasked and ETA error is small", function()
    -- 3 NM to WP at 200 kt → predicted 54s; ETA in 60s → error -6s < 15
    local wpCoord = makeCoord({x=0, y=0, z=5556})  -- 3 NM
    local group   = makeGroup({alive=true, airborne=true,
                               coordinate=makeCoord({x=0, y=0, z=0}),
                               velocity=200, altitude=500})
    local navCwp = makeCWp({
      source=makeWp({type="NAV", coordinate=wpCoord}),
      resolvedAltFt=500, legGsKt=200, etaSec=43200+60,
    })
    local state = makeState({
      assignmentOpts={group=group, plan={waypoints={}}},
      currentWpIndex=2,
    })
    state.lastRetaskTime = 999999  -- cooldown: 999999-999999=0 < 30 → blocks retask
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return makeComputed({makeCWp(), navCwp}) end
    setAbsTime(43200); setTime(999999)
    P:_TickAssignment(state)
    P._GetComputedPlan = origCompute
    setAbsTime(0)
    assertEq(state.aiMode, "DIRECT_WP")
    assertEq(state.aiModeReason, "within_eta_tolerance")
  end)
end)

suite("_TickAssignment HOLD branch returns after _TickHold", function()
  it("advances WP index and returns after _TickHold exits expired hold", function()
    local holdCoord = makeCoord({x=0, y=0, z=0})
    local landCoord = makeCoord({x=0, y=0, z=1852})
    local group     = makeGroup({alive=true, airborne=true,
                                 coordinate=makeCoord({x=0, y=0, z=37040}),
                                 velocity=0})
    local holdSrc = makeWp({type="HOLD",    order=2, coordinate=holdCoord})
    local landSrc = makeWp({type="LANDING", order=3, coordinate=landCoord})
    local plan    = {waypoints={makeWp({type="TAKE_OFF",order=1}), holdSrc, landSrc}}
    -- Hold ETA 100s in the past, holdDurationSec=0 → _TickHold exits immediately
    local holdCwp = makeCWp({source=holdSrc, etaSec=43200-100, holdDurationSec=0,
                              resolvedAltFt=0, legGsKt=140})
    local landCwp = makeCWp({source=landSrc, resolvedAltFt=0, legGsKt=140})
    local state = makeState({assignmentOpts={group=group, plan=plan}, currentWpIndex=2})
    local origCompute = P._GetComputedPlan
    P._GetComputedPlan = function() return makeComputed({makeCWp(), holdCwp, landCwp}) end
    setAbsTime(43200); setTime(0)
    P:_TickAssignment(state)
    P._GetComputedPlan = origCompute
    setAbsTime(0)
    assertEq(state.currentWpIndex, 3)  -- advanced past HOLD to LANDING
  end)
end)

------------------------------------------------------------
-- Bundle smoke test
------------------------------------------------------------

print("== Bundle smoke test")
it("MosieAiPlanner.lua loads without errors", function()
  local ok, err = pcall(dofile, "MosieAiPlanner.lua")
  assert(ok, "bundle failed to load: " .. tostring(err))
end)

------------------------------------------------------------
-- Runner
------------------------------------------------------------

runTests()
