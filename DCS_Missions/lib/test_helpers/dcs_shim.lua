-- dcs_shim.lua
-- Minimal DCS API shim for unit testing outside the DCS runtime.
-- Compatible with Lua 5.1 / LuaJIT.
--
-- dofile this file before loading MOOSE and any module under test.
--
-- Globals set: env, timer, world, country, coalition, trigger, Airbase,
--   Group, Unit, Weapon, Object, Controller, AI, Warehouse, land, net,
--   radio, missionCommands, atmosphere, Terrain, CoalitionSide
-- Helper globals: setAbsTime(v), setTime(v), makeCoord(opts)

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
  getTime    = function() return fakeTime end,
  scheduleFunction = function() return 0 end,
  removeFunction   = nop,
}

function setAbsTime(v) fakeAbsTime = v end
function setTime(v)    fakeTime = v end

-- DCS event IDs. MOOSE indexes into world.event.* and does arithmetic on
-- S_EVENT_MAX, so these must be real numbers.
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
  event      = worldEvent,
  BirthPlace = {
    wsBirthPlace_Air = 1, wsBirthPlace_RunWay = 2, wsBirthPlace_Park = 3,
    wsBirthPlace_Heliport_Hot = 4, wsBirthPlace_Heliport_Cold = 5,
    wsBirthPlace_Ship_Cold = 6, wsBirthPlace_Ship_Hot = 7, wsBirthPlace_Ship = 8,
  },
  VolumeType      = { SEGMENT = 0, BOX = 1, SPHERE = 2, PYRAMID = 3 },
  getPlayer       = function() return nil end,
  getAirbases     = function() return {} end,
  addEventHandler = nop,
  removeEventHandler = nop,
  searchObjects   = nop,
  getMarkPanels   = function() return {} end,
}

country = {
  id   = makeAutoStub("country.id"),
  name = makeAutoStub("country.name"),
}

coalition = {
  side = { NEUTRAL = 0, RED = 1, BLUE = 2 },
  addGroup             = nop,
  addStaticObject      = nop,
  getGroups            = function() return {} end,
  getStaticObjects     = function() return {} end,
  getPlayers           = function() return {} end,
  getCountryCoalition  = function() return 0 end,
  getMainRefPoint      = function() return { x = 0, y = 0, z = 0 } end,
  getAirbases          = function() return {} end,
  getServiceProviders  = function() return {} end,
}

trigger = {
  misc       = makeAutoStub("trigger.misc"),
  action     = makeAutoStub("trigger.action"),
  smokeColor = { Green = 0, Red = 1, White = 2, Orange = 3, Blue = 4 },
  flareColor = { Green = 0, Red = 1, White = 2, Yellow = 3 },
}

Airbase = {
  Category     = { AIRDROME = 0, HELIPAD = 1, SHIP = 2 },
  TerminalType = {
    Runway = 16, HelicopterOnly = 40, Shelter = 68, OpenBig = 72,
    OpenMed = 104, OpenMedOrBig = 176, HelicopterUsable = 216, FighterAircraft = 244,
  },
}

Group = {
  Category = { AIRPLANE = 0, HELICOPTER = 1, GROUND = 2, SHIP = 3, TRAIN = 4 },
}

Unit = {
  Category       = { AIRPLANE = 0, HELICOPTER = 1, GROUND_UNIT = 2, SHIP = 3, STRUCTURE = 4 },
  RefuelingSystem = { BOOM_AND_RECEPTACLE = 0, PROBE_AND_DROGUE = 1 },
}

Weapon = {
  Category        = { SHELL = 0, MISSILE = 1, ROCKET = 2, BOMB = 3, TORPEDO = 4 },
  GuidanceType    = { INS = 1, IR = 2, RADAR_ACTIVE = 3, RADAR_SEMI_ACTIVE = 4, RADAR_PASSIVE = 5, TV = 6, LASER = 7, TELE = 8 },
  MissileCategory = { AAM = 1, SAM = 2, BM = 3, ANTI_SHIP = 4, CRUISE = 5, OTHER = 6 },
  WarheadType     = { AP = 0, HE = 1, SHAPED_EXPLOSIVE = 2 },
  flag            = makeAutoStub("Weapon.flag"),
}

Object = {
  Category = { UNIT = 1, WEAPON = 2, STATIC = 3, BASE = 4, SCENERY = 5, CARGO = 6 },
}

Controller = makeAutoStub("Controller")

AI = {
  Task  = makeAutoStub("AI.Task"),
  Skill = { AVERAGE = "Average", GOOD = "Good", HIGH = "High", EXCELLENT = "Excellent",
            RANDOM = "Random", PLAYER = "Player", CLIENT = "Client" },
  Option = makeAutoStub("AI.Option"),
}

Warehouse    = makeAutoStub("Warehouse")

land = {
  SurfaceType  = { LAND = 1, SHALLOW_WATER = 2, WATER = 3, ROAD = 4, RUNWAY = 5 },
  getHeight    = function() return 0 end,
  getSurfaceType = function() return 1 end,
  getIP        = function() return nil end,
  isVisible    = function() return true end,
  profile      = function() return {} end,
}

net            = makeAutoStub("net")
radio          = { modulation = { AM = 0, FM = 1 } }
missionCommands = makeAutoStub("missionCommands")
atmosphere     = makeAutoStub("atmosphere")
Terrain        = makeAutoStub("Terrain")
CoalitionSide  = coalition.side

-- Coordinate mock factory.
-- Distance = Euclidean over (x, z); heading = atan2(dx, dz) degrees, north = +z.
function makeCoord(opts)
  opts = opts or {}
  local windField        = opts.windField
  local declinationField = opts.declinationField
  local self = {
    x            = opts.x or 0,
    y            = opts.y or 0,
    z            = opts.z or 0,
    windField    = windField,
    declinationField = declinationField,
    wind         = opts.wind,
    declination  = opts.declination,
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
  self.GetVec2 = function() return { x = self.x, y = self.z } end
  self.GetLLDDM = function() return opts.lat or 0, opts.lon or 0 end
  self.GetMagneticDeclination = function()
    if self.declinationField then return self.declinationField(self.x, self.z) end
    return self.declination or 0
  end
  self.GetWindVec3 = function(_, height)
    if self.windField then return self.windField(self.x, self.z, height) end
    return self.wind or { x = 0, y = 0, z = 0 }
  end
  self.GetIntermediateCoordinate = function(_, other, fraction)
    return makeCoord({
      x = self.x + ((other.x or 0) - self.x) * fraction,
      y = self.y + ((other.y or 0) - self.y) * fraction,
      z = self.z + ((other.z or 0) - self.z) * fraction,
      windField        = windField        or other.windField,
      declinationField = declinationField or other.declinationField,
    })
  end
  -- DCS F10 map drawing stubs (needed for _DrawWaypoint/_DrawPlan/_DrawBeacon)
  self.CircleToAll = function(_, radius, coalition, color, alpha, fillColor, fillAlpha, lineType, readOnly, label)
    return {markType = "circle", x = self.x, z = self.z}
  end
  self.TextToAll = function(_, text, coalition, color, readOnly, fillColor, fillAlpha, fontSize, readOnly2)
    return {markType = "text", text = text, x = self.x, z = self.z}
  end
  self.LineToAll = function(_, other, coalition, color, alpha, lineType, readOnly, label)
    return {markType = "line", x = self.x, z = self.z}
  end
  return self
end
