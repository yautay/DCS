-- MosieNavigator.spec.lua
-- Unit tests for MosieNavigator.lua.
--
-- Run from this directory:
--   lua MosieNavigator.spec.lua
--
-- Loads real MOOSE (lib/Moose.lua) via its static include path with a
-- minimal DCS API shim, then loads MosieNavigator.lua and exercises
-- its parsers, formatters, math helpers, and zone discovery flow.
--
-- Compatible with Lua 5.1 / LuaJIT (DCS runtime).

------------------------------------------------------------
-- Section 1: DCS API shim
------------------------------------------------------------

local function nop() end

local function makeAutoStub(name)
  local stub = {}
  local mt
  mt = {
    __index = function(_, k)
      local child = makeAutoStub(name .. "." .. tostring(k))
      rawset(stub, k, child)
      return child
    end,
    __call = function() return makeAutoStub(name .. "()") end,
    __metatable = "autoStub",
  }
  setmetatable(stub, mt)
  return stub
end

local function emptyCoalition() return { nav_points = {}, country = {} } end

env = {
  info = nop,
  warning = nop,
  error = nop,
  setErrorMessageBoxEnabled = nop,
  getValueDictByKey = function(s) return s end,
  mission = {
    theatre = "Caucasus",
    coalition = { red = emptyCoalition(), blue = emptyCoalition(), neutrals = emptyCoalition() },
    date = { Year = 2026, Month = 6, Day = 6 },
    start_time = 0,
    weather = { atmosphere_type = 0, wind = { atGround = {speed=0, dir=0}, at2000 = {speed=0, dir=0}, at8000 = {speed=0, dir=0} } },
    triggers = { zones = {} },
    map = {},
  },
  DIFFICULTY = {},
}

local fakeAbsTime = 0
local fakeTime = 0
timer = {
  getAbsTime = function() return fakeAbsTime end,
  getTime = function() return fakeTime end,
  scheduleFunction = function() return 0 end,
  removeFunction = nop,
}

