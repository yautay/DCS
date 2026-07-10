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
dofile("MosieNavigator.lua")

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
  it("parses HH:MM:SS", function()
    local text, sec = M:_ParseTimeOnTarget("14:30:45")
    assertEq(text, "14:30"); assertEq(sec, 14 * 3600 + 30 * 60 + 45)
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
  it("parses H:MM", function()
    assertEq(M:_ParseRolexDuration("0:05"), 5 * 60)
    assertEq(M:_ParseRolexDuration("1:30"), 3600 + 30 * 60)
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
  it("ALT500 / ALT500FT", function()
    assertEq(M:_ParseWaypointMetadata({"ALT500"}).altitudeFt, 500)
    assertEq(M:_ParseWaypointMetadata({"ALT500FT"}).altitudeFt, 500)
  end)
  it("T14:30", function()
    local md = M:_ParseWaypointMetadata({"T14:30"})
    assertEq(md.timeOnTarget, "14:30")
    assertEq(md.timeOnTargetSeconds, 14 * 3600 + 30 * 60)
  end)
  it("TOT14:30", function()
    assertEq(M:_ParseWaypointMetadata({"TOT14:30"}).timeOnTarget, "14:30")
  end)
  it("both A and T", function()
    local md = M:_ParseWaypointMetadata({"A500", "T14:30"})
    assertEq(md.altitudeFt, 500)
    assertEq(md.timeOnTarget, "14:30")
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
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_03_RENDEZVOUS_Rendezvous")
    assertEq(wp.name, "Rendezvous")
  end)
  it("TAKE_OFF with NAME", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_01_TAKE_OFF_Tangmere")
    assertEq(wp.type, "TAKE_OFF"); assertEq(wp.name, "Tangmere")
  end)
  it("TAKE_OFF without NAME", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_01_TAKE_OFF")
    assertEq(wp.type, "TAKE_OFF"); assertEq(wp.name, "TAKE_OFF")
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

suite("CalculateLegSpeedKnots", function()
  it("no TOT → nil", function()
    local prev = { timeOnTargetSeconds = nil }
    local cur = { timeOnTargetSeconds = 3600 }
    assertNil(M:_CalculateLegSpeedKnots(prev, cur, 10))
  end)
  it("60 NM / 1 h = 60 kt", function()
    local prev = { timeOnTargetSeconds = 0 }
    local cur = { timeOnTargetSeconds = 3600 }
    assertNear(M:_CalculateLegSpeedKnots(prev, cur, 60), 60)
  end)
  it("cross-midnight wrap", function()
    local prev = { timeOnTargetSeconds = 23 * 3600 }
    local cur = { timeOnTargetSeconds = 1 * 3600 }
    assertNear(M:_CalculateLegSpeedKnots(prev, cur, 120), 60)
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

suite("ComputeLegMetrics", function()
  it("first waypoint: no leg, has trueCourse to next", function()
    local a = { coordinate = makeCoord({x=0, z=0}) }
    local b = { coordinate = makeCoord({x=1852, z=0}) }
    local plan = { waypoints = {a, b} }
    local m = M:_ComputeLegMetrics(plan, 1)
    assertNil(m.legDistanceNm)
    assertNil(m.legSpeedKnots)
    assertNil(m.legIasKnots)
    assertNotNil(m.trueCourse)
  end)
  it("mid waypoint: leg distance and speed", function()
    local a = { coordinate = makeCoord({x=0, z=0}), timeOnTargetSeconds = 0 }
    local b = { coordinate = makeCoord({x=1852, z=0}), timeOnTargetSeconds = 3600, altitudeFt = 0 }
    local plan = { waypoints = {a, b} }
    local m = M:_ComputeLegMetrics(plan, 2)
    assertNear(m.legDistanceNm, 1, 0.001)
    assertNear(m.legSpeedKnots, 1, 0.001)
    assertNil(m.trueCourse)
  end)
  it("true course between waypoints", function()
    local a = { coordinate = makeCoord({x=0, z=0}) }
    local b = { coordinate = makeCoord({x=1000, z=0}) }
    local c = { coordinate = makeCoord({x=1000, z=1000}) }
    local plan = { waypoints = {a, b, c} }
    local m = M:_ComputeLegMetrics(plan, 2)
    assertNear(m.trueCourse, 0, 0.01)
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