-- DCS event IDs (S_EVENT_*). MOOSE indexes into world.event.* at top-level
-- and performs arithmetic on S_EVENT_MAX, so these must be real numbers.
local WORLD_EVENT_NAMES = {
  "S_EVENT_INVALID", "S_EVENT_SHOT", "S_EVENT_HIT", "S_EVENT_TAKEOFF",
  "S_EVENT_LAND", "S_EVENT_CRASH", "S_EVENT_EJECTION", "S_EVENT_REFUELING",
  "S_EVENT_DEAD", "S_EVENT_PILOT_DEAD", "S_EVENT_BASE_CAPTURED",
  "S_EVENT_MISSION_START", "S_EVENT_MISSION_END", "S_EVENT_TOOK_CONTROL",
  "S_EVENT_REFUELING_STOP", "S_EVENT_BIRTH", "S_EVENT_HUMAN_FAILURE",
  "S_EVENT_DETAILED_FAILURE", "S_EVENT_ENGINE_STARTUP", "S_EVENT_ENGINE_SHUTDOWN",
  "S_EVENT_PLAYER_ENTER_UNIT", "S_EVENT_PLAYER_LEAVE_UNIT",
  "S_EVENT_PLAYER_COMMENT", "S_EVENT_SHOOTING_START", "S_EVENT_SHOOTING_END",
  "S_EVENT_MARK_ADDED", "S_EVENT_MARK_CHANGE", "S_EVENT_MARK_REMOVED",
  "S_EVENT_KILL", "S_EVENT_SCORE", "S_EVENT_UNIT_LOST",
  "S_EVENT_LANDING_AFTER_EJECTION", "S_EVENT_PARATROOPER_LENDING",
  "S_EVENT_DISCARD_CHAIR_AFTER_EJECTION", "S_EVENT_WEAPON_ADD",
  "S_EVENT_TRIGGER_ZONE", "S_EVENT_LANDING_QUALITY_MARK", "S_EVENT_BDA",
  "S_EVENT_AI_ABORT_MISSION", "S_EVENT_DAYNIGHT", "S_EVENT_FLIGHT_TIME",
  "S_EVENT_PLAYER_SELF_KILL_PILOT", "S_EVENT_PLAYER_CAPTURE_AIRFIELD",
  "S_EVENT_EMERGENCY_LANDING", "S_EVENT_UNIT_CREATE_TASK",
  "S_EVENT_UNIT_DELETE_TASK", "S_EVENT_SIMULATION_START",
  "S_EVENT_WEAPON_REARM", "S_EVENT_WEAPON_DROP", "S_EVENT_UNIT_TASK_TIMEOUT",
  "S_EVENT_UNIT_TASK_STAGE", "S_EVENT_MAC_SUBTASK_SCORE",
  "S_EVENT_MAC_EXTRA_SCORE", "S_EVENT_MISSION_RESTART",
  "S_EVENT_MISSION_WINNER", "S_EVENT_RUNWAY_TAKEOFF", "S_EVENT_RUNWAY_TOUCH",
  "S_EVENT_MAC_LMS_RESTART", "S_EVENT_SIMULATION_FREEZE",
  "S_EVENT_SIMULATION_UNFREEZE", "S_EVENT_HUMAN_AIRCRAFT_REPAIR_START",
  "S_EVENT_HUMAN_AIRCRAFT_REPAIR_FINISH", "S_EVENT_UNIT_TASK_COMPLETE",
}
local worldEvent = { S_EVENT_MAX = #WORLD_EVENT_NAMES + 1 }
for i, name in ipairs(WORLD_EVENT_NAMES) do worldEvent[name] = i end

world = {
  event = worldEvent,
  BirthPlace = { wsBirthPlace_Air = 1, wsBirthPlace_RunWay = 2, wsBirthPlace_Park = 3, wsBirthPlace_Heliport_Hot = 4, wsBirthPlace_Heliport_Cold = 5, wsBirthPlace_Ship_Cold = 6, wsBirthPlace_Ship_Hot = 7, wsBirthPlace_Ship = 8 },
  VolumeType = { SEGMENT = 0, BOX = 1, SPHERE = 2, PYRAMID = 3 },
  getPlayer = function() return nil end,
  getAirbases = function() return {} end,
  addEventHandler = nop,
  removeEventHandler = nop,
  searchObjects = nop,
  getMarkPanels = function() return {} end,
}

country = {
  id = makeAutoStub("country.id"),
  name = makeAutoStub("country.name"),
}

coalition = {
  side = { NEUTRAL = 0, RED = 1, BLUE = 2 },
  addGroup = nop,
  addStaticObject = nop,
  getGroups = function() return {} end,
  getStaticObjects = function() return {} end,
  getPlayers = function() return {} end,
  getCountryCoalition = function() return 0 end,
  getMainRefPoint = function() return { x = 0, y = 0, z = 0 } end,
  getAirbases = function() return {} end,
  getServiceProviders = function() return {} end,
}

trigger = {
  misc = makeAutoStub("trigger.misc"),
  action = makeAutoStub("trigger.action"),
  smokeColor = { Green = 0, Red = 1, White = 2, Orange = 3, Blue = 4 },
  flareColor = { Green = 0, Red = 1, White = 2, Yellow = 3 },
}

Airbase = {
  Category = { AIRDROME = 0, HELIPAD = 1, SHIP = 2 },
  TerminalType = { Runway = 16, HelicopterOnly = 40, Shelter = 68, OpenBig = 72, OpenMed = 104, OpenMedOrBig = 176, HelicopterUsable = 216, FighterAircraft = 244 },
}

Group = {
  Category = { AIRPLANE = 0, HELICOPTER = 1, GROUND = 2, SHIP = 3, TRAIN = 4 },
}

Unit = {
  Category = { AIRPLANE = 0, HELICOPTER = 1, GROUND_UNIT = 2, SHIP = 3, STRUCTURE = 4 },
  RefuelingSystem = { BOOM_AND_RECEPTACLE = 0, PROBE_AND_DROGUE = 1 },
}

Weapon = {
  Category = { SHELL = 0, MISSILE = 1, ROCKET = 2, BOMB = 3, TORPEDO = 4 },
  GuidanceType = { INS = 1, IR = 2, RADAR_ACTIVE = 3, RADAR_SEMI_ACTIVE = 4, RADAR_PASSIVE = 5, TV = 6, LASER = 7, TELE = 8 },
  MissileCategory = { AAM = 1, SAM = 2, BM = 3, ANTI_SHIP = 4, CRUISE = 5, OTHER = 6 },
  WarheadType = { AP = 0, HE = 1, SHAPED_EXPLOSIVE = 2 },
  flag = makeAutoStub("Weapon.flag"),
}

Object = {
  Category = { UNIT = 1, WEAPON = 2, STATIC = 3, BASE = 4, SCENERY = 5, CARGO = 6 },
}

Controller = makeAutoStub("Controller")

AI = {
  Task = makeAutoStub("AI.Task"),
  Skill = { AVERAGE = "Average", GOOD = "Good", HIGH = "High", EXCELLENT = "Excellent", RANDOM = "Random", PLAYER = "Player", CLIENT = "Client" },
  Option = makeAutoStub("AI.Option"),
}

Warehouse = makeAutoStub("Warehouse")

land = {
  SurfaceType = { LAND = 1, SHALLOW_WATER = 2, WATER = 3, ROAD = 4, RUNWAY = 5 },
  getHeight = function() return 0 end,
  getSurfaceType = function() return 1 end,
  getIP = function() return nil end,
  isVisible = function() return true end,
  profile = function() return {} end,
}

net = makeAutoStub("net")
radio = { modulation = { AM = 0, FM = 1 } }
missionCommands = makeAutoStub("missionCommands")
atmosphere = makeAutoStub("atmosphere")

-- Some MOOSE code may reference these
Terrain = makeAutoStub("Terrain")
CoalitionSide = coalition.side

------------------------------------------------------------
-- Section 2: Load MOOSE (force static include)
------------------------------------------------------------

MOOSE_DEVELOPMENT_FOLDER = "__nonexistent_test_folder__"
local ok, err = pcall(dofile, "../Moose.lua")
if not ok then
  io.stderr:write("Failed to load Moose.lua: " .. tostring(err) .. "\n")
  os.exit(1)
end

------------------------------------------------------------
-- Section 3: Sanity checks (real MOOSE integration)
------------------------------------------------------------

assert(type(UTILS) == "table", "UTILS not defined after loading Moose")
assert(type(UTILS.MetersToNM) == "function", "UTILS.MetersToNM missing")
assert(math.abs(UTILS.MetersToNM(1852) - 1) < 1e-6, "UTILS.MetersToNM broken")
assert(math.abs(UTILS.NMToMeters(1) - 1852) < 1e-3, "UTILS.NMToMeters broken")
assert(math.abs(UTILS.KnotsToMps(1) - 0.514444) < 1e-3, "UTILS.KnotsToMps broken")
assert(math.abs(UTILS.MpsToKnots(0.514444) - 1) < 1e-3, "UTILS.MpsToKnots broken")

------------------------------------------------------------
-- Section 4: Load code under test
------------------------------------------------------------

MOSIE_NAVIGATOR_AUTO_START = false
local _src_modules = {
  "src/01_config.lua", "src/02_util.lua", "src/03_parser.lua",
  "src/04_physics.lua", "src/05_compute.lua", "src/06_csv.lua",
  "src/07_discover.lua", "src/08_draw.lua", "src/09_guidance.lua",
  "src/10_navigator.lua", "src/11_messages.lua", "src/12_io.lua",
  "src/13_main.lua",
}
for _, name in ipairs(_src_modules) do dofile(name) end

------------------------------------------------------------
-- Section 5: Test helpers
------------------------------------------------------------

local function setAbsTime(v) fakeAbsTime = v end

-- Coordinate mock factory. Uses simple 2D geometry: distance is
-- Euclidean over (x,z); heading is atan2(dx,dz) in degrees, north = +z.
local function makeCoord(opts)
  opts = opts or {}
  local self = {
    x = opts.x or 0,
    y = opts.y or 0,
    z = opts.z or 0,
  }
  self.Get2DDistance = function(_, other)
    local dx = (other.x or 0) - self.x
    local dz = (other.z or 0) - self.z
    return math.sqrt(dx * dx + dz * dz)
  end
  self.HeadingTo = function(_, other)
    local dx = (other.x or 0) - self.x
    local dz = (other.z or 0) - self.z
    local h = math.deg(math.atan2(dx, dz))
    return (h % 360 + 360) % 360
  end
  self.GetVec3 = function() return { x = self.x, y = self.y, z = self.z } end
  self.GetLLDDM = function() return opts.lat or 0, opts.lon or 0 end
  self.GetMagneticDeclination = function() return opts.declination or 0 end
  self.GetWindVec3 = function() return opts.wind or { x = 0, y = 0, z = 0 } end
  return self
end

------------------------------------------------------------
-- Section 6: Mini test framework
------------------------------------------------------------

local totalPass, totalFail = 0, 0
local failures = {}
local currentSuite = ""

local function suite(name, fn)
  currentSuite = name
  print("== " .. name)
  fn()
end

local function it(name, fn)
  local ok, err = pcall(fn)
  if ok then
    totalPass = totalPass + 1
    print("  PASS " .. name)
  else
    totalFail = totalFail + 1
    table.insert(failures, currentSuite .. " / " .. name .. " : " .. tostring(err))
    print("  FAIL " .. name .. " : " .. tostring(err))
  end
end

local function assertEq(actual, expected, msg)
  if actual ~= expected then
    error((msg or "eq") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

local function assertNil(v, msg)
  if v ~= nil then
    error((msg or "nil") .. ": expected nil, got " .. tostring(v), 2)
  end
end

local function assertNotNil(v, msg)
  if v == nil then
    error((msg or "notNil") .. ": expected non-nil", 2)
  end
end

local function assertNear(actual, expected, epsilon, msg)
  epsilon = epsilon or 1e-6
  if math.abs(actual - expected) > epsilon then
    error((msg or "near") .. ": expected " .. tostring(expected) .. " +/- " .. tostring(epsilon) .. ", got " .. tostring(actual), 2)
  end
end

local function assertMatch(s, pattern, msg)
  if not string.find(s, pattern) then
    error((msg or "match") .. ": '" .. tostring(s) .. "' does not match '" .. pattern .. "'", 2)
  end
end

local function assertTrue(v, msg)
  if not v then error((msg or "true") .. ": expected truthy", 2) end
end

------------------------------------------------------------
-- Section 7: Test suites
------------------------------------------------------------

local M = MosieNavigator

suite("Split / SplitPlain / Join", function()
  it("_Split splits on separator", function()
    local r = M:_Split("a_b_c", "_")
    assertEq(#r, 3); assertEq(r[1], "a"); assertEq(r[3], "c")
  end)
  it("_Split collapses double separators (regex behavior)", function()
    local r = M:_Split("a__b", "_")
    assertEq(#r, 2); assertEq(r[1], "a"); assertEq(r[2], "b")
  end)
  it("_SplitPlain preserves empty tokens", function()
    local r = M:_SplitPlain("a__b", "_")
    assertEq(#r, 3); assertEq(r[2], "")
  end)
  it("_SplitPlain handles multi-char delimiter", function()
    local r = M:_SplitPlain("MN_X__A50", "__")
    assertEq(#r, 2); assertEq(r[1], "MN_X"); assertEq(r[2], "A50")
  end)
  it("_Join reassembles from index", function()
    assertEq(M:_Join({"a","b","c","d"}, 2, "-"), "b-c-d")
  end)
  it("_Join returns empty for out-of-range start", function()
    assertEq(M:_Join({"a","b"}, 5, "-"), "")
  end)
end)

suite("ParseTimeOnTarget", function()
  it("parses HH:MM", function()
    local text, sec = M:_ParseTimeOnTarget("14:30")
    assertEq(text, "14:30"); assertEq(sec, 14 * 3600 + 30 * 60)
  end)
  it("rejects HH:MM:SS", function()
    assertNil(M:_ParseTimeOnTarget("14:30:45"))
  end)
  it("rejects invalid", function()
    assertNil(M:_ParseTimeOnTarget("garbage"))
    assertNil(M:_ParseTimeOnTarget("25:00"))
    assertNil(M:_ParseTimeOnTarget("14:60"))
    assertNil(M:_ParseTimeOnTarget("14:30:60"))
    assertNil(M:_ParseTimeOnTarget(""))
    assertNil(M:_ParseTimeOnTarget(nil))
  end)
end)

suite("ParseRolexDuration", function()
  it("parses minute-only", function()
    assertEq(M:_ParseRolexDuration("5"), 5 * 60)
  end)
  it("parses minute-only >= 60 (unbounded)", function()
    assertEq(M:_ParseRolexDuration("120"), 120 * 60)
    assertEq(M:_ParseRolexDuration("90"), 90 * 60)
  end)
  it("parses minute-only zero", function()
    assertEq(M:_ParseRolexDuration("0"), 0)
  end)
  it("rejects negative minute-only", function()
    assertNil(M:_ParseRolexDuration("-5"))
  end)
  it("parses H:MM", function()
    assertEq(M:_ParseRolexDuration("0:05"), 5 * 60)
    assertEq(M:_ParseRolexDuration("1:30"), 3600 + 30 * 60)
  end)
  it("rejects H:MM with minutes > 59", function()
    assertNil(M:_ParseRolexDuration("1:60"))
  end)
  it("parses H:MM:SS", function()
    assertEq(M:_ParseRolexDuration("0:00:30"), 30)
    assertEq(M:_ParseRolexDuration("1:02:03"), 3600 + 120 + 3)
  end)
  it("rejects too many parts", function()
    assertNil(M:_ParseRolexDuration("1:2:3:4"))
  end)
  it("rejects garbage", function()
    assertNil(M:_ParseRolexDuration("abc"))
  end)
end)

suite("FormatClock", function()
  it("HH:MM when seconds=0", function()
    assertEq(M:_FormatClock(14 * 3600 + 30 * 60), "14:30")
  end)
  it("HH:MM:SS when seconds > 0", function()
    assertEq(M:_FormatClock(14 * 3600 + 30 * 60 + 45), "14:30:45")
  end)
  it("wraps modulo day", function()
    assertEq(M:_FormatClock(25 * 3600), "01:00")
  end)
end)

suite("FormatRolex", function()
  it("zero → +00:00", function()
    assertEq(M:_FormatRolex(0), "+00:00")
    assertEq(M:_FormatRolex(nil), "+00:00")
  end)
  it("+HH:MM", function()
    assertEq(M:_FormatRolex(5 * 60), "+00:05")
    assertEq(M:_FormatRolex(3600 + 30 * 60), "+01:30")
  end)
  it("+HH:MM:SS", function()
    assertEq(M:_FormatRolex(30), "+00:00:30")
  end)
end)

suite("FormatDuration", function()
  it("nil → --", function()
    assertEq(M:_FormatDuration(nil), "--")
  end)
  it("positive", function()
    assertEq(M:_FormatDuration(65), "1:05")
    assertEq(M:_FormatDuration(3661), "61:01")
  end)
  it("negative", function()
    assertEq(M:_FormatDuration(-65), "-1:05")
  end)
end)

suite("ParseWaypointMetadata", function()
  it("A prefix", function()
    assertEq(M:_ParseWaypointMetadata({"A500"}).altitudeFt, 500)
  end)
  it("A500FT", function()
    assertEq(M:_ParseWaypointMetadata({"A500FT"}).altitudeFt, 500)
  end)
  it("ALT500 is unknown (alias removed)", function()
    assertNil(M:_ParseWaypointMetadata({"ALT500"}).altitudeFt)
  end)
  it("ALT500FT is unknown (alias removed)", function()
    assertNil(M:_ParseWaypointMetadata({"ALT500FT"}).altitudeFt)
  end)
  it("T14:30", function()
    local md = M:_ParseWaypointMetadata({"T14:30"})
    assertEq(md.timeOnTarget, "14:30")
    assertEq(md.timeOnTargetSeconds, 14 * 3600 + 30 * 60)
  end)
  it("TOT14:30 is unknown (alias removed)", function()
    assertNil(M:_ParseWaypointMetadata({"TOT14:30"}).timeOnTarget)
  end)
  it("S180 speed token", function()
    assertEq(M:_ParseWaypointMetadata({"S180"}).speedKt, 180)
  end)
  it("S180KT speed token", function()
    assertEq(M:_ParseWaypointMetadata({"S180KT"}).speedKt, 180)
  end)
  it("s200kt case-insensitive", function()
    assertEq(M:_ParseWaypointMetadata({"s200kt"}).speedKt, 200)
  end)
  it("both A and T", function()
    local md = M:_ParseWaypointMetadata({"A500", "T14:30"})
    assertEq(md.altitudeFt, 500)
    assertEq(md.timeOnTarget, "14:30")
  end)
  it("A T and S together", function()
    local md = M:_ParseWaypointMetadata({"A500", "T14:30", "S180"})
    assertEq(md.altitudeFt, 500)
    assertEq(md.timeOnTarget, "14:30")
    assertEq(md.speedKt, 180)
  end)
  it("negative altitude", function()
    assertEq(M:_ParseWaypointMetadata({"A-500"}).altitudeFt, -500)
  end)
end)

suite("ParseWaypointZoneName", function()
  it("minimal happy path", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_02_NAV")
    assertNotNil(wp)
    assertEq(wp.plan, "JERICHO"); assertEq(wp.order, 2)
    assertEq(wp.type, "NAV"); assertEq(wp.name, "NAV")
  end)
  it("with NAME", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_03_NAV_Checkpoint")
    assertEq(wp.name, "Checkpoint")
  end)
  it("TAKE_OFF with NAME", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_01_TAKE_OFF_Tangmere")
    assertEq(wp.type, "TAKE_OFF"); assertEq(wp.name, "Tangmere")
  end)
  it("TAKE_OFF without NAME", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_01_TAKE_OFF")
    assertEq(wp.type, "TAKE_OFF"); assertEq(wp.name, "TAKE_OFF")
  end)
  it("LAND alias normalizes to LANDING", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_08_LAND_Tangmere")
    assertNotNil(wp)
    assertEq(wp.type, "LANDING")
    assertEq(wp.name, "Tangmere")
  end)
  it("A and T metadata", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_05_INGRESS_IP__A50__T14:28")
    assertEq(wp.altitudeFt, 50)
    assertEq(wp.timeOnTargetSeconds, 14 * 3600 + 28 * 60)
  end)
  it("rejects non-MN prefix", function()
    assertNil(M:_ParseWaypointZoneName("SOMETHING_ELSE"))
    assertNil(M:_ParseWaypointZoneName("MNB_TANGMERE"))
  end)
  it("rejects unknown type", function()
    assertNil(M:_ParseWaypointZoneName("MN_JERICHO_01_BOGUS"))
  end)
  it("rejects empty middle token", function()
    assertNil(M:_ParseWaypointZoneName("MN_JERICHO__01_NAV"))
  end)
  it("rejects non-numeric order", function()
    assertNil(M:_ParseWaypointZoneName("MN_JERICHO_XX_NAV"))
  end)
  it("multi-word NAME preserved", function()
    local wp = M:_ParseWaypointZoneName("MN_PLAN_04_HOLD_Some_Long_Name")
    assertEq(wp.name, "Some_Long_Name")
  end)
  it("nameExplicit false when no explicit name", function()
    assertEq(M:_ParseWaypointZoneName("MN_JERICHO_02_NAV").nameExplicit, false)
    assertEq(M:_ParseWaypointZoneName("MN_JERICHO_01_TAKE_OFF").nameExplicit, false)
  end)
  it("nameExplicit true when explicit name present", function()
    assertEq(M:_ParseWaypointZoneName("MN_JERICHO_03_NAV_Checkpoint").nameExplicit, true)
    assertEq(M:_ParseWaypointZoneName("MN_JERICHO_01_TAKE_OFF_Tangmere").nameExplicit, true)
  end)
  it("rejects removed RENDEZVOUS type", function()
    assertNil(M:_ParseWaypointZoneName("MN_JERICHO_03_RENDEZVOUS_Rendezvous"))
  end)
  it("__S token parsed into speedKt", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_02_NAV__S180")
    assertNotNil(wp)
    assertEq(wp.speedKt, 180)
  end)
  it("__A and __S and __T all parsed", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_05_INGRESS_IP__A50__T14:28__S200")
    assertNotNil(wp)
    assertEq(wp.altitudeFt, 50)
    assertEq(wp.speedKt, 200)
    assertEq(wp.timeOnTargetSeconds, 14 * 3600 + 28 * 60)
  end)
  it("no __S → speedKt nil", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_02_NAV")
    assertNil(wp.speedKt)
  end)
end)

suite("ParseBeaconZoneName", function()
  it("minimal", function()
    local b = M:_ParseBeaconZoneName("MNB_TANGMERE")
    assertNotNil(b); assertEq(b.id, "TANGMERE")
    assertEq(b.powerNm, 60); assertEq(b.altitudeFt, 0)
  end)
  it("full", function()
    local b = M:_ParseBeaconZoneName("MNB_TANGMERE_310KHZ_120NM_200FT")
    assertEq(b.id, "TANGMERE"); assertEq(b.frequency, "310KHZ")
    assertEq(b.powerNm, 120); assertEq(b.altitudeFt, 200)
  end)
  it("rejects non-MNB", function()
    assertNil(M:_ParseBeaconZoneName("MN_JERICHO_01_NAV"))
  end)
  it("rejects empty middle token", function()
    assertNil(M:_ParseBeaconZoneName("MNB__TANGMERE"))
  end)
end)

suite("ParseNumberWithSuffix", function()
  it("NM / FT", function()
    assertEq(M:_ParseNumberWithSuffix("120NM", "NM"), 120)
    assertEq(M:_ParseNumberWithSuffix("200FT", "FT"), 200)
  end)
  it("case-insensitive", function()
    assertEq(M:_ParseNumberWithSuffix("120nm", "NM"), 120)
  end)
  it("decimals", function()
    assertEq(M:_ParseNumberWithSuffix("12.5NM", "NM"), 12.5)
  end)
  it("rejects mismatched suffix", function()
    assertNil(M:_ParseNumberWithSuffix("120NM", "FT"))
  end)
  it("rejects nil", function()
    assertNil(M:_ParseNumberWithSuffix(nil, "NM"))
  end)
end)

suite("GetPlanColor / CopyColor", function()
  it("cycles through PlanColors", function()
    local c1 = M:_GetPlanColor(1)
    local c8 = M:_GetPlanColor(8)
    assertEq(c1, c8)
  end)
  it("CopyColor returns independent copy", function()
    local orig = {0.1, 0.2, 0.3}
    local cp = M:_CopyColor(orig)
    assertEq(cp[1], 0.1); assertEq(cp[3], 0.3)
    cp[1] = 999
    assertEq(orig[1], 0.1)
  end)
end)

suite("SanitizeFilename", function()
  it("keeps alnum, hyphen, underscore", function()
    assertEq(M:_SanitizeFilename("abc-XYZ_123"), "abc-XYZ_123")
  end)
  it("replaces spaces and special chars", function()
    assertEq(M:_SanitizeFilename("A B/C.D"), "A_B_C_D")
  end)
end)

suite("FormatHeading / NormalizeHeading / Atan2", function()
  it("nil → ---", function()
    assertEq(M:_FormatHeading(nil), "---")
  end)
  it("zero-pads", function()
    assertEq(M:_FormatHeading(5), "005")
    assertEq(M:_FormatHeading(90), "090")
    assertEq(M:_FormatHeading(359), "359")
  end)
  it("modulo 360", function()
    assertEq(M:_FormatHeading(360), "000")
    assertEq(M:_FormatHeading(720), "000")
  end)
  it("rounds to nearest", function()
    assertEq(M:_FormatHeading(89.6), "090")
  end)
  it("NormalizeHeading wraps", function()
    assertNear(M:_NormalizeHeading(370), 10)
    assertNear(M:_NormalizeHeading(-10), 350)
    assertNear(M:_NormalizeHeading(0), 0)
  end)
  it("Atan2 basic", function()
    assertNear(M:_Atan2(0, 1), 0)
    assertNear(M:_Atan2(1, 0), math.pi / 2)
  end)
end)

suite("FormatSpeed / FormatOptional", function()
  it("nil speed → ---", function()
    assertEq(M:_FormatSpeed(nil), "---")
  end)
  it("integer format", function()
    assertEq(M:_FormatSpeed(240.7), "241")
    assertEq(M:_FormatSpeed(0), "0")
  end)
  it("FormatOptional nil → ---", function()
    assertEq(M:_FormatOptional(nil), "---")
  end)
  it("FormatOptional value → string", function()
    assertEq(M:_FormatOptional(500), "500")
  end)
end)

suite("FormatDecimalMinutes / FitText", function()
  it("N hemisphere", function()
    local s = M:_FormatDecimalMinutes(50.5, "N", "S", 2)
    assertMatch(s, "^N50 30%.00$")
  end)
  it("S hemisphere", function()
    local s = M:_FormatDecimalMinutes(-50.5, "N", "S", 2)
    assertMatch(s, "^S50")
  end)
  it("rollover just above 59.995 threshold", function()
    -- Value slightly above 59.995 to avoid FP precision boundary
    local s = M:_FormatDecimalMinutes(50 + 59.999 / 60, "N", "S", 2)
    assertMatch(s, "^N51 00%.00$")
  end)
  it("FitText truncates", function()
    assertEq(M:_FitText("abcdefgh", 5), "abcde")
  end)
  it("FitText preserves shorter", function()
    assertEq(M:_FitText("abc", 5), "abc")
  end)
  it("FitText nil → empty", function()
    assertEq(M:_FitText(nil, 5), "")
  end)
end)



suite("ExtractPlan / ExtractRolex from group name", function()
  it("plan tag", function()
    assertEq(M:_ExtractPlanFromGroupName("MOSQUITO 1-1 [MN:JERICHO]"), "JERICHO")
  end)
  it("no plan tag → nil", function()
    assertNil(M:_ExtractPlanFromGroupName("PLAIN GROUP"))
  end)
  it("rolex minutes", function()
    assertEq(M:_ExtractRolexFromGroupName("MOSQUITO 1-2 [MN:JERICHO]__R0:05"), 5 * 60)
  end)
  it("rolex H:MM:SS", function()
    assertEq(M:_ExtractRolexFromGroupName("MOSQUITO 1-3 [MN:JERICHO]__R0:00:30"), 30)
  end)
  it("no rolex → 0", function()
    assertEq(M:_ExtractRolexFromGroupName("MOSQUITO 1-1 [MN:JERICHO]"), 0)
  end)
  it("case-insensitive R", function()
    assertEq(M:_ExtractRolexFromGroupName("MOSQUITO [MN:X]__r5"), 5 * 60)
  end)
end)

suite("FormatWaypointTot", function()
  it("no TOT → ---", function()
    assertEq(M:_FormatWaypointTot({}, 0), "---")
  end)
  it("with TOT", function()
    local wp = { timeOnTargetSeconds = 14 * 3600 + 30 * 60 }
    assertEq(M:_FormatWaypointTot(wp, 0), "14:30")
  end)
  it("with ROLEX shift", function()
    local wp = { timeOnTargetSeconds = 14 * 3600 + 30 * 60 }
    assertEq(M:_FormatWaypointTot(wp, 5 * 60), "14:35")
  end)
end)

suite("ConvertIasToTas", function()
  it("nil IAS → nil", function()
    assertNil(M:_ConvertIasToTas(nil, 5000))
  end)
  it("nil altitude → nil", function()
    assertNil(M:_ConvertIasToTas(200, nil))
  end)
  it("IAS = TAS at sea level", function()
    assertNear(M:_ConvertIasToTas(200, 0), 200, 0.01)
  end)
  it("TAS > IAS at altitude", function()
    local tas = M:_ConvertIasToTas(200, 10000)
    assertTrue(tas > 200, "TAS should exceed IAS: " .. tostring(tas))
    assertTrue(tas < 260, "TAS sanity range: " .. tostring(tas))
  end)
  it("round-trip with ConvertTasToIas", function()
    local ias = 180
    local alt = 8000
    local tas = M:_ConvertIasToTas(ias, alt)
    local iasBack = M:_ConvertTasToIas(tas, alt)
    assertNear(iasBack, ias, 0.01, "round-trip IAS")
  end)
end)

suite("ConvertTasToIas", function()
  it("nil TAS → nil", function()
    assertNil(M:_ConvertTasToIas(nil, 5000))
  end)
  it("nil altitude → nil", function()
    assertNil(M:_ConvertTasToIas(200, nil))
  end)
  it("TAS = IAS at sea level", function()
    assertNear(M:_ConvertTasToIas(200, 0), 200, 0.01)
  end)
  it("IAS < TAS at altitude", function()
    local ias = M:_ConvertTasToIas(200, 10000)
    assertTrue(ias < 200, "IAS should be less than TAS: " .. tostring(ias))
    assertTrue(ias > 150, "IAS sanity range: " .. tostring(ias))
  end)
end)

suite("GetAdjustedTotSeconds / GetSecondsToWaypointTot", function()
  it("no TOT → nil", function()
    assertNil(M:_GetAdjustedTotSeconds({}, 0))
    assertNil(M:_GetSecondsToWaypointTot({}, 0))
  end)
  it("ROLEX shift modulo day", function()
    local wp = { timeOnTargetSeconds = 23 * 3600 }
    assertEq(M:_GetAdjustedTotSeconds(wp, 2 * 3600), 3600)
  end)
  it("positive delta when TOT in future", function()
    local wp = { timeOnTargetSeconds = 14 * 3600 + 30 * 60 }
    setAbsTime(14 * 3600 + 25 * 60)
    assertEq(M:_GetSecondsToWaypointTot(wp, 0), 5 * 60)
  end)
  it("negative delta when TOT passed", function()
    local wp = { timeOnTargetSeconds = 14 * 3600 }
    setAbsTime(14 * 3600 + 5 * 60)
    assertEq(M:_GetSecondsToWaypointTot(wp, 0), -5 * 60)
  end)
  it("wrap: TOT 23:00, now 01:00 → -2h", function()
    local wp = { timeOnTargetSeconds = 23 * 3600 }
    setAbsTime(1 * 3600)
    assertEq(M:_GetSecondsToWaypointTot(wp, 0), -2 * 3600)
  end)
  it("wrap: TOT 01:00, now 23:00 → +2h", function()
    local wp = { timeOnTargetSeconds = 1 * 3600 }
    setAbsTime(23 * 3600)
    assertEq(M:_GetSecondsToWaypointTot(wp, 0), 2 * 3600)
  end)
end)



suite("CalculateXte", function()
  it("no previous → nil, nil", function()
    local wp = { coordinate = makeCoord({x=0,z=0}) }
    local xte, side = M:_CalculateXte(nil, wp, makeCoord({x=0,z=0}))
    assertNil(xte); assertNil(side)
  end)
  it("on-track → xte ~ 0", function()
    local prev = { coordinate = makeCoord({x=0, z=0}) }
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local cur = makeCoord({x=0, z=926})
    local xte = M:_CalculateXte(prev, wp, cur)
    assertNear(xte, 0, 0.001)
  end)
  it("off-track port side", function()
    local prev = { coordinate = makeCoord({x=0, z=0}) }
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local cur = makeCoord({x=-1852, z=926})
    local xte, side = M:_CalculateXte(prev, wp, cur)
    assertNear(xte, 1, 0.001)
    assertEq(side, "port")
  end)
  it("off-track starboard side", function()
    local prev = { coordinate = makeCoord({x=0, z=0}) }
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local cur = makeCoord({x=1852, z=926})
    local xte, side = M:_CalculateXte(prev, wp, cur)
    assertNear(xte, 1, 0.001)
    assertEq(side, "stbd")
  end)
  it("zero-length leg → nil", function()
    local prev = { coordinate = makeCoord({x=0, z=0}) }
    local wp = { coordinate = makeCoord({x=0, z=0}) }
    local xte = M:_CalculateXte(prev, wp, makeCoord({x=5,z=5}))
    assertNil(xte)
  end)
end)

suite("CalculateWindCorrectedGuidance", function()
  it("no TOT → track only", function()
    local start = makeCoord({x=0, z=0})
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local hdg, tas, ias = M:_CalculateWindCorrectedGuidance(start, wp, nil, 0)
    assertNear(hdg, 0, 0.01); assertNil(tas); assertNil(ias)
  end)
  it("no wind: TAS matches ground speed", function()
    local start = makeCoord({x=0, z=0})
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local hdg, tas = M:_CalculateWindCorrectedGuidance(start, wp, 3600, 0)
    assertNear(hdg, 0, 0.01)
    assertNear(tas, 1, 0.01)
  end)
  it("headwind increases required TAS", function()
    local start = makeCoord({x=0, z=0, wind = {x=0, y=0, z=-1}})
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local hdg, tas = M:_CalculateWindCorrectedGuidance(start, wp, 3600, 0)
    -- ground speed 1 kt = 0.514 m/s, headwind -1 m/s in z → air z = 1.514
    -- TAS = 1.514 / 0.514444 ≈ 2.94 kt
    assertNear(tas, 1.514 / 0.514444, 0.05)
    assertNear(hdg, 0, 0.5)
  end)
end)

suite("DiscoverZones (fake SET_ZONE)", function()
  local function withFakeZones(zones, fn)
    local original = SET_ZONE
    local fakeSet = {
      FilterPrefixes = function(self) return self end,
      FilterStart = function(self) return self end,
      ForEachZone = function(self, cb)
        for _, z in ipairs(zones) do cb(z) end
        return self
      end,
    }
    SET_ZONE = { New = function() return fakeSet end }
    local okCall, errCall = pcall(fn)
    SET_ZONE = original
    if not okCall then error(errCall, 2) end
  end

  local function fakeZone(name, x, z)
    return {
      GetName = function() return name end,
      GetCoordinate = function() return makeCoord({x=x or 0, z=z or 0}) end,
      GetRadius = function() return 100 end,
    }
  end

  it("groups waypoints by plan and sorts by order", function()
    withFakeZones({
      fakeZone("MN_JERICHO_03_INGRESS"),
      fakeZone("MN_JERICHO_01_TAKE_OFF"),
      fakeZone("MN_JERICHO_02_NAV"),
    }, function()
      local plans, beacons = M:_DiscoverZones()
      assertNotNil(plans["JERICHO"])
      assertEq(#plans["JERICHO"].waypoints, 3)
      assertEq(plans["JERICHO"].waypoints[1].order, 1)
      assertEq(plans["JERICHO"].waypoints[2].order, 2)
      assertEq(plans["JERICHO"].waypoints[3].order, 3)
      assertEq(#beacons, 0)
    end)
  end)

  it("collects beacons separately", function()
    withFakeZones({
      fakeZone("MNB_TANGMERE_310KHZ_120NM_200FT"),
      fakeZone("MNB_BAYEUX"),
    }, function()
      local _, beacons = M:_DiscoverZones()
      assertEq(#beacons, 2)
    end)
  end)

  it("multiple plans coexist", function()
    withFakeZones({
      fakeZone("MN_JERICHO_01_TAKE_OFF"),
      fakeZone("MN_ESCORT_01_TAKE_OFF"),
      fakeZone("MN_ESCORT_02_NAV"),
    }, function()
      local plans = M:_DiscoverZones()
      assertNotNil(plans["JERICHO"]); assertNotNil(plans["ESCORT"])
      assertEq(#plans["JERICHO"].waypoints, 1)
      assertEq(#plans["ESCORT"].waypoints, 2)
    end)
  end)
end)

suite("CSV field formatting", function()
  it("nil → empty", function()
    assertEq(M:_FormatCsvField(nil), "")
  end)
  it("plain value unchanged", function()
    assertEq(M:_FormatCsvField("JERICHO"), "JERICHO")
  end)
  it("number stringified", function()
    assertEq(M:_FormatCsvField(42), "42")
  end)
  it("comma triggers quoting", function()
    assertEq(M:_FormatCsvField("a,b"), "\"a,b\"")
  end)
  it("double quote doubled and wrapped", function()
    assertEq(M:_FormatCsvField('he said "hi"'), "\"he said \"\"hi\"\"\"")
  end)
  it("newline triggers quoting", function()
    assertEq(M:_FormatCsvField("a\nb"), "\"a\nb\"")
  end)
  it("carriage return triggers quoting", function()
    assertEq(M:_FormatCsvField("a\rb"), "\"a\rb\"")
  end)
end)

suite("CSV row formatting", function()
  it("joins escaped fields with commas", function()
    assertEq(M:_FormatCsvRow({"a", "b", 3}), "a,b,3")
  end)
  it("escapes fields containing commas", function()
    assertEq(M:_FormatCsvRow({"a,b", "c"}), "\"a,b\",c")
  end)
  it("empty string fields preserved", function()
    assertEq(M:_FormatCsvRow({"a", "", "c"}), "a,,c")
  end)
end)

suite("CSV coordinate formatting", function()
  it("positive lat/lon 6 dp", function()
    local coord = makeCoord({lat = 50.5, lon = -0.75})
    local lat, lon = M:_FormatCoordinateForCsvDD(coord)
    assertEq(lat, "50.500000")
    assertEq(lon, "-0.750000")
  end)
  it("negative lat", function()
    local coord = makeCoord({lat = -12.345678, lon = 100.123456})
    local lat, lon = M:_FormatCoordinateForCsvDD(coord)
    assertEq(lat, "-12.345678")
    assertEq(lon, "100.123456")
  end)
end)

suite("CSV TOT formatting", function()
  it("nil TOT → empty", function()
    assertEq(M:_FormatTotForCsv({}), "")
  end)
  it("HH:MM when seconds=0", function()
    assertEq(M:_FormatTotForCsv({timeOnTargetSeconds = 14 * 3600 + 30 * 60}), "14:30")
  end)
  it("rounds seconds to nearest minute", function()
    assertEq(M:_FormatTotForCsv({timeOnTargetSeconds = 14 * 3600 + 30 * 60 + 45}), "14:31")
  end)
  it("zero-pads single-digit hour", function()
    assertEq(M:_FormatTotForCsv({timeOnTargetSeconds = 5 * 3600}), "05:00")
  end)
end)

suite("Fuel profile interpolation", function()
  it("stores six engine settings", function()
    assertEq(#M.Aircraft.engineSettings, 6)
  end)
  it("stores takeoff/emergency +18 without fuel consumption", function()
    local s = M:_GetEngineSettingById("takeoff_emergency_18")
    assertNotNil(s)
    assertNil(s.fuelImpGph)
  end)
  it("stores takeoff +12 and cruise weak fuel values", function()
    assertEq(M:_GetEngineSettingById("takeoff_12").fuelImpGph, 230)
    assertEq(M:_GetEngineSettingById("cruise_weak").fuelImpGph, 84)
  end)
  it("uses four route fuel curve settings", function()
    local curve = M:_GetFuelCurveSettings()
    assertEq(#curve, 4)
    assertEq(curve[1].id, "cruise_weak")
    assertEq(curve[4].id, "max_climb")
  end)
  it("180 IAS uses cruise weak burn", function()
    local p = M:_EstimateFuelProfile(180, 0)
    assertEq(p.name, "CRZ")
    assertNear(p.burnImpGph, 84, 0.01)
  end)
  it("215 IAS uses max continuous weak burn", function()
    local p = M:_EstimateFuelProfile(215, 0)
    assertEq(p.name, "CRZ-MCW")
    assertNear(p.burnImpGph, 126, 0.01)
  end)
  it("227.5 IAS interpolates between weak and rich continuous", function()
    local p = M:_EstimateFuelProfile(227.5, 0)
    assertEq(p.name, "MCW-MCR")
    assertNear(p.burnImpGph, 143, 0.01)
  end)
  it("250 IAS interpolates between rich continuous and climb", function()
    local p = M:_EstimateFuelProfile(250, 0)
    assertEq(p.name, "MCR-CLB")
    assertNear(p.burnImpGph, 175, 0.01)
  end)
  it("below curve clamps to lowest documented burn", function()
    assertNear(M:_EstimateFuelProfile(140, 0).burnImpGph, 84, 0.01)
  end)
  it("above curve clamps to highest route burn", function()
    assertNear(M:_EstimateFuelProfile(280, 0).burnImpGph, 190, 0.01)
  end)
end)

-- ─── ComputePlan helpers ───────────────────────────────────────────────────

local NM = 1852  -- metres per NM

-- Builds a plan with coords laid out in a line along the z-axis.
-- Each entry: { zoneName, zMetres, [lat], [lon] }
-- Distances between consecutive WPs in NM = delta_z / 1852.
local function makePlan(entries)
  local wps = {}
  for _, e in ipairs(entries) do
    local wp = M:_ParseWaypointZoneName(e[1])
    assert(wp, "parse failed: " .. e[1])
    wp.coordinate = makeCoord({ x = 0, z = e[2] or 0, lat = e[3] or 50, lon = e[4] or 0 })
    wp.zone = { GetRadius = function() return 100 end }
    table.insert(wps, wp)
  end
  table.sort(wps, function(a,b) return a.order < b.order end)
  return { name = "TEST", waypoints = wps }
end

local function etaHHMM(sec)
  sec = sec % 86400
  return string.format("%02d:%02d", math.floor(sec/3600), math.floor((sec%3600)/60))
end

suite("ComputePlan — validation", function()
  it("error when no waypoints", function()
    local r = M:_ComputePlan({ name="X", waypoints={} }, 0)
    assertEq(r.valid, false)
    assertMatch(r.error, "no waypoints")
  end)

  it("error when first WP not TAKE_OFF", function()
    local plan = makePlan({
      { "MN_TEST_01_NAV__T12:00__S180", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, false)
    assertMatch(r.error, "TAKE_OFF")
  end)

  it("error when last WP not LANDING", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T12:00__S180", 0 },
      { "MN_TEST_02_NAV", NM * 20 },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, false)
    assertMatch(r.error, "LANDING")
  end)

  it("error when TAKE_OFF missing __T", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__S180", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, false)
    assertMatch(r.error, "__T")
  end)

  it("valid when TAKE_OFF missing __S uses 240 mph default cruise speed", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T12:00", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, true)
    assertNear(M.Aircraft.defaultCruiseSpeedKt, 208.554, 0.001)
    assertNear(r.waypoints[2].legGsKt, M.Aircraft.defaultCruiseSpeedKt, 0.01)
  end)

  it("valid when TAKE_OFF missing __S but has downstream __T pair", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T12:00", 0 },
      { "MN_TEST_02_TARGET__T12:10", NM * 20 },
      { "MN_TEST_03_LANDING", NM * 30 },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, true)
  end)
end)

suite("ComputePlan — Plan 1 BASIC (no __T in middle)", function()
  -- 20+30+25+45 = 120 NM at 200 kt GS → 36 min total
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*20 },
    { "MN_TEST_03_NAV",                          NM*50 },
    { "MN_TEST_04_TARGET",                       NM*75 },
    { "MN_TEST_05_LANDING",                      NM*120 },
  })

  it("returns valid", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, true)
    assertNil(r.error)
  end)

  it("ETA[1] = 12:00", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(etaHHMM(r.waypoints[1].etaSec), "12:00")
  end)

  it("ETA[2] = 12:06 (20 NM at 200 kt)", function()
    local r = M:_ComputePlan(plan, 0)
    -- 20/200 h = 0.1 h = 6 min. IAS→TAS conversion at 500 ft ISA gives
    -- TAS ≈ 201.5, so leg time is ~357.4 s (2.6 s under 360).
    assertNear(r.waypoints[2].etaSec, (12*3600 + 6*60), 5)
  end)

  it("all non-TAKEOFF legs have GS near 200 kt TAS", function()
    local r = M:_ComputePlan(plan, 0)
    for i = 2, #r.waypoints do
      local w = r.waypoints[i]
      assertNotNil(w.legGsKt, "legGsKt nil at WP" .. i)
      assertNear(w.legGsKt, M:_ConvertIasToTas(200, 500), 2)
    end
  end)

  it("TAKE_OFF has no leg data", function()
    local r = M:_ComputePlan(plan, 0)
    assertNil(r.waypoints[1].legGsKt)
    assertNil(r.waypoints[1].legDistNm)
  end)

  it("fuel summary present with positive margin", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.fuel.marginImpGal > 0, "expected positive fuel margin")
    assertTrue(r.fuel.totalImpGal > r.fuel.taxiImpGal, "total > taxi")
  end)

  it("no warnings", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(#r.warnings, 0)
  end)
end)

suite("ComputePlan — Plan 2 MID_TOT (constraint derived speed)", function()
  -- 75 NM total, __T12:20 on TARGET → 20 min → required 225 kt GS
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*20 },
    { "MN_TEST_03_NAV",                          NM*50 },
    { "MN_TEST_04_TARGET__T12:20",               NM*75 },
    { "MN_TEST_05_LANDING",                      NM*120 },
  })

  it("segment [TAKE_OFF..TARGET] ETA hits constraint", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid)
    -- TARGET should be at or very close to 12:20
    assertNear(r.waypoints[4].etaSec, 12*3600 + 20*60, 2)
  end)

  it("post-constraint leg reverts to default __S200", function()
    local r = M:_ComputePlan(plan, 0)
    -- leg to LANDING: default 200 kt (as IAS→TAS at 500ft)
    local expectedGs = M:_ConvertIasToTas(200, 500)
    assertNear(r.waypoints[5].legGsKt, expectedGs, 2)
  end)
end)

suite("ComputePlan — Plan 5 MIXED_S (FIXED honored, FREE averaged)", function()
  -- Segment [TAKE_OFF..TARGET] 50 NM in 15 min
  -- WP3 INGRESS: FIXED __S220 (dist 10 NM from prev)
  -- WP2 NAV and WP4 TARGET: FREE
  -- FIXED leg (→WP3): 10 NM at 220 kt TAS = ~2.73 min
  -- FREE legs (→WP2 20NM and →WP4 20NM) share remaining ~12.27 min
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV__A500",                    NM*20 },
    { "MN_TEST_03_INGRESS__S220__A200",           NM*30 },
    { "MN_TEST_04_TARGET__A200__T12:15",         NM*50 },
    { "MN_TEST_05_LANDING",                      NM*95 },
  })

  it("FIXED leg at WP3 uses __S220 GS", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    local expectedGs = M:_ConvertIasToTas(220, 200)
    assertNear(r.waypoints[3].legGsKt, expectedGs, 2)
  end)

  it("TARGET ETA hits __T12:15", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[4].etaSec, 12*3600 + 15*60, 5)
  end)

  it("no warnings for valid mixed segment", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(#r.warnings, 0)
  end)
end)

suite("ComputePlan — Plan 6 ALL_S_OVERRIDDEN", function()
  -- All legs in segment are FIXED but __T wins
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV__S180",                    NM*20 },
    { "MN_TEST_03_INGRESS__S220__A200",           NM*30 },
    { "MN_TEST_04_TARGET__S200__A200__T12:15",   NM*50 },
    { "MN_TEST_05_LANDING",                      NM*95 },
  })

  it("TARGET ETA hits __T12:15", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertNear(r.waypoints[4].etaSec, 12*3600 + 15*60, 5)
  end)

  it("all segment legs get same GS (uniform derived)", function()
    local r = M:_ComputePlan(plan, 0)
    local gs2 = r.waypoints[2].legGsKt
    local gs3 = r.waypoints[3].legGsKt
    local gs4 = r.waypoints[4].legGsKt
    assertNear(gs2, gs3, 0.5)
    assertNear(gs3, gs4, 0.5)
  end)

  it("emits warning that __S ignored in all-FIXED segment", function()
    local r = M:_ComputePlan(plan, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "all%-FIXED") or string.find(w, "ignored") then
        found = true; break
      end
    end
    assertTrue(found, "expected all-FIXED warning, got: " .. table.concat(r.warnings, "; "))
  end)
end)

suite("ComputePlan — Plan 3 HOLD_ANCHOR (__T on HOLD = arrival)", function()
  -- TAKE_OFF 12:00, fly 50 NM to HOLD at 12:15, then 20 NM to TARGET at 12:30
  -- HOLD arrival = 12:15 (from __T), exit computed from TARGET 12:30 minus flight 20NM/200kt = 6min → hold = 9min
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*30 },
    { "MN_TEST_03_HOLD__T12:15",                 NM*50 },
    { "MN_TEST_04_NAV",                          NM*65 },
    { "MN_TEST_05_TARGET__T12:30",               NM*70 },
    { "MN_TEST_06_LANDING",                      NM*120 },
  })

  it("HOLD ETA = arrival 12:15 (from __T)", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertNear(r.waypoints[3].etaSec, 12*3600 + 15*60, 5)
  end)

  it("HOLD duration positive", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue((r.waypoints[3].holdDurationSec or 0) > 0,
      "expected hold duration > 0, got " .. tostring(r.waypoints[3].holdDurationSec))
  end)

  it("TARGET ETA hits 12:30", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[5].etaSec, 12*3600 + 30*60, 5)
  end)
end)

suite("ComputePlan — Plan 4 HOLD_ABSORB (no __T on HOLD)", function()
  -- 50 NM at 200 kt = 15 min → arrive HOLD 12:15; TARGET at 12:30; flight HOLD→TARGET 20NM = 6min
  -- hold = 30 - 15 - 6 = 9 min
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*30 },
    { "MN_TEST_03_HOLD",                         NM*50 },
    { "MN_TEST_04_TARGET__T12:30",               NM*70 },
    { "MN_TEST_05_LANDING",                      NM*120 },
  })

  it("HOLD absorbs slack", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertTrue((r.waypoints[3].holdDurationSec or 0) > 0,
      "hold should absorb slack, got " .. tostring(r.waypoints[3].holdDurationSec))
  end)

  it("TARGET ETA hits 12:30", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[4].etaSec, 12*3600 + 30*60, 5)
  end)

  it("no warnings", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(#r.warnings, 0)
  end)
end)

suite("ComputePlan — Plan 7 MULTI_HOLD (last HOLD absorbs)", function()
  -- H1 (no __T) then H2 (no __T), TARGET at 12:35
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD",                         NM*15 },
    { "MN_TEST_03_NAV",                          NM*35 },
    { "MN_TEST_04_HOLD",                         NM*60 },
    { "MN_TEST_05_TARGET__T12:35",               NM*70 },
    { "MN_TEST_06_LANDING",                      NM*120 },
  })

  it("H1 gets duration 0 + warning", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertEq(r.waypoints[2].holdDurationSec, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "not last") then found = true; break end
    end
    assertTrue(found, "expected 'not last' warning")
  end)

  it("H2 absorbs remaining slack", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue((r.waypoints[4].holdDurationSec or 0) > 0,
      "H2 should absorb slack, got " .. tostring(r.waypoints[4].holdDurationSec))
  end)

  it("TARGET ETA hits 12:35", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[5].etaSec, 12*3600 + 35*60, 5)
  end)
end)

suite("ComputePlan — HOLD without downstream __T", function()
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD",                         NM*15 },
    { "MN_TEST_03_LANDING",                      NM*50 },
  })

  it("HOLD duration = 0 and warning emitted", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertEq(r.waypoints[2].holdDurationSec, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "no downstream") or string.find(w, "duration 0") then
        found = true; break
      end
    end
    assertTrue(found, "expected warning, got: " .. table.concat(r.warnings, "; "))
  end)
end)

suite("ComputePlan — __S override on individual WP", function()
  -- WP3 NAV has __S140; others default 200
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*20 },
    { "MN_TEST_03_NAV__S140",                    NM*30 },
    { "MN_TEST_04_LANDING",                      NM*60 },
  })

  it("WP3 leg uses __S140 GS", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    local expectedGs = M:_ConvertIasToTas(140, 500)
    assertNear(r.waypoints[3].legGsKt, expectedGs, 2)
  end)

  it("WP4 leg reverts to default 200 GS", function()
    local r = M:_ComputePlan(plan, 0)
    local expectedGs = M:_ConvertIasToTas(200, 500)
    assertNear(r.waypoints[4].legGsKt, expectedGs, 2)
  end)
end)

suite("ComputePlan — ROLEX shift", function()
  -- 60 NM in 20 min = 180 kt required, feasible in envelope [165..260].
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_TARGET__T12:20",               NM*60 },
    { "MN_TEST_03_LANDING",                      NM*100 },
  })

  it("ROLEX shifts ETA[1] by 5 min", function()
    local r = M:_ComputePlan(plan, 5*60)
    assertNear(r.waypoints[1].etaSec, 12*3600 + 5*60, 2)
  end)

  it("ROLEX shifts TARGET ETA too", function()
    local r = M:_ComputePlan(plan, 5*60)
    assertNear(r.waypoints[2].etaSec, 12*3600 + 25*60, 5)
  end)
end)

suite("ComputePlan — altitude cascade", function()
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A5000", 0 },
    { "MN_TEST_02_NAV",                           NM*20 },
    { "MN_TEST_03_INGRESS__A50",                  NM*40 },
    { "MN_TEST_04_TARGET",                        NM*60 },
    { "MN_TEST_05_LANDING__A200",                 NM*100 },
  })

  it("WP2 inherits 5000 ft from TAKE_OFF", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertEq(r.waypoints[2].resolvedAltFt, 5000)
    assertEq(r.waypoints[2].altInherited, true)
  end)

  it("WP3 uses own __A50", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.waypoints[3].resolvedAltFt, 50)
    assertEq(r.waypoints[3].altInherited, false)
  end)

  it("WP4 inherits 50 ft from WP3", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.waypoints[4].resolvedAltFt, 50)
    assertEq(r.waypoints[4].altInherited, true)
  end)

  it("WP5 uses own __A200", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.waypoints[5].resolvedAltFt, 200)
    assertEq(r.waypoints[5].altInherited, false)
  end)
end)

suite("ComputePlan — no __A anywhere defaults to 0 ft + warning", function()
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200", 0 },
    { "MN_TEST_02_LANDING",                NM*50 },
  })

  it("resolvedAltFt = 0 and warning emitted", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertEq(r.waypoints[2].resolvedAltFt, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "__A") or string.find(w, "0 ft") then
        found = true; break
      end
    end
    assertTrue(found, "expected altitude warning, got: " .. table.concat(r.warnings, "; "))
  end)
end)

suite("ComputePlan — Plan 8 ENVELOPE_CLAMP", function()
  -- 25 NM in 3 min → 500 kt required → clamped
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*15 },
    { "MN_TEST_03_TARGET__T12:03",               NM*25 },
    { "MN_TEST_04_LANDING",                      NM*75 },
  })

  it("emits clamp warning", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "clamped") or string.find(w, "IAS") then
        found = true; break
      end
    end
    assertTrue(found, "expected clamp warning, got: " .. table.concat(r.warnings, "; "))
  end)

  it("GS does not exceed envelope-derived max", function()
    local r = M:_ComputePlan(plan, 0)
    local maxGs = M:_ConvertIasToTas(M.Aircraft.envelope.maxIasKt, 500)
    for i = 2, #r.waypoints do
      if r.waypoints[i].legGsKt then
        assertTrue(r.waypoints[i].legGsKt <= maxGs + 1,
          "GS exceeds envelope at WP" .. i)
      end
    end
  end)
end)

suite("ComputePlan — fuel calculation", function()
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_LANDING",                      NM*60 },
  })

  it("taxi allowance in total", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.fuel.taxiImpGal, M.Aircraft.fuel.taxiAllowance)
  end)

  it("landing allowance in total", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.fuel.landingImpGal, M.Aircraft.fuel.landingAllowance)
  end)

  it("total = taxi + route + reserve + landing", function()
    local r = M:_ComputePlan(plan, 0)
    local expected = r.fuel.taxiImpGal + r.fuel.routeImpGal
                   + r.fuel.reserveImpGal + r.fuel.landingImpGal
    assertNear(r.fuel.totalImpGal, expected, 0.01)
  end)

  it("reserve uses 30 minutes at cruise weak burn", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.fuel.reserveImpGal, 42, 0.01)
  end)

  it("margin = tank - total", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.fuel.marginImpGal, r.fuel.tankImpGal - r.fuel.totalImpGal, 0.01)
  end)

  it("tank capacity matches recommended DCS configuration", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.fuel.tankImpGal, r.fuel.dcs.capacityGal, 0.01)
  end)

  it("DCS fuel conversion matches 200 gal = 1443 lbs", function()
    assertNear(M:_FuelGalToLb(200), 1443, 0.01)
  end)

  it("DCS internal fuel capacity comes from 3269 lbs", function()
    assertNear(M:_FuelLbToGal(3269), 453.1, 0.1)
  end)

  it("DCS short plan uses internal percent with +1 percent buffer", function()
    local dcs = M:_BuildDcsFuelRecommendation(93.6)
    assertEq(dcs.dropTankLabel, "NONE")
    assertEq(dcs.internalPercent, 22)
  end)

  it("DCS recommendation uses 2x50 tanks above internal capacity", function()
    local internal = M:_FuelLbToGal(M.Aircraft.fuel.internalFuelLb)
    local dcs = M:_BuildDcsFuelRecommendation(internal + 50)
    assertEq(dcs.internalPercent, 100)
    assertEq(dcs.dropTankLabel, "2x50 GAL")
  end)

  it("DCS recommendation uses 2x100 tanks above internal plus 2x50 capacity", function()
    local internal = M:_FuelLbToGal(M.Aircraft.fuel.internalFuelLb)
    local dcs = M:_BuildDcsFuelRecommendation(internal + 150)
    assertEq(dcs.internalPercent, 100)
    assertEq(dcs.dropTankLabel, "2x100 GAL")
  end)

  it("DCS recommendation flags fuel above internal plus 2x100 capacity", function()
    local internal = M:_FuelLbToGal(M.Aircraft.fuel.internalFuelLb)
    local dcs = M:_BuildDcsFuelRecommendation(internal + 250)
    assertEq(dcs.dropTankLabel, "2x100 GAL")
    assertEq(dcs.exceedsCapacity, true)
  end)

  it("HOLD orbit burn uses cruise weak documented burn", function()
    assertEq(M.Aircraft.holdBurnImpGph, 84)
  end)
end)

-- ─── HOLD semantics: __T on HOLD is arrival-only; last HOLD absorbs ───────

suite("ComputePlan — HOLD then HOLD(__T) then TARGET(__T)", function()
  -- Both HOLDs are "last" before their own downstream __T anchor
  -- (HOLD1 → HOLD2's __T anchor; HOLD2 → TARGET's __T anchor), so both absorb.
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD",                          NM*20 },
    { "MN_TEST_03_HOLD__T12:20",                  NM*40 },
    { "MN_TEST_04_TARGET__T12:30",                NM*60 },
    { "MN_TEST_05_LANDING",                       NM*120 },
  })

  it("HOLD1 (no __T) absorbs slack to HOLD2(__T)", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertTrue((r.waypoints[2].holdDurationSec or 0) > 0,
      "expected HOLD1 duration > 0, got " .. tostring(r.waypoints[2].holdDurationSec))
  end)

  it("HOLD2 arrival = 12:20 (snap __T)", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[3].etaSec, 12*3600 + 20*60, 5)
  end)

  it("HOLD2 (__T) also absorbs slack to TARGET(__T)", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue((r.waypoints[3].holdDurationSec or 0) > 0,
      "expected HOLD2 duration > 0, got " .. tostring(r.waypoints[3].holdDurationSec))
  end)

  it("TARGET ETA = 12:30", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[4].etaSec, 12*3600 + 30*60, 5)
  end)

  it("no warnings for feasible plan", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(#r.warnings, 0,
      "expected no warnings, got: " .. table.concat(r.warnings, "; "))
  end)
end)

suite("ComputePlan — HOLD(__T) then HOLD (no __T) then TARGET(__T)", function()
  -- HOLD1 has __T but a LATER HOLD sits before the same TARGET anchor.
  -- lastHoldBeforeAnchor[TARGET] = HOLD2 → HOLD1 gets 0, HOLD2 absorbs.
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD__T12:15",                  NM*30 },
    { "MN_TEST_03_NAV",                           NM*40 },
    { "MN_TEST_04_HOLD",                          NM*55 },
    { "MN_TEST_05_TARGET__T12:40",                NM*75 },
    { "MN_TEST_06_LANDING",                       NM*130 },
  })

  it("HOLD1 (__T) duration = 0 + 'not last' warning", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertEq(r.waypoints[2].holdDurationSec, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "not last") then found = true; break end
    end
    assertTrue(found, "expected 'not last' warning, got: " .. table.concat(r.warnings, "; "))
  end)

  it("HOLD1 arrival = 12:15 (snap __T)", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[2].etaSec, 12*3600 + 15*60, 2)
  end)

  it("HOLD2 (no __T) absorbs slack to TARGET", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue((r.waypoints[4].holdDurationSec or 0) > 0,
      "expected HOLD2 duration > 0, got " .. tostring(r.waypoints[4].holdDurationSec))
  end)

  it("TARGET ETA ≈ 12:40", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[5].etaSec, 12*3600 + 40*60, 10)
  end)
end)

suite("ComputePlan — HOLD(__T) then HOLD(__T) then TARGET(__T)", function()
  -- Each HOLD's downstream anchor is the next __T (which is the other HOLD or TARGET).
  -- Both are "last before their own downstream" and both absorb.
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD__T12:10",                  NM*20 },
    { "MN_TEST_03_HOLD__T12:20",                  NM*40 },
    { "MN_TEST_04_TARGET__T12:30",                NM*60 },
    { "MN_TEST_05_LANDING",                       NM*120 },
  })

  it("HOLD1 arrival = 12:10 and duration > 0", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertNear(r.waypoints[2].etaSec, 12*3600 + 10*60, 2)
    assertTrue((r.waypoints[2].holdDurationSec or 0) > 0,
      "expected HOLD1 duration > 0")
  end)

  it("HOLD2 arrival = 12:20 and duration > 0", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[3].etaSec, 12*3600 + 20*60, 2)
    assertTrue((r.waypoints[3].holdDurationSec or 0) > 0,
      "expected HOLD2 duration > 0")
  end)

  it("TARGET ETA = 12:30", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[4].etaSec, 12*3600 + 30*60, 5)
  end)

  it("no warnings", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(#r.warnings, 0,
      "expected no warnings, got: " .. table.concat(r.warnings, "; "))
  end)
end)

suite("ComputePlan — HOLD(__T) with no downstream __T", function()
  -- HOLD has __T (arrival pinned) but there is no downstream __T at all.
  -- Under new contract: duration 0 + 'no downstream __T' warning.
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD__T12:15",                  NM*30 },
    { "MN_TEST_03_LANDING",                       NM*80 },
  })

  it("HOLD duration = 0 with warning", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertEq(r.waypoints[2].holdDurationSec, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "no downstream") then found = true; break end
    end
    assertTrue(found, "expected 'no downstream' warning, got: " .. table.concat(r.warnings, "; "))
  end)

  it("HOLD arrival = 12:15 (snap __T)", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[2].etaSec, 12*3600 + 15*60, 2)
  end)
end)

suite("ComputePlan — multi-HOLD with local __S (feasible)", function()
  -- Feasible variant: HOLD1 uses local __S400 for arrival, HOLD2 has own __T,
  -- TARGET has local __S300 and __T15:00, LANDING has __T15:20.
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD__S400",                    NM*100 },
    { "MN_TEST_03_HOLD__T14:00",                  NM*200 },
    { "MN_TEST_04_TARGET__S300__T15:00",          NM*400 },
    { "MN_TEST_05_LANDING__T15:20",               NM*460 },
  })

  it("HOLD1 absorbs slack to HOLD2 (__T14:00)", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertTrue((r.waypoints[2].holdDurationSec or 0) > 0,
      "expected HOLD1 duration > 0")
  end)

  it("HOLD2 arrival = 14:00 and absorbs slack to TARGET (__T15:00)", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[3].etaSec, 14*3600, 5)
    assertTrue((r.waypoints[3].holdDurationSec or 0) > 0,
      "expected HOLD2 duration > 0")
  end)

  it("Leg to HOLD1 uses declared __S400 (not clamped in HOLD segment)", function()
    local r = M:_ComputePlan(plan, 0)
    local expectedGs = M:_ConvertIasToTas(400, 500)
    assertNear(r.waypoints[2].legGsKt, expectedGs, 2)
  end)

  it("Leg to TARGET uses declared __S300", function()
    local r = M:_ComputePlan(plan, 0)
    local expectedGs = M:_ConvertIasToTas(300, 500)
    assertNear(r.waypoints[4].legGsKt, expectedGs, 2)
  end)

  it("TARGET ETA = 15:00, LANDING ETA = 15:20", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[4].etaSec, 15*3600, 5)
    assertNear(r.waypoints[5].etaSec, 15*3600 + 20*60, 10)
  end)
end)

suite("ComputePlan — multi-HOLD with local __S (infeasible slack)", function()
  -- Exact scenario from user: TARGET __T14:30 too tight for 200 NM at declared 300 kt
  -- from HOLD2 arriving at 14:00 (needs 40 min, only 30 min available).
  -- HOLD2 duration = 0 + negative-slack warning; TARGET and LANDING drift past their __T.
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_HOLD__S400",                    NM*100 },
    { "MN_TEST_03_HOLD__T14:00",                  NM*200 },
    { "MN_TEST_04_TARGET__S300__T14:30",          NM*400 },
    { "MN_TEST_05_LANDING__T14:45",               NM*500 },
  })

  it("valid despite infeasible constraints", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
  end)

  it("HOLD1 still absorbs slack to HOLD2", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue((r.waypoints[2].holdDurationSec or 0) > 0,
      "expected HOLD1 duration > 0")
  end)

  it("HOLD2 duration = 0 with negative-slack warning", function()
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.waypoints[3].holdDurationSec, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "negative slack") then found = true; break end
    end
    assertTrue(found, "expected 'negative slack' warning, got: " .. table.concat(r.warnings, "; "))
  end)

  it("TARGET ETA drifts past __T14:30", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.waypoints[4].etaSec > 14*3600 + 30*60,
      "expected TARGET drift past 14:30, got " .. tostring(r.waypoints[4].etaSec))
  end)

  it("LANDING ETA drifts past __T14:45", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.waypoints[5].etaSec > 14*3600 + 45*60,
      "expected LANDING drift past 14:45, got " .. tostring(r.waypoints[5].etaSec))
  end)
end)

local function makeWaypointFromZone(zoneName, coordOpts)
  local wp = M:_ParseWaypointZoneName(zoneName)
  assertNotNil(wp, "parse failed for " .. zoneName)
  wp.coordinate = makeCoord(coordOpts or {lat = 50.0, lon = -0.5})
  return wp
end

local function makeBeaconFromZone(zoneName, coordOpts)
  local b = M:_ParseBeaconZoneName(zoneName)
  assertNotNil(b, "parse failed for " .. zoneName)
  b.coordinate = makeCoord(coordOpts or {lat = 50.0, lon = -0.5})
  return b
end

local function splitLines(text)
  local lines = {}
  for line in string.gmatch(text, "([^\n]*)\n") do
    table.insert(lines, line)
  end
  return lines
end

suite("Build flight plan messages", function()
  it("F10 flight plan uses operational heading and speed columns", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_NAV", NM * 20 },
      { "MN_TEST_03_LANDING", NM * 40 },
    })
    local msg = M:_BuildSimplifiedFlightPlanMessage(plan, "GRP", 0)
    assertMatch(msg, "ID%s+TYPE%s+ALT%s+IAS%(MPH%)%s+TAS%(KN%)%s+COG%s+HDG%(TRUE%)%s+VAR%s+HDG%(MAG%)%s+SOG%s+DIST%s+TIME%s+ETA")
    assertMatch(msg, "01 TAKE_OFF%s+1500%s+[^\n]*07:00")
    assertMatch(msg, "02 NAV%s+1500%*%s+253%*%s+225%s+000%s+000%s+%-0%.0%s+000%s+225%s+20%.0%s+5%s+07:05")
    assertMatch(msg, "03 LANDING%s+1500%*%s+253%*%s+225%s+000%s+000%s+%-0%.0%s+000%s+225%s+20%.0%s+5%s+07:11")
  end)

  it("F10 flight plan includes multi-line fuel summary", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local msg = M:_BuildSimplifiedFlightPlanMessage(plan, "GRP", 0)
    assertMatch(msg, "FUEL:\n  TAXI:%s+15%.0 IMP GAL")
    assertMatch(msg, "\n  ROUTE:%s+%d+%.%d IMP GAL")
    assertMatch(msg, "\n  RESERVE:%s+%d+%.%d IMP GAL%s+%(30 min%)")
    assertMatch(msg, "\n  LANDING:%s+5%.0 IMP GAL")
    assertMatch(msg, "\n  TOTAL:%s+%d+%.%d IMP GAL")
    assertMatch(msg, "DCS FUEL:")
    assertMatch(msg, "\n  REQUIRED:%s+%d+%.%d GAL /%s+%d+ LBS")
    assertMatch(msg, "\n  INTERNAL:%s+%d+%%%s+%(3269 LBS max%)")
    assertMatch(msg, "\n  DROP:%s+NONE")
    assertTrue(not string.find(msg, "CAPACITY", 1, true), "DCS FUEL should not display capacity")
    assertTrue(not string.find(msg, "MARGIN", 1, true), "DCS FUEL should not display margin")
  end)

  it("TXT navlog includes DCS fuel recommendation", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local text = M:_BuildFlightPlanTable(plan, nil, 0)
    assertMatch(text, "DCS FUEL:")
    assertMatch(text, "INTERNAL:%s+%d+%%")
    assertMatch(text, "DROP:%s+NONE")
    assertTrue(not string.find(text, "CAPACITY", 1, true), "DCS FUEL should not display capacity")
    assertTrue(not string.find(text, "MARGIN", 1, true), "DCS FUEL should not display margin")
  end)

  it("TXT navlog ETA column uses minute-rounded display ETA without shifting COG", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_NAV", NM * 20 },
      { "MN_TEST_03_LANDING", NM * 40 },
    })
    local lines = splitLines(M:_BuildFlightPlanTable(plan, nil, 0))
    local header, row
    for _, line in ipairs(lines) do
      if string.find(line, "HDG(TRUE)", 1, true) then header = line end
      if string.find(line, "02 NAV", 1, true) then row = line end
    end
    assertNotNil(header)
    assertNotNil(row)
    assertNotNil(string.find(header, "COG%s+HDG%(TRUE%)%s+VAR%s+HDG%(MAG%)"))
    assertNotNil(string.find(row, "000%s+000%s+%-0%.0%s+000%s+225%s+20%.0%s+5%s+07:05"))
  end)

  it("TXT navlog marks inherited ALT and IAS with star", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_NAV", NM * 20 },
      { "MN_TEST_03_LANDING__S200", NM * 40 },
    })
    local text = M:_BuildFlightPlanTable(plan, nil, 0)
    assertMatch(text, "02 NAV%s+1500%*%s+253%*")
    assertMatch(text, "03 LANDING%s+1500%*%s+230%s")
  end)
end)

suite("Build flight plan CSV", function()
  it("headers and declared rows for plan", function()
    local plan = makePlan({
      { "MN_JERICHO_01_TAKE_OFF_Tangmere__T07:00__S220__A1500", 0, 50.85, -0.7 },
      { "MN_JERICHO_02_NAV", NM * 20, 50.9, -0.65 },
      { "MN_JERICHO_03_LANDING", NM * 40, 50.95, -0.6 },
    })
    plan.name = "JERICHO"
    local csv = M:_BuildFlightPlanCsv(plan, nil, 0)
    local lines = splitLines(csv)
    assertEq(lines[1], "# PLAN,JERICHO")
    assertEq(lines[2], "ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT")
    assertEq(lines[3], "1,TAKE_OFF,Tangmere,50.850000,-0.700000,1500,07:00,220")
    assertEq(lines[4], "2,NAV,,50.900000,-0.650000,,,")
  end)

  it("GROUP and ROLEX headers are not included", function()
    local plan = makePlan({
      { "MN_JERICHO_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_JERICHO_02_LANDING", NM * 20 },
    })
    plan.name = "JERICHO"
    local csv = M:_BuildFlightPlanCsv(plan, "MOSQUITO 1-1", 300)
    local lines = splitLines(csv)
    assertEq(lines[1], "# PLAN,JERICHO")
    assertEq(lines[2], "ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT")
    assertTrue(not string.find(csv, "GROUP"), "CSV should not include group headers")
    assertTrue(not string.find(csv, "ROLEX_SEC"), "CSV should not include ROLEX headers")
  end)

  it("empty NAME for zones with no explicit name", function()
    local plan = makePlan({
      { "MN_JERICHO_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_JERICHO_02_NAV", NM * 20 },
      { "MN_JERICHO_03_LANDING", NM * 40 },
    })
    plan.name = "JERICHO"
    local csv = M:_BuildFlightPlanCsv(plan, nil, 0)
    local lines = splitLines(csv)
    assertMatch(lines[4], "^2,NAV,,")  -- NAME empty, then coords, ALT, TOT, SPEED_KT all follow
  end)

  it("explicit NAME preserved", function()
    local plan = makePlan({
      { "MN_JERICHO_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_JERICHO_02_NAV_Checkpoint", NM * 20 },
      { "MN_JERICHO_03_LANDING", NM * 40 },
    })
    plan.name = "JERICHO"
    local csv = M:_BuildFlightPlanCsv(plan, nil, 0)
    local lines = splitLines(csv)
    assertMatch(lines[4], "^2,NAV,Checkpoint,")
  end)

  it("only declared altitude, TOT, and SPEED_KT are exported", function()
    local plan = makePlan({
      { "MN_JERICHO_01_TAKE_OFF__A1500__T07:00__S220", 0 },
      { "MN_JERICHO_02_NAV__A500__S200", NM * 20 },
      { "MN_JERICHO_03_TARGET__T07:30", NM * 30 },
      { "MN_JERICHO_04_LANDING", NM * 40 },
    })
    plan.name = "JERICHO"
    local csv = M:_BuildFlightPlanCsv(plan, nil, 0)
    local lines = splitLines(csv)
    assertMatch(lines[4], "^2,NAV,,[^,]+,[^,]+,500,,200$")
    assertMatch(lines[5], "^3,TARGET,,[^,]+,[^,]+,,07:30,$")
    assertMatch(lines[6], "^4,LANDING,,[^,]+,[^,]+,,,$")
  end)

  it("row count matches waypoint count", function()
    local plan = makePlan({
      { "MN_JERICHO_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_JERICHO_02_NAV", NM * 20 },
      { "MN_JERICHO_03_LANDING", NM * 40 },
    })
    plan.name = "JERICHO"
    local csv = M:_BuildFlightPlanCsv(plan, nil, 0)
    local lines = splitLines(csv)
    -- 1 PLAN header + 1 column header + 3 waypoint rows
    assertEq(#lines, 5)
  end)

  it("CSV exports declared rows without navlog validation", function()
    local plan = makePlan({
      { "MN_JERICHO_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_JERICHO_02_NAV", NM * 20 },
    })
    plan.name = "JERICHO"
    local csv = M:_BuildFlightPlanCsv(plan, nil, 0)
    local lines = splitLines(csv)
    assertEq(#lines, 4)
    assertTrue(not string.find(csv, "# ERROR", 1, true), "CSV declaration export should not emit compute errors")
  end)
end)

suite("Build beacons CSV", function()
  it("full beacon emits all fields", function()
    local beacons = {makeBeaconFromZone("MNB_TANGMERE_310KHZ_120NM_200FT", {lat = 50.85, lon = -0.7})}
    local csv = M:_BuildBeaconsCsv(beacons)
    local lines = splitLines(csv)
    assertEq(lines[1], "ID,FREQUENCY,POWER_NM,ALT_FT,LAT,LON")
    assertEq(lines[2], "TANGMERE,310KHZ,120,200,50.850000,-0.700000")
  end)

  it("minimal beacon uses defaults and empty frequency", function()
    local beacons = {makeBeaconFromZone("MNB_BAYEUX", {lat = 49.27, lon = -0.7})}
    local csv = M:_BuildBeaconsCsv(beacons)
    local lines = splitLines(csv)
    assertEq(lines[2], "BAYEUX,,60,0,49.270000,-0.700000")
  end)

  it("multiple beacons", function()
    local beacons = {
      makeBeaconFromZone("MNB_TANGMERE_310KHZ_120NM_200FT"),
      makeBeaconFromZone("MNB_BAYEUX"),
    }
    local csv = M:_BuildBeaconsCsv(beacons)
    local lines = splitLines(csv)
    assertEq(#lines, 3)
  end)

  it("empty beacon list yields header only", function()
    local csv = M:_BuildBeaconsCsv({})
    local lines = splitLines(csv)
    assertEq(#lines, 1)
    assertEq(lines[1], "ID,FREQUENCY,POWER_NM,ALT_FT,LAT,LON")
  end)
end)

suite("WriteFlightPlanFiles flag interaction", function()
  local function withSpies(opts, fn)
    local originalTxt = M._WriteFlightPlanFile
    local originalCsv = M._WriteFlightPlanCsvFile
    local originalDiscover = M._DiscoverGroupAssignments
    local originalTxtFlag = M.Config.generateFlightPlanFiles
    local originalCsvFlag = M.Config.generateCsvFiles

    local txtCalls = {}
    local csvCalls = {}

    M._WriteFlightPlanFile = function(self, plan, groupName, rolexSeconds)
      table.insert(txtCalls, {plan = plan and plan.name, groupName = groupName, rolexSeconds = rolexSeconds})
    end
    M._WriteFlightPlanCsvFile = function(self, plan, groupName, rolexSeconds)
      table.insert(csvCalls, {plan = plan and plan.name, groupName = groupName, rolexSeconds = rolexSeconds})
    end
    M._DiscoverGroupAssignments = function() return opts.assignments or {} end
    M.Config.generateFlightPlanFiles = opts.txt
    M.Config.generateCsvFiles = opts.csv

    local ok, err = pcall(fn, txtCalls, csvCalls)

    M._WriteFlightPlanFile = originalTxt
    M._WriteFlightPlanCsvFile = originalCsv
    M._DiscoverGroupAssignments = originalDiscover
    M.Config.generateFlightPlanFiles = originalTxtFlag
    M.Config.generateCsvFiles = originalCsvFlag

    if not ok then error(err, 2) end
  end

  local samplePlan = {name = "JERICHO", waypoints = {}}
  local samplePlans = {JERICHO = samplePlan}
  local sampleAssignment = {plan = samplePlan, groupName = "MOSQUITO 1-1", rolexSeconds = 300}

  it("calls both writers when both flags enabled and assignments exist", function()
    withSpies({txt = true, csv = true, assignments = {sampleAssignment}}, function(txtCalls, csvCalls)
      M:_WriteFlightPlanFiles(samplePlans)
      assertEq(#txtCalls, 1)
      assertEq(#csvCalls, 1)
      assertEq(txtCalls[1].groupName, "MOSQUITO 1-1")
      assertNil(csvCalls[1].groupName)
      assertNil(csvCalls[1].rolexSeconds)
    end)
  end)

  it("only TXT writer called when only txt flag enabled", function()
    withSpies({txt = true, csv = false, assignments = {sampleAssignment}}, function(txtCalls, csvCalls)
      M:_WriteFlightPlanFiles(samplePlans)
      assertEq(#txtCalls, 1)
      assertEq(#csvCalls, 0)
    end)
  end)

  it("only CSV writer called when only csv flag enabled", function()
    withSpies({txt = false, csv = true, assignments = {sampleAssignment}}, function(txtCalls, csvCalls)
      M:_WriteFlightPlanFiles(samplePlans)
      assertEq(#txtCalls, 0)
      assertEq(#csvCalls, 1)
      assertEq(csvCalls[1].plan, "JERICHO")
      assertNil(csvCalls[1].groupName)
    end)
  end)

  it("CSV writer is called once per plan, not per assigned group", function()
    local secondAssignment = {plan = samplePlan, groupName = "MOSQUITO 1-2", rolexSeconds = 600}
    withSpies({txt = true, csv = true, assignments = {sampleAssignment, secondAssignment}}, function(txtCalls, csvCalls)
      M:_WriteFlightPlanFiles(samplePlans)
      assertEq(#txtCalls, 2)
      assertEq(#csvCalls, 1)
      assertEq(csvCalls[1].plan, "JERICHO")
      assertNil(csvCalls[1].groupName)
    end)
  end)

  it("returns early when both flags disabled", function()
    withSpies({txt = false, csv = false, assignments = {sampleAssignment}}, function(txtCalls, csvCalls)
      M:_WriteFlightPlanFiles(samplePlans)
      assertEq(#txtCalls, 0)
      assertEq(#csvCalls, 0)
    end)
  end)

  it("fallback branch writes per plan without groupName when no assignments", function()
    withSpies({txt = true, csv = true, assignments = {}}, function(txtCalls, csvCalls)
      M:_WriteFlightPlanFiles(samplePlans)
      assertEq(#txtCalls, 1)
      assertEq(#csvCalls, 1)
      assertNil(txtCalls[1].groupName)
      assertNil(csvCalls[1].groupName)
    end)
  end)

  it("fallback branch honors csv-only flag", function()
    withSpies({txt = false, csv = true, assignments = {}}, function(txtCalls, csvCalls)
      M:_WriteFlightPlanFiles(samplePlans)
      assertEq(#txtCalls, 0)
      assertEq(#csvCalls, 1)
    end)
  end)
end)

------------------------------------------------------------
-- Bundle smoke test
------------------------------------------------------------

print("== Bundle smoke test")
it("MosieNavigator.lua loads without errors", function()
  local ok, err = pcall(dofile, "MosieNavigator.lua")
  assert(ok, "bundle failed to load: " .. tostring(err))
end)

------------------------------------------------------------
-- Runner
------------------------------------------------------------

print("")
print("========================================")
print(string.format("Total: %d PASS, %d FAIL", totalPass, totalFail))
if totalFail > 0 then
  print("")
  print("Failures:")
  for _, f in ipairs(failures) do print("  " .. f) end
  os.exit(1)
end
os.exit(0)
