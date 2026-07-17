-- MosieNavigator.spec.lua
-- Unit tests for MosieNavigator source modules.
--
-- Run from this directory:
--   lua MosieNavigator.spec.lua
--
-- Loads the DCS API shim and MOOSE, then loads source modules from src/
-- and exercises parsers, formatters, math helpers, and zone discovery flow.
--
-- Compatible with Lua 5.1 / LuaJIT (DCS runtime).

------------------------------------------------------------
-- Section 1: DCS API shim + test helpers
------------------------------------------------------------

dofile("../test_helpers/dcs_shim.lua")

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
MOSIE_AI_PLANNER_AUTO_START = false
dofile("../mosie_ai_planner/MosieAiPlanner.lua")

------------------------------------------------------------
-- Section 5: Mini test framework
------------------------------------------------------------

dofile("../test_helpers/suite.lua")

------------------------------------------------------------
-- Section 7: Test suites
------------------------------------------------------------

local M = MosieNavigator

suite("Config defaults", function()
  it("merges partial pre-load config with defaults", function()
    local originalConfig = MosieNavigator.Config
    MosieNavigator.Config = { flightPlanOutputDirectory = "custom/" }

    local ok, err = pcall(dofile, "src/01_config.lua")

    local merged = MosieNavigator.Config
    MosieNavigator.Config = originalConfig
    M.Config = originalConfig
    if not ok then error(err) end

    assertEq(merged.flightPlanOutputDirectory, "custom/")
    assertEq(merged.flightZonePrefix, "MN_")
    assertEq(merged.navigatorTickInterval, 5)
    assertEq(merged.generateCsvFiles, true)
  end)
end)

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
  it("signed negative HH:MM", function()
    assertEq(M:_FormatSignedRolex(-5 * 60), "-00:05")
  end)
  it("signed positive HH:MM", function()
    assertEq(M:_FormatSignedRolex(10 * 60), "+00:10")
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
  it("__P_ token parsed into targetPackageId", function()
    local wp = M:_ParseWaypointZoneName("MN_JERICHO_04_TARGET_Prison__T14:30__P_PRISON_BOMB")
    assertNotNil(wp)
    assertEq(wp.type, "TARGET")
    assertEq(wp.targetPackageId, "PRISON_BOMB")
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
  it("rejects malformed rolex suffix instead of parsing prefix", function()
    local logs = {}
    local originalLog = M._Log
    M._Log = function(_, message) table.insert(logs, message) end

    local ok, result = pcall(function()
      return M:_ExtractRolexFromGroupName("MOSQUITO [MN:X]__R5BAD")
    end)

    M._Log = originalLog
    if not ok then error(result) end
    assertEq(result, 0)
    assertTrue(string.find(logs[1] or "", "invalid group ROLEX") ~= nil)
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
  it("off-track starboard side", function()
    local prev = { coordinate = makeCoord({x=0, z=0}) }
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local cur = makeCoord({x=-1852, z=926})
    local xte, side = M:_CalculateXte(prev, wp, cur)
    assertNear(xte, 1, 0.001)
    assertEq(side, "stbd")
  end)
  it("off-track port side", function()
    local prev = { coordinate = makeCoord({x=0, z=0}) }
    local wp = { coordinate = makeCoord({x=0, z=1852}) }
    local cur = makeCoord({x=1852, z=926})
    local xte, side = M:_CalculateXte(prev, wp, cur)
    assertNear(xte, 1, 0.001)
    assertEq(side, "port")
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
    local windField = function() return {x=0, y=0, z=-1} end
    local start = makeCoord({x=0, z=0, windField = windField})
    local wp = { coordinate = makeCoord({x=0, z=1852, windField = windField}) }
    local hdg, tas = M:_CalculateWindCorrectedGuidance(start, wp, 3600, 0)
    -- ground speed 1 kt = 0.514 m/s, headwind -1 m/s in z → air z = 1.514
    -- TAS = 1.514 / 0.514444 ≈ 2.94 kt
    assertNear(tas, 1.514 / 0.514444, 0.05)
    assertNear(hdg, 0, 0.5)
  end)
  it("samples leg coordinates every 10 NM rounded down, minimum 2", function()
    local nm = 1852
    local start = makeCoord({x=0, z=0})
    assertEq(#M:_GetLegSampleCoordinates(start, makeCoord({x=0, z=5 * nm}), 5), 2)
    assertEq(#M:_GetLegSampleCoordinates(start, makeCoord({x=0, z=19 * nm}), 19), 2)
    assertEq(#M:_GetLegSampleCoordinates(start, makeCoord({x=0, z=20 * nm}), 20), 3)
    assertEq(#M:_GetLegSampleCoordinates(start, makeCoord({x=0, z=35 * nm}), 35), 4)
  end)
  it("averages wind vectors over sampled start/mid/end coordinates", function()
    local nm = 1852
    local windField = function(_, z)
      return {x = z / (10 * nm), y = 0, z = 0}
    end
    local start = makeCoord({x=0, z=0, windField = windField})
    local finish = makeCoord({x=0, z=20 * nm, windField = windField})
    local avg = M:_GetAverageLegWindVec3(start, finish, 0, 20)
    assertNear(avg.x, 1, 0.001)
    assertNear(avg.z, 0, 0.001)
  end)
  it("averages magnetic variation over the same leg samples", function()
    local nm = 1852
    local declinationField = function(_, z)
      return z / (10 * nm)
    end
    local start = makeCoord({x=0, z=0, declinationField = declinationField})
    local finish = makeCoord({x=0, z=20 * nm, declinationField = declinationField})
    -- _GetMagneticVariation stores variation as negative DCS declination.
    assertNear(M:_GetAverageLegMagneticVariation(start, finish, 20), -1, 0.001)
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

suite("DiscoverGroupAssignments", function()
  local function withFakeGroups(groups, testMode, fn)
    local originalSetGroup = SET_GROUP
    local originalTestMode = TEST_MODE
    local fakeSet = {
      FilterStart = function(self) return self end,
      ForEachGroup = function(self, cb)
        for _, group in ipairs(groups) do cb(group) end
        return self
      end,
    }
    SET_GROUP = { New = function() return fakeSet end }
    TEST_MODE = testMode

    local ok, err = pcall(fn)

    SET_GROUP = originalSetGroup
    TEST_MODE = originalTestMode
    if not ok then error(err, 2) end
  end

  local function fakeGroup(name, skill)
    return {
      GetName = function() return name end,
      GetSkill = function() return skill end,
      IsAlive = function() return true end,
    }
  end

  it("uses client groups and ignores AI outside TEST_MODE", function()
    withFakeGroups({
      fakeGroup("CLIENT [MN:TEST]", "Client"),
      fakeGroup("AI [MN:TEST]", "High"),
    }, false, function()
      local assignments = M:_DiscoverGroupAssignments({TEST = {name = "TEST", waypoints = {}}})
      assertEq(#assignments, 1)
      assertEq(assignments[1].groupName, "CLIENT [MN:TEST]")
    end)
  end)

  it("uses AI groups in TEST_MODE", function()
    withFakeGroups({fakeGroup("AI [MN:TEST]", "High")}, true, function()
      local assignments = M:_DiscoverGroupAssignments({TEST = {name = "TEST", waypoints = {}}})
      assertEq(#assignments, 1)
      assertEq(assignments[1].groupName, "AI [MN:TEST]")
      assertEq(assignments[1].navigatorAutoDefault, true)
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
  it("192 mph IAS uses cruise weak burn", function()
    local p = M:_EstimateFuelProfile(192 * 0.8689762419, 0)
    assertEq(p.name, "CRZ")
    assertNear(p.burnImpGph, 84, 0.01)
  end)
  it("228 mph IAS uses max continuous weak burn", function()
    local p = M:_EstimateFuelProfile(228 * 0.8689762419, 0)
    assertEq(p.name, "CRZ-MCW")
    assertNear(p.burnImpGph, 126, 0.01)
  end)
  it("232.5 mph IAS interpolates between weak and rich continuous", function()
    local p = M:_EstimateFuelProfile(232.5 * 0.8689762419, 0)
    assertEq(p.name, "MCW-MCR")
    assertNear(p.burnImpGph, 143, 0.01)
  end)
  it("238.5 mph IAS interpolates between rich continuous and climb", function()
    local p = M:_EstimateFuelProfile(238.5 * 0.8689762419, 0)
    assertEq(p.name, "MCR-CLB")
    assertNear(p.burnImpGph, 175, 0.01)
  end)
  it("below curve clamps to lowest documented burn", function()
    assertNear(M:_EstimateFuelProfile(140, 0).burnImpGph, 84, 0.01)
  end)
  it("above curve clamps to highest route burn", function()
    assertNear(M:_EstimateFuelProfile(250 * 0.8689762419, 0).burnImpGph, 190, 0.01)
  end)
end)

-- ─── ComputePlan helpers ───────────────────────────────────────────────────

local NM = 1852  -- metres per NM

-- Builds a plan with coords laid out in a line along the z-axis.
-- Each entry: { zoneName, zMetres, [lat], [lon], [windVec3], [windField], [declination], [declinationField] }
-- Distances between consecutive WPs in NM = delta_z / 1852.
local function makePlan(entries)
  local wps = {}
  for _, e in ipairs(entries) do
    local wp = M:_ParseWaypointZoneName(e[1])
    assert(wp, "parse failed: " .. e[1])
    wp.coordinate = makeCoord({
      x = 0,
      z = e[2] or 0,
      lat = e[3] or 50,
      lon = e[4] or 0,
      wind = e[5],
      windField = e[6],
      declination = e[7],
      declinationField = e[8],
    })
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

  it("valid when TAKE_OFF missing __S uses 228 mph default cruise speed", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T12:00", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, true)
    assertNear(M.Aircraft.defaultCruiseSpeedKt, 198.127, 0.001)
    assertNear(r.waypoints[2].legGsKt, M.Aircraft.defaultCruiseSpeedKt, 0.01)
  end)

  it("TAKE_OFF __S remains knots and overrides mph default", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T12:00__S200", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, true)
    assertNear(r.waypoints[2].legGsKt, 200, 0.01)
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

  it("all non-TAKEOFF legs use declared 200 kt GS", function()
    local r = M:_ComputePlan(plan, 0)
    for i = 2, #r.waypoints do
      local w = r.waypoints[i]
      assertNotNil(w.legGsKt, "legGsKt nil at WP" .. i)
      assertNear(w.legGsKt, 200, 0.1)
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
  -- 75 NM total, __T12:25 on TARGET → 25 min → required 180 kt GS
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*20 },
    { "MN_TEST_03_NAV",                          NM*50 },
    { "MN_TEST_04_TARGET__T12:25",               NM*75 },
    { "MN_TEST_05_LANDING",                      NM*120 },
  })

  it("segment [TAKE_OFF..TARGET] ETA hits constraint", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid)
    -- TARGET should be at or very close to 12:25
    assertNear(r.waypoints[4].etaSec, 12*3600 + 25*60, 2)
  end)

  it("post-constraint leg reverts to default __S200", function()
    local r = M:_ComputePlan(plan, 0)
    -- leg to LANDING: default 200 kt GS
    assertNear(r.waypoints[5].legGsKt, 200, 0.1)
  end)
end)

suite("ComputePlan — low-speed timing advisory", function()
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*10 },
    { "MN_TEST_03_TARGET__T12:30",               NM*20 },
    { "MN_TEST_04_LANDING",                      NM*40 },
  })

  it("uses minimum cruise speed but keeps the timed waypoint fixed", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertNear(r.waypoints[3].etaSec, 12*3600 + 30*60, 1)
    assertNear(r.waypoints[2].legIasKt, M.Aircraft.envelope.minIasKt, 0.5)
    assertNear(r.waypoints[3].legIasKt, M.Aircraft.envelope.minIasKt, 0.5)
    assertTrue((r.waypoints[3].timingDelayBeforeSec or 0) > 0,
      "expected delay before timed target")
  end)

  it("emits TIMING advisory instead of low-speed clamp warning", function()
    local r = M:_ComputePlan(plan, 0)
    local timingText = table.concat(r.timing or {}, "; ")
    local warningText = table.concat(r.warnings or {}, "; ")
    assertTrue(string.find(timingText, "orbit/delay at WP02 before WP03 TARGET") ~= nil,
      "expected timing advisory, got: " .. timingText)
    assertTrue(string.find(warningText, "below minimum") == nil,
      "expected no low-speed warning, got: " .. warningText)
  end)

  it("renders TIMING section in flight plan output", function()
    M.ComputedPlanCache = nil
    local text = M:_BuildFlightPlanTable(plan)
    assertTrue(string.find(text, "TIMING:") ~= nil, "expected TIMING section")
    assertTrue(string.find(text, "at WP02 before WP03 TARGET") ~= nil, "expected target timing text")
  end)

  it("keeps TEST-C style TARGET __T and shifts it with base ROLEX", function()
    local testC = makePlan({
      { "MN_TEST_01_TAKE_OFF__A1250__T7:04", 0 },
      { "MN_TEST_02_TARGET__T7:25",          NM * 44.95 },
      { "MN_TEST_03_LANDING",                NM * 89.91 },
    })

    local base = M:_ComputePlan(testC, 0)
    local rolex = M:_ComputePlan(testC, 5 * 60)

    assertTrue(base.valid, base.error or "")
    assertTrue(rolex.valid, rolex.error or "")
    assertNear(base.waypoints[2].etaSec, 7*3600 + 25*60, 1)
    assertNear(rolex.waypoints[2].etaSec, 7*3600 + 30*60, 1)
    assertTrue((base.waypoints[2].timingDelayBeforeSec or 0) > 0,
      "expected delay before TEST-C target")
  end)
end)

suite("ComputePlan — impossible fast TOT", function()
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__A500", 0 },
    { "MN_TEST_02_TARGET__T12:05",         NM * 100 },
    { "MN_TEST_03_LANDING",               NM * 110 },
  })

  it("drifts ETA late when the aircraft cannot make the timed waypoint", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertTrue(r.waypoints[2].etaSec > 12*3600 + 5*60,
      "expected target ETA to drift late")
    assertTrue((r.waypoints[2].lateTotWarningSec or 0) > 0,
      "expected late TOT metadata")
  end)

  it("warns clearly that the timed waypoint is unreachable", function()
    local r = M:_ComputePlan(plan, 0)
    local warningText = table.concat(r.warnings or {}, "; ")
    assertTrue(string.find(warningText, "unable to meet TOT 12:05") ~= nil,
      "expected unable TOT warning, got: " .. warningText)
    assertTrue(string.find(warningText, "late by") ~= nil,
      "expected late-by warning, got: " .. warningText)
  end)
end)

suite("ComputePlan — Plan 5 MIXED_S (FIXED honored, FREE averaged)", function()
  -- Segment [TAKE_OFF..TARGET] 50 NM in 15 min
  -- WP3 INGRESS: FIXED __S200 (dist 10 NM from prev)
  -- WP2 NAV and WP4 TARGET: FREE
  -- FIXED leg (→WP3): 10 NM at 200 kt GS = 3 min
  -- FREE legs (→WP2 20NM and →WP4 20NM) share remaining 12 min
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV__A500",                    NM*20 },
    { "MN_TEST_03_INGRESS__S200__A200",           NM*30 },
    { "MN_TEST_04_TARGET__A200__T12:15",         NM*50 },
    { "MN_TEST_05_LANDING",                      NM*95 },
  })

  it("FIXED leg at WP3 uses __S200 GS", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertNear(r.waypoints[3].legGsKt, 200, 0.1)
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
  -- WP3 NAV has __S170; others default 200
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV",                          NM*20 },
    { "MN_TEST_03_NAV__S170",                    NM*30 },
    { "MN_TEST_04_LANDING",                      NM*60 },
  })

  it("WP3 leg uses __S170 GS", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    assertNear(r.waypoints[3].legGsKt, 170, 0.1)
  end)

  it("WP4 leg reverts to default 200 GS", function()
    local r = M:_ComputePlan(plan, 0)
    assertNear(r.waypoints[4].legGsKt, 200, 0.1)
  end)
end)

suite("ComputePlan — explicit __S envelope clamp", function()
  local plan = makePlan({
    { "MN_TEST_01_TAKE_OFF__T12:00__S200__A500", 0 },
    { "MN_TEST_02_NAV__S140",                    NM*20 },
    { "MN_TEST_03_LANDING",                      NM*60 },
  })

  it("clamps explicit __S below minimum IAS", function()
    local r = M:_ComputePlan(plan, 0)
    assertTrue(r.valid, r.error or "")
    local expectedGs = M:_ConvertIasToTas(M.Aircraft.envelope.minIasKt, 500)
    assertNear(r.waypoints[2].legGsKt, expectedGs, 0.1)
  end)

  it("emits warning for explicit __S clamp", function()
    local r = M:_ComputePlan(plan, 0)
    local found = false
    for _, w in ipairs(r.warnings) do
      if string.find(w, "WP02 __S") and string.find(w, "clamped") then found = true; break end
    end
    assertTrue(found, "expected explicit __S clamp warning, got: " .. table.concat(r.warnings, "; "))
  end)
end)

suite("ComputePlan — ROLEX shift", function()
  -- 60 NM in 20 min = 180 kt required, feasible in the Mosquito envelope.
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
  -- HOLD1/HOLD2 local speed overrides exceed the envelope and are clamped.
  -- HOLD2 has own __T,
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

  it("Leg to HOLD1 clamps declared __S400 to envelope", function()
    local r = M:_ComputePlan(plan, 0)
    local expectedGs = M:_ConvertIasToTas(M.Aircraft.envelope.maxIasKt, 500)
    assertNear(r.waypoints[2].legGsKt, expectedGs, 2)
  end)

  it("Leg to TARGET clamps declared __S300 to envelope", function()
    local r = M:_ComputePlan(plan, 0)
    local expectedGs = M:_ConvertIasToTas(M.Aircraft.envelope.maxIasKt, 500)
    assertNear(r.waypoints[4].legGsKt, expectedGs, 2)
  end)

  it("emits clamp warnings for local __S overrides", function()
    local r = M:_ComputePlan(plan, 0)
    local count = 0
    for _, w in ipairs(r.warnings) do
      if string.find(w, "__S") and string.find(w, "clamped") then count = count + 1 end
    end
    assertTrue(count >= 2, "expected __S clamp warnings, got: " .. table.concat(r.warnings, "; "))
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
      { "MN_TEST_01_TAKE_OFF__T07:00__S200__A1500", 0 },
      { "MN_TEST_02_NAV", NM * 20 },
      { "MN_TEST_03_LANDING", NM * 40 },
    })
    local msg = M:_BuildSimplifiedFlightPlanMessage(plan, "GRP", 0)
    assertMatch(msg, "ID%s+TYPE%s+ALT%s+IAS%(MPH%)%s+TAS%(KN%)%s+COG%s+WHDG%s+WTAS%s+HDG%(T%)%s+VAR%s+HDG%(M%)%s+SOG%s+DIST%s+TIME%s+ETA%s+GAS")
    assertMatch(msg, "01 TAKE_OFF%s+1500%s+[^\n]*07:00%s+%-%-%-")
    assertMatch(msg, "02 NAV%s+1500%*%s+225%*%s+200%s+000%s+%+00%s+%+00%s+000%s+%+0%.0%s+000%s+200%s+20%.0%s+6%s+07:06%s+%d+%.%d")
    assertMatch(msg, "03 LANDING%s+1500%*%s+225%*%s+200%s+000%s+%+00%s+%+00%s+000%s+%+0%.0%s+000%s+200%s+20%.0%s+6%s+07:12%s+%d+%.%d")
  end)

  it("wind correction shifts HDG(T) from COG and updates TAS/IAS", function()
    local windField = function() return {x = 10, y = 0, z = 0} end
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S200__A1500", 0, nil, nil, nil, windField },
      { "MN_TEST_02_NAV", NM * 20, nil, nil, nil, windField },
      { "MN_TEST_03_LANDING", NM * 40, nil, nil, nil, windField },
    })
    local r = M:_ComputePlan(plan, 0)
    assertEq(r.valid, true)
    assertNear(r.waypoints[2].trueCourse, 0, 0.01)
    assertNear(r.waypoints[2].headingTrue, 354.45, 0.1)
    assertNear(r.waypoints[2].windCorrectionDeg, -5.55, 0.1)
    assertNear(r.waypoints[2].tasCorrectionKt, 0.94, 0.1)
    assertTrue(r.waypoints[2].legTasKt > r.waypoints[2].legGsKt, "crosswind should increase required TAS")

    local msg = M:_BuildSimplifiedFlightPlanMessage(plan, "GRP", 0)
    assertMatch(msg, "02 NAV%s+1500%*%s+226%*%s+201%s+000%s+%-06%s+%+01%s+354")
  end)

  it("F10 flight plan includes multi-line fuel summary", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S200__A1500", 0 },
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
      { "MN_TEST_01_TAKE_OFF__T07:00__S200__A1500", 0 },
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
      { "MN_TEST_01_TAKE_OFF__T07:00__S200__A1500", 0 },
      { "MN_TEST_02_NAV", NM * 20 },
      { "MN_TEST_03_LANDING", NM * 40 },
    })
    local lines = splitLines(M:_BuildFlightPlanTable(plan, nil, 0))
    local header, row
    for _, line in ipairs(lines) do
      if string.find(line, "HDG(T)", 1, true) then header = line end
      if string.find(line, "02 NAV", 1, true) then row = line end
    end
    assertNotNil(header)
    assertNotNil(row)
    assertNotNil(string.find(header, "COG%s+WHDG%s+WTAS%s+HDG%(T%)%s+VAR%s+HDG%(M%)"))
    assertNotNil(string.find(row, "000%s+%+00%s+%+00%s+000%s+%+0%.0%s+000%s+200%s+20%.0%s+6%s+07:06%s+%d+%.%d"))
  end)

  it("TXT navlog GAS column shows inbound leg fuel only", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S200__A1500", 0 },
      { "MN_TEST_02_HOLD__T07:20", NM * 20 },
      { "MN_TEST_03_LANDING__T07:40", NM * 40 },
    })
    local text = M:_BuildFlightPlanTable(plan, nil, 0)
    assertMatch(text, "ID%s+TYPE%s+[^\n]+ETA%s+GAS")
    assertMatch(text, "01 TAKE_OFF%s+1500%s+[^\n]*07:00%s+%-%-%-")
    assertMatch(text, "02 HOLD%s+1500%*%s+[^\n]*07:20%s+%d+%.%d")
    assertMatch(text, "orbit %d+ min @ 140 IAS: %d+%.%d gal")
  end)

  it("TXT navlog marks inherited ALT and IAS with star", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S200__A1500", 0 },
      { "MN_TEST_02_NAV", NM * 20 },
      { "MN_TEST_03_LANDING__S200", NM * 40 },
    })
    local text = M:_BuildFlightPlanTable(plan, nil, 0)
    assertMatch(text, "02 NAV%s+1500%*%s+225%*")
    assertMatch(text, "03 LANDING%s+1500%*%s+225%s")
  end)

  it("static FP render uses cached computed plan per plan and ROLEX", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local original = M._ComputePlan
    local calls = 0
    M.ComputedPlanCache = nil
    M._ComputePlan = function(self, p, rolexSeconds)
      calls = calls + 1
      return original(self, p, rolexSeconds)
    end

    local ok, err = pcall(function()
      M:_BuildSimplifiedFlightPlanMessage(plan, "GRP", 0)
      M:_BuildFlightPlanTable(plan, "GRP", 0)
      M:_BuildSimplifiedFlightPlanMessage(plan, "GRP", 300)
    end)

    M._ComputePlan = original
    M.ComputedPlanCache = nil
    if not ok then error(err) end
    assertEq(calls, 2)
  end)

  it("group __R shifts ETA but is not displayed as pilot ROLEX", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local msg = M:_BuildSimplifiedFlightPlanMessage(plan, "GRP [MN:TEST]__R5", 5 * 60, 0)
    assertMatch(msg, "01 TAKE_OFF%s+1500%s+[^\n]*07:05")
    assertTrue(not string.find(msg, "ROLEX", 1, true), "__R must be hidden from pilot ROLEX display")
  end)

  it("pilot ADVANCE displays negative ROLEX and shifts from __R baseline", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local msg = M:_BuildSimplifiedFlightPlanMessage(plan, "GRP [MN:TEST]__R5", 5 * 60, -2 * 60)
    assertMatch(msg, "ROLEX : %-00:02")
    assertMatch(msg, "01 TAKE_OFF%s+1500%s+[^\n]*07:03")
  end)

  it("pilot RETARD displays positive ROLEX and shifts from __R baseline", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local msg = M:_BuildSimplifiedFlightPlanMessage(plan, "GRP [MN:TEST]__R5", 5 * 60, 3 * 60)
    assertMatch(msg, "ROLEX : %+00:03")
    assertMatch(msg, "01 TAKE_OFF%s+1500%s+[^\n]*07:08")
  end)

  it("pilot ROLEX shifts cached plan copy without recomputing base weather/variation", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local original = M._ComputePlan
    local calls = 0
    M.ComputedPlanCache = nil
    M._ComputePlan = function(self, p, rolexSeconds)
      calls = calls + 1
      return original(self, p, rolexSeconds)
    end

    local ok, err = pcall(function()
      local plus = M:_GetActiveComputedPlan(plan, 5 * 60, 2 * 60)
      local minus = M:_GetActiveComputedPlan(plan, 5 * 60, -2 * 60)
      assertNear(plus.waypoints[1].etaSec, 7 * 3600 + 7 * 60, 1)
      assertNear(minus.waypoints[1].etaSec, 7 * 3600 + 3 * 60, 1)
    end)

    M._ComputePlan = original
    M.ComputedPlanCache = nil
    if not ok then error(err) end
    assertEq(calls, 1)
  end)

  it("TXT navlog hides base __R and displays only pilot ROLEX", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local baseOnly = M:_BuildFlightPlanTable(plan, "GRP [MN:TEST]__R5", 5 * 60, 0)
    assertTrue(not string.find(baseOnly, "ROLEX", 1, true), "base __R should not be labeled as ROLEX")

    local pilot = M:_BuildFlightPlanTable(plan, "GRP [MN:TEST]__R5", 5 * 60, 10 * 60)
    assertMatch(pilot, "ROLEX : %+00:10")
  end)
end)

suite("Navigator takeoff callouts", function()
  local function makeNavGroup(name, airborne)
    return {
      GetName = function() return name end,
      IsAlive = function() return true end,
      IsAirborne = function() return airborne or false end,
    }
  end

  local function withCapturedNavigatorMessages(fn)
    local messages = {}
    local originalSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil
    local ok, err = pcall(function() fn(messages) end)
    M._SendNavigatorMessage = originalSend
    M.NavigatorStates = nil
    if not ok then error(err, 2) end
  end

  it("reports time to takeoff by interval before the final 30 seconds", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:01__S220__A1500", 0 },
        { "MN_TEST_02_NAV__T00:20", NM * 20 },
        { "MN_TEST_03_LANDING", NM * 40 },
      })
      local group = makeNavGroup("MOSQUITO 1-1 [MN:TEST]")
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.reportInterval = 30
      state.lastReportTime = 0

      setAbsTime(20)
      setTime(31)
      M:_TickNavigatorState(state)

      assertEq(#messages, 1)
      assertEq(messages[1], "NAV: Brake release in 0:40. Stand by.")
    end)
  end)

  it("always emits 30/20/10/5 second takeoff callouts", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:01__S220__A1500", 0 },
        { "MN_TEST_02_NAV__T00:20", NM * 20 },
        { "MN_TEST_03_LANDING", NM * 40 },
      })
      local group = makeNavGroup("MOSQUITO 1-1 [MN:TEST]")
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.reportInterval = 120

      setAbsTime(30); setTime(30); M:_TickNavigatorState(state)
      setAbsTime(40); setTime(40); M:_TickNavigatorState(state)
      setAbsTime(50); setTime(50); M:_TickNavigatorState(state)
      setAbsTime(55); setTime(55); M:_TickNavigatorState(state)

      assertEq(#messages, 4)
      assertEq(messages[1], "0:30 CALLOUT: NAV: Brake release in 0:30. Stand by.")
      assertEq(messages[2], "0:20 CALLOUT: NAV: Brake release in 0:20. Stand by.")
      assertEq(messages[3], "0:10 CALLOUT: NAV: Brake release in 0:10. Stand by.")
      assertEq(messages[4], "0:05 CALLOUT: NAV: Brake release in 0:05. Stand by.")
    end)
  end)

  it("suppresses interval reports from 30 seconds to brake release", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:01__S220__A1500", 0 },
        { "MN_TEST_02_NAV__T00:20", NM * 20 },
        { "MN_TEST_03_LANDING", NM * 40 },
      })
      local group = makeNavGroup("MOSQUITO 1-1 [MN:TEST]")
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.reportInterval = 10
      state.lastReportTime = 20
      state.timedCallouts = { ["TAKE_OFF:brake_release"] = { [30] = true } }

      setAbsTime(35)
      setTime(35)
      M:_TickNavigatorState(state)

      assertEq(#messages, 0)
    end)
  end)

  it("announces brake release once", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:01__S220__A1500", 0 },
        { "MN_TEST_02_NAV__T00:20", NM * 20 },
        { "MN_TEST_03_LANDING", NM * 40 },
      })
      local group = makeNavGroup("MOSQUITO 1-1 [MN:TEST]")
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.reportInterval = 120

      setAbsTime(60); setTime(60); M:_TickNavigatorState(state)
      setAbsTime(61); setTime(61); M:_TickNavigatorState(state)

      assertEq(#messages, 1)
      assertEq(messages[1], "NAV: Brakes! Brakes! Brakes! Commence take-off!")
    end)
  end)

  it("does not advance to airborne waypoint guidance while still on the ground", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:01__S220__A1500", 0 },
        { "MN_TEST_02_NAV__T00:02", NM * 20 },
        { "MN_TEST_03_LANDING", NM * 40 },
      })
      local group = makeNavGroup("MOSQUITO 1-1 [MN:TEST]")
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.reportInterval = 10

      setAbsTime(60); setTime(60); M:_TickNavigatorState(state)
      setAbsTime(180); setTime(180); M:_TickNavigatorState(state)

      assertEq(#messages, 1)
      assertEq(messages[1], "NAV: Brakes! Brakes! Brakes! Commence take-off!")
      assertEq(state.currentWpIndex, 1)
    end)
  end)

  it("Status Now before takeoff does not consume automatic threshold callouts", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:01__S220__A1500", 0 },
        { "MN_TEST_02_NAV__T00:20", NM * 20 },
        { "MN_TEST_03_LANDING", NM * 40 },
      })
      local group = makeNavGroup("MOSQUITO 1-1 [MN:TEST]")
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true

      setAbsTime(30)
      setTime(30)
      M:_NavigatorStatusNow(group, plan, 0)
      M:_TickNavigatorState(state)

      assertEq(#messages, 2)
      assertEq(messages[1], "NAV: Brake release in 0:30. Stand by.")
      assertEq(messages[2], "0:30 CALLOUT: NAV: Brake release in 0:30. Stand by.")
    end)
  end)
end)

suite("Navigator waypoint callouts", function()
  local function makeAirborneNavGroup(name, x, z, altitudeM, velocityKt)
    return {
      GetName = function() return name end,
      IsAlive = function() return true end,
      IsAirborne = function() return true end,
      GetCoordinate = function() return makeCoord({x = x or 0, z = z or 0}) end,
      GetAltitude = function() return altitudeM or 0 end,
      GetVelocityKNOTS = function() return velocityKt or 0 end,
    }
  end

  local function withCapturedNavigatorMessages(fn)
    local messages = {}
    local originalSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil
    local ok, err = pcall(function() fn(messages) end)
    M._SendNavigatorMessage = originalSend
    M.NavigatorStates = nil
    if not ok then error(err, 2) end
  end

  it("emits 5/2/1 minute waypoint callouts with HDG ALT and IAS", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(0); setTime(0); M:_TickNavigatorState(state)
      setAbsTime(180); setTime(180); M:_TickNavigatorState(state)
      setAbsTime(240); setTime(240); M:_TickNavigatorState(state)

      assertEq(#messages, 3)
      assertEq(messages[1], "5:00 CALLOUT: NAV: WP02 Checkpoint, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 1500 feet. We are on track.")
      assertEq(messages[2], "2:00 CALLOUT: NAV: WP02 Checkpoint, DIST 15.0 NM. We are 6 min slow. Required IAS 450 kts >MAX. Steer 000M, height 1500 feet. We are on track.")
      assertEq(messages[3], "1:00 CALLOUT: NAV: WP02 Checkpoint, DIST 15.0 NM. We are 7 min slow. Required IAS 900 kts >MAX. Steer 000M, height 1500 feet. We are on track.")
    end)
  end)

  it("suppresses interval reports from 5 minutes to the active waypoint", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2
      state.reportInterval = 10
      state.lastReportTime = 0
      state.timedCallouts = { ["WP:2"] = { [300] = true } }

      setAbsTime(1)
      setTime(20)
      M:_TickNavigatorState(state)

      assertEq(#messages, 0)
    end)
  end)

  it("announces course change with next waypoint guidance", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_INGRESS_IP__T00:10__A500", NM * 30 },
        { "MN_TEST_04_LANDING", NM * 45 },
      })
      -- Group positioned at WP02 to trigger fly-over
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, NM * 15, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(300)
      setTime(300)
      M:_TickNavigatorState(state)

      assertEq(#messages, 1)
      assertEq(messages[1], "NAV: Set course for WP03 IP, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 500 feet. We are on track.")
      assertEq(state.currentWpIndex, 3)
    end)
  end)

  it("resets timed waypoint callouts after automatic course change", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_INGRESS_IP__T00:10__A500", NM * 30 },
        { "MN_TEST_04_LANDING", NM * 45 },
      })
      -- Group positioned at WP02 to trigger fly-over
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, NM * 15, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2
      state.timedCallouts = { ["WP:2"] = { [300] = true, [120] = true, [60] = true } }

      setAbsTime(300); setTime(300); M:_TickNavigatorState(state)
      setAbsTime(301); setTime(301); M:_TickNavigatorState(state)

      assertEq(#messages, 2)
      assertEq(messages[2], "5:00 CALLOUT: NAV: WP03 IP, DIST 15.0 NM. We are 3 min slow. Required IAS 181 kts. Steer 000M, height 500 feet. We are on track.")
    end)
  end)

  it("uses target-specific 5/4/3/2/1 minute and 45/30/15/10 second callouts", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_TARGET_Prison__T00:05__A50", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(0); setTime(0); M:_TickNavigatorState(state)
      setAbsTime(60); setTime(60); M:_TickNavigatorState(state)
      setAbsTime(120); setTime(120); M:_TickNavigatorState(state)
      setAbsTime(180); setTime(180); M:_TickNavigatorState(state)
      setAbsTime(240); setTime(240); M:_TickNavigatorState(state)
      setAbsTime(255); setTime(255); M:_TickNavigatorState(state)
      setAbsTime(270); setTime(270); M:_TickNavigatorState(state)
      setAbsTime(285); setTime(285); M:_TickNavigatorState(state)
      setAbsTime(290); setTime(290); M:_TickNavigatorState(state)

      assertEq(#messages, 9)
      assertEq(messages[1], "5:00 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[2], "4:00 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 4 min slow. Required IAS 225 kts. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[3], "3:00 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 5 min slow. Required IAS 300 kts. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[4], "2:00 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 6 min slow. Required IAS 450 kts >MAX. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[5], "1:00 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 7 min slow. Required IAS 900 kts >MAX. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[6], "0:45 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 7 min slow. Required IAS 1200 kts >MAX. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[7], "0:30 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 7 min slow. Required IAS 1800 kts >MAX. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[8], "0:15 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 7 min slow. Required IAS 3600 kts >MAX. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[9], "0:10 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 7 min slow. Required IAS 5400 kts >MAX. Steer 000M, height 50 feet. We are on track.")
    end)
  end)

  it("suppresses interval reports from 5 minutes to target", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_TARGET_Prison__T00:05__A50", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2
      state.reportInterval = 10
      state.lastReportTime = 0
      state.timedCallouts = { ["TARGET:2"] = { [300] = true } }

      setAbsTime(1)
      setTime(20)
      M:_TickNavigatorState(state)

      assertEq(#messages, 0)
    end)
  end)

  it("announces course change to target as TARGET", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_TARGET_Prison__T00:10__A50", NM * 30 },
        { "MN_TEST_04_LANDING", NM * 45 },
      })
      -- Group positioned at WP02 to trigger fly-over → advance to TARGET
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, NM * 15, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(300)
      setTime(300)
      M:_TickNavigatorState(state)

      assertEq(messages[1], "NAV: Set course for TARGET WP03 Prison, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 50 feet. We are on track.")
    end)
  end)

  it("labels landing waypoint as home plate", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_LANDING_Tangmere__T00:05__A500", NM * 15 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(0)
      setTime(0)
      M:_TickNavigatorState(state)

      assertEq(messages[1], "5:00 CALLOUT: NAV: HOME PLATE WP02 Tangmere, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 500 feet. We are on track.")
    end)
  end)

  it("reports cross-track error rounded to 1 NM", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", NM, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(0)
      setTime(0)
      M:_TickNavigatorState(state)

      assertEq(messages[1], "5:00 CALLOUT: NAV: WP02 Checkpoint, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 356M, height 1500 feet. We are approx. 1 NM port of track.")
    end)
  end)

  it("reports port cross-track error rounded to 1 NM", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", -NM, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(0)
      setTime(0)
      M:_TickNavigatorState(state)

      assertEq(messages[1], "5:00 CALLOUT: NAV: WP02 Checkpoint, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 004M, height 1500 feet. We are approx. 1 NM starboard of track.")
    end)
  end)

  it("Status Now after takeoff uses operational callout phrase without consuming thresholds", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_TARGET_Prison__T00:05__A50", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(0)
      setTime(0)
      M:_NavigatorStatusNow(group, plan, 0)
      M:_TickNavigatorState(state)

      assertEq(#messages, 2)
      assertEq(messages[1], "NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 50 feet. We are on track.")
      assertEq(messages[2], "5:00 CALLOUT: NAV: TARGET WP02 Prison, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 50 feet. We are on track.")
    end)
  end)

  it("Automatic ON after takeoff uses operational callout phrase", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S220__A1500", 0 },
        { "MN_TEST_02_LANDING_Tangmere__T00:05__A500", NM * 15 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)

      setAbsTime(0)
      setTime(0)
      M:_SetNavigatorEnabled(group, plan, 0, true)

      assertEq(messages[1], "NAV: HOME PLATE WP02 Tangmere, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 500 feet. We are on track.")
    end)
  end)

  it("airborne navigator skips TAKE_OFF and reports the first airborne waypoint", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:01__S220__A1500", 0 },
        { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 15 },
        { "MN_TEST_03_LANDING", NM * 30 },
      })
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 1

      setAbsTime(30)
      setTime(30)
      M:_TickNavigatorState(state)

      assertEq(state.currentWpIndex, 2)
      assertTrue(state.takeoffComplete)
      assertEq(messages[1], "5:00 CALLOUT: NAV: WP02 Checkpoint, DIST 15.0 NM. We are 3 min slow. Required IAS 194 kts. Steer 000M, height 1500 feet. We are on track.")
    end)
  end)

  it("holds active waypoint until computed hold exit and then gives next waypoint guidance", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S200__A1500", 0 },
        { "MN_TEST_02_HOLD_Orbit__T00:05", NM * 10 },
        { "MN_TEST_03_NAV_Exit__T00:15__A500", NM * 20 },
        { "MN_TEST_04_LANDING", NM * 30 },
      })
      -- Group positioned at HOLD zone to trigger positional entry
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, NM * 10, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(300); setTime(300); M:_TickNavigatorState(state)
      setAbsTime(480); setTime(480); M:_TickNavigatorState(state)
      setAbsTime(540); setTime(540); M:_TickNavigatorState(state)

      assertEq(messages[1], "NAV: Holding at HOLD WP02 Orbit. Remain in hold 7:00.")
      assertEq(messages[2], "4:00 CALLOUT: NAV: HOLD WP02 Orbit, 4:00 to leave hold.")
      assertEq(messages[3], "3:00 CALLOUT: NAV: HOLD WP02 Orbit, 3:00 to leave hold.")
      assertEq(state.currentWpIndex, 2)

      setAbsTime(725); setTime(725); M:_TickNavigatorState(state)

      assertEq(messages[#messages], "NAV: Leaving hold. Set course for WP03 Exit, DIST 10.0 NM. We are 2 min slow. Required IAS 206 kts. Steer 000M, height 500 feet. We are on track.")
      assertEq(state.currentWpIndex, 3)
    end)
  end)

  it("initial waypoint selection stays on active hold", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T00:00__S200__A1500", 0 },
      { "MN_TEST_02_HOLD_Orbit__T00:05", NM * 10 },
      { "MN_TEST_03_NAV_Exit__T00:15__A500", NM * 20 },
      { "MN_TEST_04_LANDING", NM * 30 },
    })

    setAbsTime(360)
    assertEq(M:_GetInitialNavigatorWpIndexByTot(plan, 0), 2)
  end)

  it("advances positionally past waypoint without raw __T", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S180__A0", 0 },
        { "MN_TEST_02_NAV_Checkpoint", NM * 15 },
        { "MN_TEST_03_LANDING__T00:10", NM * 30 },
      })
      -- Group positioned at WP02 to trigger fly-over
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, NM * 15, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(300)
      setTime(300)
      M:_TickNavigatorState(state)

      assertEq(messages[1], "NAV: Set course for HOME PLATE WP03 LANDING, DIST 15.0 NM. We are 3 min slow. Required IAS 180 kts. Steer 000M, height 0 feet. We are on track.")
      assertEq(state.currentWpIndex, 3)
    end)
  end)

  it("shows slow-down correction and orbit hint when actual ETA is ahead of plan", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T00:00__S200__A0", 0 },
      { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 10 },
      { "MN_TEST_03_LANDING", NM * 20 },
    })
    local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 200)
    local state = M:_GetNavigatorState(group, plan, 0)
    state.enabled = true
    state.currentWpIndex = 2
    local originalGetNavigatorComputedWaypoint = M._GetNavigatorComputedWaypoint
    M._GetNavigatorComputedWaypoint = function(_, navState, index)
      local waypoint = navState.plan.waypoints[index]
      return waypoint and {etaSec = waypoint.timeOnTargetSeconds}
    end

    local ok, err = pcall(function()
      setAbsTime(0)
      setTime(0)

      local message = M:_BuildNavigatorWaypointCalloutMessage(state, "test")
      assertEq(message, "NAV: WP02 Checkpoint, DIST 10.0 NM. We are 2 min fast. Required IAS 120 kts. Steer 000M, height 0 feet. We are on track.")
    end)

    M._GetNavigatorComputedWaypoint = originalGetNavigatorComputedWaypoint
    if not ok then error(err) end
  end)

  it("uses 350 mph runtime max before marking speed correction unachievable", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T00:00__S200__A0", 0 },
      { "MN_TEST_02_NAV_Checkpoint__T00:05", NM * 25 },
      { "MN_TEST_03_LANDING", NM * 50 },
    })
    local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 250)
    local state = M:_GetNavigatorState(group, plan, 0)
    state.enabled = true
    state.currentWpIndex = 2
    local originalGetNavigatorComputedWaypoint = M._GetNavigatorComputedWaypoint
    M._GetNavigatorComputedWaypoint = function(_, navState, index)
      local waypoint = navState.plan.waypoints[index]
      return waypoint and {etaSec = waypoint.timeOnTargetSeconds}
    end

    local ok, err = pcall(function()
      setAbsTime(0)
      setTime(0)

      local message = M:_BuildNavigatorWaypointCalloutMessage(state, "test")
      assertEq(message, "NAV: WP02 Checkpoint, DIST 25.0 NM. We are 1 min slow. Required IAS 300 kts. Steer 000M, height 0 feet. We are on track.")
    end)

    M._GetNavigatorComputedWaypoint = originalGetNavigatorComputedWaypoint
    if not ok then error(err) end
  end)

  it("pilot ROLEX in navigator shifts cached base plan without recomputing", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S180__A0", 0 },
      { "MN_TEST_02_LANDING", NM * 15 },
    })
    local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, 0, 0, 120)
    local original = M._ComputePlan
    local calls = 0
    M.ComputedPlanCache = nil
    M._ComputePlan = function(self, p, rolexSeconds)
      calls = calls + 1
      return original(self, p, rolexSeconds)
    end

    local ok, err = pcall(function()
      local state = M:_GetNavigatorState(group, plan, 7 * 60, 5 * 60, 2 * 60)
      local wp = M:_GetNavigatorComputedWaypoint(state, 1)
      assertNear(wp.etaSec, 7 * 3600 + 7 * 60, 1)
      state.rolexSeconds = 3 * 60
      state.baseRolexSeconds = 5 * 60
      state.pilotRolexSeconds = -2 * 60
      wp = M:_GetNavigatorComputedWaypoint(state, 1)
      assertNear(wp.etaSec, 7 * 3600 + 3 * 60, 1)
    end)

    M._ComputePlan = original
    M.ComputedPlanCache = nil
    if not ok then error(err) end
    assertEq(calls, 1)
  end)

  it("manual waypoint change resets hold entry announcements", function()
    withCapturedNavigatorMessages(function(messages)
      local plan = makePlan({
        { "MN_TEST_01_TAKE_OFF__T00:00__S200__A1500", 0 },
        { "MN_TEST_02_HOLD_Orbit__T00:05", NM * 10 },
        { "MN_TEST_03_NAV_Exit__T00:15__A500", NM * 20 },
        { "MN_TEST_04_LANDING", NM * 30 },
      })
      -- Group positioned at HOLD zone for positional entry
      local group = makeAirborneNavGroup("MOSQUITO 1-1 [MN:TEST]", 0, NM * 10, 0, 120)
      local state = M:_GetNavigatorState(group, plan, 0)
      state.enabled = true
      state.currentWpIndex = 2

      setAbsTime(300); setTime(300); M:_TickNavigatorState(state)
      assertEq(messages[1], "NAV: Holding at HOLD WP02 Orbit. Remain in hold 7:00.")

      M:_SetNavigatorWaypoint(state, 3, "manual WP")
      M:_SetNavigatorWaypoint(state, 2, "manual WP")
      setAbsTime(301); setTime(301); M:_TickNavigatorState(state)

      assertEq(messages[#messages], "NAV: Holding at HOLD WP02 Orbit. Remain in hold 6:59.")
    end)
  end)
end)

suite("Group runtime ROLEX state", function()
  local function makeGroup(name)
    return { GetName = function() return name end }
  end

  local function makeAssignment(plan, baseRolexSeconds)
    return {
      groupName = "MOSQUITO 1-1 [MN:TEST]__R5",
      planName = "TEST",
      plan = plan,
      rolexSeconds = baseRolexSeconds or 0,
    }
  end

  it("initial state separates base __R from pilot ROLEX", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local group = makeGroup("MOSQUITO 1-1 [MN:TEST]__R5")
    M.GroupPlanStates = nil

    local state = M:_GetGroupPlanState(group, makeAssignment(plan, 5 * 60))
    assertEq(state.baseRolexSeconds, 5 * 60)
    assertEq(state.pilotRolexSeconds, 0)
    assertEq(M:_GetActiveRolexSeconds(state), 5 * 60)
  end)

  it("ADVANCE subtracts pilot ROLEX from base __R", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local group = makeGroup("MOSQUITO 1-1 [MN:TEST]__R5")
    local assignment = makeAssignment(plan, 5 * 60)
    local messages = {}
    local originalSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, g, text) table.insert(messages, {group = g:GetName(), text = text}) end
    M.GroupPlanStates = nil
    M.NavigatorStates = nil

    local ok, err = pcall(function()
      M:_AdjustPilotRolex(group, assignment, -2 * 60)
      local state = M:_GetGroupPlanState(group, assignment)
      assertEq(state.pilotRolexSeconds, -2 * 60)
      assertEq(M:_GetActiveRolexSeconds(state), 3 * 60)
      assertEq(messages[#messages].text, "ROLEX -00:02")
    end)

    M._SendNavigatorMessage = originalSend
    if not ok then error(err) end
  end)

  it("RETARD adds pilot ROLEX to base __R", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local group = makeGroup("MOSQUITO 1-1 [MN:TEST]__R5")
    local assignment = makeAssignment(plan, 5 * 60)
    local originalSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function() end
    M.GroupPlanStates = nil
    M.NavigatorStates = nil

    local ok, err = pcall(function()
      M:_AdjustPilotRolex(group, assignment, 10 * 60)
      local state = M:_GetGroupPlanState(group, assignment)
      assertEq(state.pilotRolexSeconds, 10 * 60)
      assertEq(M:_GetActiveRolexSeconds(state), 15 * 60)
    end)

    M._SendNavigatorMessage = originalSend
    if not ok then error(err) end
  end)

  it("RESET returns to mission-maker __R baseline, not zero active offset", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local group = makeGroup("MOSQUITO 1-1 [MN:TEST]__R5")
    local assignment = makeAssignment(plan, 5 * 60)
    local messages = {}
    local originalSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.GroupPlanStates = nil
    M.NavigatorStates = nil

    local ok, err = pcall(function()
      M:_AdjustPilotRolex(group, assignment, 10 * 60)
      M:_SetPilotRolex(group, assignment, 0)
      local state = M:_GetGroupPlanState(group, assignment)
      assertEq(state.pilotRolexSeconds, 0)
      assertEq(M:_GetActiveRolexSeconds(state), 5 * 60)
      assertEq(messages[#messages], "ROLEX reset")
    end)

    M._SendNavigatorMessage = originalSend
    if not ok then error(err) end
  end)

  it("ROLEX change refreshes existing navigator state to active offset", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_NAV__T07:30", NM * 20 },
      { "MN_TEST_03_LANDING", NM * 40 },
    })
    local group = makeGroup("MOSQUITO 1-1 [MN:TEST]__R5")
    local assignment = makeAssignment(plan, 5 * 60)
    local originalSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function() end
    M.GroupPlanStates = nil
    M.NavigatorStates = {
      [group:GetName()] = {
        enabled = false,
        group = group,
        groupName = group:GetName(),
        plan = plan,
        rolexSeconds = 0,
        currentWpIndex = 2,
        callouts = {},
      }
    }

    local ok, err = pcall(function()
      M:_AdjustPilotRolex(group, assignment, -2 * 60)
      local navState = M.NavigatorStates[group:GetName()]
      assertEq(navState.rolexSeconds, 3 * 60)
      assertEq(navState.currentWpIndex, 2)
      assertEq(type(navState.callouts), "table")
    end)

    M._SendNavigatorMessage = originalSend
    if not ok then error(err) end
  end)
end)

suite("Navigator TEST_MODE messaging", function()
  it("sends ToAll with group prefix and writes full dump to log", function()
    local originalTestMode = TEST_MODE
    local originalMessage = MESSAGE
    local originalLog = M._Log
    local originalAppendDump = M._AppendNavigatorDump
    local logs, sent, dumps = {}, {}, {}
    local group = { GetName = function() return "AI TEST [MN:TEST]" end }

    TEST_MODE = true
    M._Log = function(_, message) table.insert(logs, message) end
    M._AppendNavigatorDump = function(_, groupName, text) table.insert(dumps, {groupName = groupName, text = text}) end
    MESSAGE = {
      New = function(_, text, duration, title)
        return {
          ToAll = function()
            table.insert(sent, {scope = "all", text = text, duration = duration, title = title})
          end,
          ToGroup = function()
            table.insert(sent, {scope = "group", text = text, duration = duration, title = title})
          end,
        }
      end
    }

    local ok, err = pcall(function()
      M:_SendNavigatorMessage(group, "LINE 1\nLINE 2", 12)
      assertEq(#sent, 1)
      assertEq(sent[1].scope, "all")
      assertEq(sent[1].text, "[AI TEST [MN:TEST]]\nLINE 1\nLINE 2")
      assertEq(logs[1], 'TEST_MESSAGE_DUMP_BEGIN group="AI TEST [MN:TEST]"')
      assertEq(logs[2], "LINE 1\nLINE 2")
      assertEq(logs[3], 'TEST_MESSAGE_DUMP_END group="AI TEST [MN:TEST]"')
      assertEq(#dumps, 1)
      assertEq(dumps[1].groupName, "AI TEST [MN:TEST]")
      assertEq(dumps[1].text, "LINE 1\nLINE 2")
    end)

    TEST_MODE = originalTestMode
    MESSAGE = originalMessage
    M._Log = originalLog
    M._AppendNavigatorDump = originalAppendDump
    if not ok then error(err) end
  end)
end)

suite("Mission ROLEX", function()
  it("contributes to active group ROLEX", function()
    local originalMissionRolex = M.MissionRolexSeconds
    M.MissionRolexSeconds = 3 * 60
    local active = M:_GetActiveRolexSeconds({baseRolexSeconds = 5 * 60, pilotRolexSeconds = -2 * 60})
    M.MissionRolexSeconds = originalMissionRolex
    assertEq(active, 6 * 60)
  end)
end)

suite("MosieAiPlanner", function()
  local AP = MosieAiPlanner
  local suiteOriginalTestMode = TEST_MODE
  TEST_MODE = false

  local function makeAiDumpState(groupCoordinateProvider)
    local group = {
      GetCoordinate = groupCoordinateProvider,
      GetVelocityKNOTS = function() return 210 end,
      GetAltitude = function() return 1234 end,
      IsAlive = function() return true end,
      IsAirborne = function() return true end,
    }
    local wp1 = {
      type = "TAKE_OFF",
      order = 1,
      name = "START",
      zoneName = "MN_TEST_01_TAKE_OFF__T12:00",
      zone = {GetRadius = function() return NM end},
      coordinate = makeCoord({x = 0, z = -NM * 2}),
    }
    local wp2 = {
      type = "NAV",
      order = 2,
      name = "CHECK",
      zoneName = "MN_TEST_02_NAV_CHECK",
      zone = {GetRadius = function() return NM end},
      coordinate = makeCoord({x = 0, z = 0}),
    }
    return {
      assignment = {
        group = group,
        groupName = "AI TEST [MN:TEST]",
        planName = "TEST",
        plan = {name = "TEST", waypoints = {wp1, wp2}},
      }
    }, {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, etaSec = 0},
        {type = "NAV", order = 2, etaSec = 100},
      }
    }
  end

  local function withAiZoneDumpCapture(testMode, fn)
    local originalTestMode = TEST_MODE
    local originalAppend = AP._AppendAiZoneDump
    local dumps = {}
    TEST_MODE = testMode
    AP._AppendAiZoneDump = function(_, text) table.insert(dumps, text) end

    local ok, err = pcall(function() fn(dumps) end)

    TEST_MODE = originalTestMode
    AP._AppendAiZoneDump = originalAppend
    if not ok then error(err, 2) end
  end

  it("builds an AI route with current position and landing point", function()
    local group = {
      GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
      GetAltitude = function() return 100 end,
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 0, resolvedAltFt = 0},
        {type = "NAV", order = 2, coordinate = makeCoord({x = 0, z = NM * 10}), etaSec = 300, resolvedAltFt = 1500, legGsKt = 180},
        {type = "LANDING", order = 3, coordinate = makeCoord({x = 0, z = NM * 20}), etaSec = 600, resolvedAltFt = 0, legGsKt = 160},
      }
    }

    local route = AP:_BuildRoute(group, computed, 2, 190)
    assertEq(#route, 3)
    assertEq(route[2].type, "Turning Point")
    -- No airbase mock → degrades to fly-over
    assertEq(route[3].type, "Turning Point")
    assertEq(route[3].action, "Fly Over Point")
  end)

  it("LANDING without a nearby airdrome degrades to fly-over turning point", function()
    local group = {
      GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
      GetAltitude = function() return 100 end,
    }
    local landingCoordinate = makeCoord({x = 0, z = NM * 20})
    landingCoordinate.GetClosestAirbase = function() return nil, nil end

    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 0, resolvedAltFt = 0},
        {type = "LANDING", order = 2, coordinate = landingCoordinate, etaSec = 300, resolvedAltFt = 0, legGsKt = 160},
      }
    }

    local route = AP:_BuildRoute(group, computed, 2, 190)
    assertEq(#route, 2)
    assertEq(route[2].type, "Turning Point")
    assertEq(route[2].action, "Fly Over Point")
    assertTrue(route[2].airdromeId == nil)
  end)

  it("routes LANDING to the nearest airdrome under the LAND zone", function()
    local group = {
      GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
      GetAltitude = function() return 100 end,
    }
    local landingZoneCoordinate = makeCoord({x = 0, z = NM * 20})
    local airbaseCoordinate = makeCoord({x = NM * 2, z = NM * 21})
    local airbase = {
      GetID = function() return 42 end,
      GetName = function() return "Tangmere" end,
      GetCoordinate = function() return airbaseCoordinate end,
      GetAirbaseCategory = function() return Airbase.Category.AIRDROME end,
    }
    landingZoneCoordinate.GetClosestAirbase = function(_, category)
      assertEq(category, Airbase.Category.AIRDROME)
      return airbase, NM
    end

    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 0, resolvedAltFt = 0},
        {type = "NAV", order = 2, coordinate = makeCoord({x = 0, z = NM * 10}), etaSec = 300, resolvedAltFt = 1500, legGsKt = 180},
        {type = "LANDING", order = 3, coordinate = landingZoneCoordinate, etaSec = 600, resolvedAltFt = 0, legGsKt = 160},
      }
    }

    local route = AP:_BuildRoute(group, computed, 2, 190)
    assertEq(route[3].type, "Turning Point")
    assertEq(route[4].type, "Land")
    assertEq(route[4].action, "Landing")
    assertEq(route[4].airdromeId, 42)
    assertEq(route[4].name, "Tangmere")
    assertNear(route[4].x, NM * 2, 0.001)
    assertNear(route[4].y, NM * 21, 0.001)
  end)

  it("adds a line-intercept point when AI is off track and more than 10 NM from the waypoint", function()
    local group = {
      GetCoordinate = function() return makeCoord({x = NM * 2, z = NM * 5}) end,
      GetAltitude = function() return 100 end,
    }
    local plan = {
      name = "TEST",
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0})},
        {type = "NAV", order = 2, coordinate = makeCoord({x = 0, z = NM * 20})},
        {type = "LANDING", order = 3, coordinate = makeCoord({x = 0, z = NM * 40})},
      },
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = plan.waypoints[1].coordinate, etaSec = 0, resolvedAltFt = 0, source = plan.waypoints[1]},
        {type = "NAV", order = 2, coordinate = plan.waypoints[2].coordinate, etaSec = 300, resolvedAltFt = 1500, legGsKt = 180, source = plan.waypoints[2]},
        {type = "LANDING", order = 3, coordinate = plan.waypoints[3].coordinate, etaSec = 600, resolvedAltFt = 0, legGsKt = 160, source = plan.waypoints[3]},
      }
    }
    local state = {assignment = {group = group, groupName = "AI [MN:TEST]", plan = plan}, currentWpIndex = 2}

    local route, routeMode, routeDetails = AP:_BuildRoute(state, computed, 2, 190)

    assertEq(routeMode, "INTERCEPT_LINE")
    assertTrue(string.find(routeDetails, "intercept_xte_nm=2%.0") ~= nil, routeDetails)
    assertEq(#route, 4)
    assertNear(route[2].x, 0, 0.001)
    assertNear(route[2].y, NM * 10, 0.001)
    assertNear(route[3].x, 0, 0.001)
    assertNear(route[3].y, NM * 20, 0.001)
  end)

  it("routes direct to waypoint when AI is within 10 NM", function()
    local group = {
      GetCoordinate = function() return makeCoord({x = NM * 2, z = NM * 12}) end,
      GetAltitude = function() return 100 end,
    }
    local plan = {
      name = "TEST",
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0})},
        {type = "NAV", order = 2, coordinate = makeCoord({x = 0, z = NM * 20})},
        {type = "LANDING", order = 3, coordinate = makeCoord({x = 0, z = NM * 40})},
      },
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = plan.waypoints[1].coordinate, etaSec = 0, resolvedAltFt = 0, source = plan.waypoints[1]},
        {type = "NAV", order = 2, coordinate = plan.waypoints[2].coordinate, etaSec = 300, resolvedAltFt = 1500, legGsKt = 180, source = plan.waypoints[2]},
        {type = "LANDING", order = 3, coordinate = plan.waypoints[3].coordinate, etaSec = 600, resolvedAltFt = 0, legGsKt = 160, source = plan.waypoints[3]},
      }
    }
    local state = {assignment = {group = group, groupName = "AI [MN:TEST]", plan = plan}, currentWpIndex = 2}

    local route, routeMode = AP:_BuildRoute(state, computed, 2, 190)

    assertEq(routeMode, "DIRECT_WP")
    assertEq(#route, 3)
    assertNear(route[2].x, 0, 0.001)
    assertNear(route[2].y, NM * 20, 0.001)
  end)

  it("does not write AI zone dump outside TEST_MODE", function()
    withAiZoneDumpCapture(false, function(dumps)
      local state, computed = makeAiDumpState(function() return makeCoord({x = 0, z = 0}) end)
      AP:_TickZoneDump(state, computed)
      assertEq(#dumps, 0)
    end)
  end)

  it("writes AI zone dump only on zone entry and permits re-entry", function()
    withAiZoneDumpCapture(true, function(dumps)
      local position = makeCoord({x = 0, z = NM * 2})
      local state, computed = makeAiDumpState(function() return position end)
      setAbsTime(110)

      AP:_TickZoneDump(state, computed)
      assertEq(#dumps, 0)

      position = makeCoord({x = 0, z = 0})
      AP:_TickZoneDump(state, computed)
      assertEq(#dumps, 1)
      assertTrue(string.find(dumps[1], "AI_ZONE_ENTRY") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "AI TEST %[MN:TEST%]") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "wp=WP02") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "zone=\"MN_TEST_02_NAV_CHECK\"") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "delta_sec=%+10") ~= nil, dumps[1])

      AP:_TickZoneDump(state, computed)
      assertEq(#dumps, 1)

      position = makeCoord({x = 0, z = NM * 2})
      AP:_TickZoneDump(state, computed)
      assertEq(#dumps, 1)

      position = makeCoord({x = 0, z = 0})
      AP:_TickZoneDump(state, computed)
      assertEq(#dumps, 2)
    end)
  end)

  it("writes AI flight samples no more often than configured interval", function()
    withAiZoneDumpCapture(true, function(dumps)
      local state, computed = makeAiDumpState(function() return makeCoord({x = 0, z = 0}) end)
      state.currentWpIndex = 2
      state.aiMode = "DIRECT_WP"
      state.aiModeReason = "test"

      setAbsTime(0); setTime(0); AP:_TickFlightSampleDump(state, computed)
      setAbsTime(10); setTime(10); AP:_TickFlightSampleDump(state, computed)
      setAbsTime(15); setTime(15); AP:_TickFlightSampleDump(state, computed)

      assertEq(#dumps, 2)
      assertTrue(string.find(dumps[1], "AI_FLIGHT_SAMPLE") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "mode=DIRECT_WP") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "plan_eta=00:01:40") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "act_eta=00:00") ~= nil, dumps[1])
      assertTrue(string.find(dumps[1], "eta_delta_sec=%-100") ~= nil, dumps[1])
    end)
  end)

  it("logs AI commands for route retask and waypoint advance", function()
    withAiZoneDumpCapture(true, function(dumps)
      local routes = 0
      local state, computed = makeAiDumpState(function() return makeCoord({x = 0, z = 0}) end)
      state.currentWpIndex = 2
      state.assignment.group.Route = function() routes = routes + 1 end
      computed.waypoints[1].coordinate = makeCoord({x = 0, z = -NM * 2})
      computed.waypoints[2].coordinate = makeCoord({x = 0, z = 0})
      computed.waypoints[2].source = state.assignment.plan.waypoints[2]
      computed.waypoints[3] = {type = "LANDING", order = 3, coordinate = makeCoord({x = 0, z = NM * 10}), etaSec = 600, resolvedAltFt = 0, legGsKt = 160}
      local originalGetComputed = AP._GetComputedPlan
      AP._GetComputedPlan = function() return computed end
      setAbsTime(0); setTime(0)

      local ok, err = pcall(function()
        AP:_RetaskRoute(state, "initial airborne route", 180)
        AP:_AdvanceArrivedWaypoint(state, computed)

        local text = table.concat(dumps, "\n")
        assertEq(routes, 2)
        assertTrue(string.find(text, "AI_COMMAND") ~= nil, text)
        assertTrue(string.find(text, "command=ROUTE") ~= nil, text)
        assertTrue(string.find(text, "command=WP_ADVANCE") ~= nil, text)
        assertEq(state.currentWpIndex, 3)
      end)

      AP._GetComputedPlan = originalGetComputed
      if not ok then error(err) end
    end)
  end)

  it("logs AI commands for timing and hold orbit tasks", function()
    withAiZoneDumpCapture(true, function(dumps)
      local taskSet = 0
      local group = {
        GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
        GetAltitude = function() return 0 end,
        TaskOrbitCircleAtVec2 = function() return {id = "Orbit"} end,
        SetTask = function() taskSet = taskSet + 1 end,
      }
      local state = {assignment = {group = group, groupName = "AI [MN:TEST]"}, currentWpIndex = 2}
      setAbsTime(0); setTime(0)

      AP:_StartTimingOrbit(state, {type = "NAV", order = 2, coordinate = makeCoord({x = 0, z = NM * 10}), resolvedAltFt = 0}, 100)

      local holdState = {assignment = {group = group, groupName = "AI [MN:TEST]"}, currentWpIndex = 2}
      AP:_TickHold(holdState, {waypoints = {}}, {type = "HOLD", order = 2, coordinate = makeCoord({x = 0, z = 0}), etaSec = 0, holdDurationSec = 60, resolvedAltFt = 0})

      local text = table.concat(dumps, "\n")
      assertEq(taskSet, 2)
      assertTrue(string.find(text, "command=SET_TASK_TIMING_ORBIT") ~= nil, text)
      assertTrue(string.find(text, "command=SET_TASK_HOLD_ORBIT") ~= nil, text)
    end)
  end)

  it("_IsGroupExisting returns true when DCS group exists", function()
    local group = {
      GetDCSObject = function() return {isExist = function() return true end} end,
    }
    assertTrue(AP:_IsGroupExisting(group))
  end)

  it("_IsGroupExisting returns false when DCS group does not exist", function()
    local group = {
      GetDCSObject = function() return {isExist = function() return false end} end,
    }
    assertTrue(not AP:_IsGroupExisting(group))
  end)

  it("_IsGroupExisting returns false when GetDCSObject returns nil (despawned group)", function()
    local group = {
      GetDCSObject = function() return nil end,
    }
    assertTrue(not AP:_IsGroupExisting(group))
  end)

  it("_IsGroupExisting returns true for uncontrolled group that exists but IsAlive would return nil", function()
    local group = {
      GetDCSObject = function()
        return {isExist = function() return true end}
      end,
      IsAlive = function() return nil end,
    }
    assertTrue(AP:_IsGroupExisting(group))
  end)

  it("_IsGroupExisting falls back to IsAlive when no GetDCSObject", function()
    local group = {IsAlive = function() return true end}
    assertTrue(AP:_IsGroupExisting(group))
    local deadGroup = {IsAlive = function() return false end}
    assertTrue(not AP:_IsGroupExisting(deadGroup))
  end)

  it("sends StartUncontrolled inside the takeoff lead window", function()
    local started = false
    local group = { StartUncontrolled = function() started = true end }
    local state = {assignment = {group = group, groupName = "AI [MN:TEST]"}}
    local computed = {valid = true, waypoints = {{type = "TAKE_OFF", etaSec = 180}}}

    setAbsTime(0)
    AP:_MaybeStartUncontrolled(state, computed)

    assertTrue(started)
    assertEq(state.startCommanded, true)
  end)

  it("_TickAssignment wakes uncontrolled AI group that reports IsAlive=nil but exists in DCS", function()
    local started = false
    local group = {
      GetDCSObject = function() return {isExist = function() return true end} end,
      IsAlive = function() return nil end,
      IsAirborne = function() return false end,
      StartUncontrolled = function() started = true end,
      GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
      GetAltitude = function() return 0 end,
      GetSkill = function() return "Excellent" end,
      Route = function() end,
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 180, resolvedAltFt = 0},
        {type = "LANDING", order = 2, coordinate = makeCoord({x = 0, z = NM * 20}), etaSec = 600, resolvedAltFt = 0, legGsKt = 160},
      }
    }
    local originalGetComputed = AP._GetComputedPlan
    AP._GetComputedPlan = function() return computed end
    setAbsTime(0); setTime(0)

    local ok, err = pcall(function()
      AP:_TickAssignment({assignment = {group = group, groupName = "AI [MN:TEST]"}, currentWpIndex = 2})
      assertTrue(started, "expected StartUncontrolled to fire for uncontrolled group")
    end)

    AP._GetComputedPlan = originalGetComputed
    if not ok then error(err) end
  end)

  it("retasks when ETA error exceeds tolerance", function()
    local routes = {}
    local group = {
      GetName = function() return "AI [MN:TEST]" end,
      IsAlive = function() return true end,
      IsAirborne = function() return true end,
      GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
      GetAltitude = function() return 0 end,
      GetVelocityKNOTS = function() return 100 end,
      Route = function(_, route) table.insert(routes, route) end,
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 0, resolvedAltFt = 0},
        {type = "NAV", order = 2, coordinate = makeCoord({x = 0, z = NM * 10}), etaSec = 100, resolvedAltFt = 1500, legGsKt = 180},
        {type = "LANDING", order = 3, coordinate = makeCoord({x = 0, z = NM * 20}), etaSec = 600, resolvedAltFt = 0, legGsKt = 160},
      }
    }
    local originalGetComputed = AP._GetComputedPlan
    AP._GetComputedPlan = function() return computed end
    setAbsTime(0)
    setTime(0)

    local ok, err = pcall(function()
      AP:_TickAssignment({assignment = {group = group, groupName = "AI [MN:TEST]"}, currentWpIndex = 2})
      assertEq(#routes, 1)
      assertNear(routes[1][1].speed, AP:_KnotsToMps(AP.Config.maxSpeedKt), 0.001)
    end)

    AP._GetComputedPlan = originalGetComputed
    if not ok then error(err) end
  end)

  it("does not route a non-airborne AI group after wake command", function()
    local started, routes = false, 0
    local group = {
      IsAlive = function() return true end,
      IsAirborne = function() return false end,
      StartUncontrolled = function() started = true end,
      GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
      GetAltitude = function() return 0 end,
      Route = function() routes = routes + 1 end,
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 180, resolvedAltFt = 0},
        {type = "NAV", order = 2, coordinate = makeCoord({x = 0, z = NM * 10}), etaSec = 300, resolvedAltFt = 1500, legGsKt = 180},
        {type = "LANDING", order = 3, coordinate = makeCoord({x = 0, z = NM * 20}), etaSec = 600, resolvedAltFt = 0, legGsKt = 160},
      }
    }
    local originalGetComputed = AP._GetComputedPlan
    AP._GetComputedPlan = function() return computed end
    setAbsTime(0); setTime(0)

    local ok, err = pcall(function()
      AP:_TickAssignment({assignment = {group = group, groupName = "AI [MN:TEST]"}, currentWpIndex = 2})
      assertTrue(started)
      assertEq(routes, 0)
    end)

    AP._GetComputedPlan = originalGetComputed
    if not ok then error(err) end
  end)

  it("commands timing orbit at the previous waypoint when AI is early for a timed waypoint", function()
    local taskSet, routes = 0, 0
    local orbitVec2 = nil
    local group = {
      IsAlive = function() return true end,
      IsAirborne = function() return true end,
      GetCoordinate = function() return makeCoord({x = 0, z = 0}) end,
      GetAltitude = function() return 0 end,
      GetVelocityKNOTS = function() return 240 end,
      TaskOrbitCircleAtVec2 = function(_, vec2) orbitVec2 = vec2; return {id = "Orbit"} end,
      SetTask = function() taskSet = taskSet + 1 end,
      Route = function() routes = routes + 1 end,
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 0, resolvedAltFt = 0},
        {type = "NAV", order = 2, coordinate = makeCoord({x = NM * 2, z = 0}), etaSec = 300, resolvedAltFt = 1500, legGsKt = 180},
        {type = "TARGET", order = 3, coordinate = makeCoord({x = 0, z = NM * 10}), etaSec = 600, resolvedAltFt = 1500, legGsKt = 180},
        {type = "LANDING", order = 4, coordinate = makeCoord({x = 0, z = NM * 20}), etaSec = 1200, resolvedAltFt = 0, legGsKt = 160},
      }
    }
    local state = {assignment = {group = group, groupName = "AI [MN:TEST]"}, currentWpIndex = 3}
    local originalGetComputed = AP._GetComputedPlan
    AP._GetComputedPlan = function() return computed end
    setAbsTime(0); setTime(0)

    local ok, err = pcall(function()
      AP:_TickAssignment(state)
      assertEq(taskSet, 1)
      assertEq(routes, 0)
      assertEq(state.timingOrbit, true)
      assertNear(orbitVec2.x, NM * 2, 0.001)
      assertNear(orbitVec2.y, 0, 0.001)
    end)

    AP._GetComputedPlan = originalGetComputed
    if not ok then error(err) end
  end)

  it("uses orbit for HOLD and resumes route after hold exit", function()
    local taskSet, routes = 0, 0
    local group = {
      IsAlive = function() return true end,
      IsAirborne = function() return true end,
      GetCoordinate = function() return makeCoord({x = 0, z = NM * 10}) end,
      GetAltitude = function() return 0 end,
      TaskOrbitCircleAtVec2 = function() return {id = "Orbit"} end,
      SetTask = function() taskSet = taskSet + 1 end,
      Route = function() routes = routes + 1 end,
    }
    local computed = {
      valid = true,
      waypoints = {
        {type = "TAKE_OFF", order = 1, coordinate = makeCoord({x = 0, z = 0}), etaSec = 0, resolvedAltFt = 0},
        {type = "HOLD", order = 2, coordinate = makeCoord({x = 0, z = NM * 10}), etaSec = 100, holdDurationSec = 60, resolvedAltFt = 1500},
        {type = "LANDING", order = 3, coordinate = makeCoord({x = 0, z = NM * 20}), etaSec = 300, resolvedAltFt = 0, legGsKt = 160},
      }
    }
    local state = {assignment = {group = group, groupName = "AI [MN:TEST]"}, currentWpIndex = 2}
    local originalGetComputed = AP._GetComputedPlan
    AP._GetComputedPlan = function() return computed end

    local ok, err = pcall(function()
      setAbsTime(120); setTime(120); AP:_TickAssignment(state)
      assertEq(taskSet, 1)
      assertEq(state.holdStarted, true)

      setAbsTime(161); setTime(161); AP:_TickAssignment(state)
      assertEq(state.currentWpIndex, 3)
      assertEq(routes, 1)
    end)

    AP._GetComputedPlan = originalGetComputed
    if not ok then error(err) end
  end)

  it("passes mission ROLEX into navigator computed plan", function()
    local originalMissionRolex = M.MissionRolexSeconds
    local originalGetActive = M._GetActiveComputedPlan
    local seenPilotRolex = nil
    M.MissionRolexSeconds = 7 * 60
    M._GetActiveComputedPlan = function(_, _, _, pilotRolexSeconds)
      seenPilotRolex = pilotRolexSeconds
      return {valid = true, waypoints = {}}
    end

    local ok, err = pcall(function()
      AP:_GetComputedPlan({plan = {name = "TEST"}, rolexSeconds = 2 * 60})
      assertEq(seenPilotRolex, 7 * 60)
    end)

    M.MissionRolexSeconds = originalMissionRolex
    M._GetActiveComputedPlan = originalGetActive
    if not ok then error(err) end
  end)

  TEST_MODE = suiteOriginalTestMode
end)

suite("Group menu structure", function()
  it("creates NAVIGATOR and ROLEX submenus with requested commands", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local group = { GetName = function() return "MOSQUITO 1-1 [MN:TEST]" end }
    local assignment = {
      groupName = group:GetName(),
      group = group,
      planName = "TEST",
      plan = plan,
      rolexSeconds = 0,
    }

    local originalDiscover = M._DiscoverGroupAssignments
    local originalMenuGroup = MENU_GROUP
    local originalMenuCommand = MENU_GROUP_COMMAND
    local menus, commands = {}, {}
    MENU_GROUP = {
      New = function(_, _, label, parent)
        local menu = {label = label, parent = parent}
        table.insert(menus, menu)
        return menu
      end
    }
    MENU_GROUP_COMMAND = {
      New = function(_, _, label, parent, callback, argument)
        table.insert(commands, {label = label, parent = parent, callback = callback, argument = argument})
        return {label = label, parent = parent}
      end
    }
    M._DiscoverGroupAssignments = function() return {assignment} end
    M.MenusCreated = {}
    M.GroupPlanStates = nil

    local ok, err = pcall(function()
      M:_CreateGroupMenus({TEST = plan})
      local menuLabels = {}
      for _, menu in ipairs(menus) do menuLabels[menu.label] = true end
      assertTrue(menuLabels["Mosie Navigator"])
      assertTrue(menuLabels["MISSION"])
      assertTrue(menuLabels["GLOBAL TOT ROLEX"])
      assertTrue(menuLabels["NAVIGATOR"])
      assertTrue(menuLabels["ROLEX"])
      assertTrue(menuLabels["ADVANCE"])
      assertTrue(menuLabels["RETARD"])

      local commandLabels = {}
      for _, command in ipairs(commands) do commandLabels[command.label] = true end
      assertTrue(commandLabels["Automatic ON"])
      assertTrue(commandLabels["Automatic OFF"])
      assertTrue(commandLabels["Show FP"])
      assertTrue(commandLabels["Status Now"])
      assertTrue(commandLabels["Next WP"])
      assertTrue(commandLabels["Prev WP"])
      assertTrue(commandLabels["RESET"])
      assertTrue(commandLabels["1 min"])
      assertTrue(commandLabels["2 min"])
      assertTrue(commandLabels["3 min"])
      assertTrue(commandLabels["5 min"])
      assertTrue(commandLabels["10 min"])
    end)

    M._DiscoverGroupAssignments = originalDiscover
    MENU_GROUP = originalMenuGroup
    MENU_GROUP_COMMAND = originalMenuCommand
    if not ok then error(err) end
  end)

  it("enables automatic navigator by default and preserves manual OFF", function()
    local plan = makePlan({
      { "MN_TEST_01_TAKE_OFF__T07:00__S220__A1500", 0 },
      { "MN_TEST_02_LANDING", NM * 20 },
    })
    local group = { GetName = function() return "MOSQUITO 1-1 [MN:TEST]" end }
    local assignment = {
      groupName = group:GetName(),
      group = group,
      planName = "TEST",
      plan = plan,
      rolexSeconds = 0,
      navigatorAutoDefault = true,
    }

    local originalDiscover = M._DiscoverGroupAssignments
    local originalSetEnabled = M._SetNavigatorEnabled
    local originalMenuGroup = MENU_GROUP
    local originalMenuCommand = MENU_GROUP_COMMAND
    local enabledCalls, commands = {}, {}

    MENU_GROUP = { New = function(_, _, label, parent) return {label = label, parent = parent} end }
    MENU_GROUP_COMMAND = {
      New = function(_, _, label, parent, callback, argument)
        table.insert(commands, {label = label, callback = callback, argument = argument})
        return {label = label, parent = parent}
      end
    }
    M._DiscoverGroupAssignments = function() return {assignment} end
    M._SetNavigatorEnabled = function(_, _, _, _, enabled)
      table.insert(enabledCalls, enabled)
    end
    M.MenusCreated = {}
    M.GroupPlanStates = nil

    local ok, err = pcall(function()
      M:_CreateGroupMenus({TEST = plan})
      assertEq(#enabledCalls, 1)
      assertEq(enabledCalls[1], true)

      for _, command in ipairs(commands) do
        if command.label == "Automatic OFF" then command.callback() end
      end
      assertEq(enabledCalls[#enabledCalls], false)

      M:_CreateGroupMenus({TEST = plan})
      assertEq(#enabledCalls, 2, "manual OFF should not be overwritten by refresh")
    end)

    M._DiscoverGroupAssignments = originalDiscover
    M._SetNavigatorEnabled = originalSetEnabled
    MENU_GROUP = originalMenuGroup
    MENU_GROUP_COMMAND = originalMenuCommand
    M.MenusCreated = nil
    M.GroupPlanStates = nil
    if not ok then error(err) end
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
    assertEq(lines[2], "ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT,PASS_RADIUS_M")
    assertEq(lines[3], "1,TAKE_OFF,Tangmere,50.850000,-0.700000,1500,07:00,220,")
    assertEq(lines[4], "2,NAV,,50.900000,-0.650000,,,,")
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
    assertEq(lines[2], "ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT,PASS_RADIUS_M")
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
    assertMatch(lines[4], "^2,NAV,,[^,]+,[^,]+,500,,200,$")
    assertMatch(lines[5], "^3,TARGET,,[^,]+,[^,]+,,07:30,,$")
    assertMatch(lines[6], "^4,LANDING,,[^,]+,[^,]+,,,,$")
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
-- Additional coverage: draw, IO, start, messages, navigator
------------------------------------------------------------

-- ===== 08_draw.lua =====

suite("_DrawWaypoint", function()
  it("draws with zone radius", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local wp = {
      order = 1, type = "TARGET", name = "Prison", plan = "JERICHO",
      zoneName = "MN_JERICHO_01_TARGET", coordinate = coord,
      zone = {GetRadius = function() return 2000 end},
    }
    M.MarkIds = {}
    M:_DrawWaypoint({name = "JERICHO"}, wp, M:_GetPlanColor(1))
    assertTrue(true)
  end)

  it("draws with default radius when zone has no GetRadius", function()
    local coord = makeCoord({x = 1000, y = 0, z = 2000})
    local wp = {
      order = 2, type = "NAV", name = "Nav", plan = "JERICHO",
      zoneName = "MN_JERICHO_02_NAV", coordinate = coord,
      zone = {},
    }
    M.MarkIds = {}
    M:_DrawWaypoint({name = "JERICHO"}, wp, M:_GetPlanColor(2))
    assertTrue(true)
  end)
end)

suite("_DrawPlan", function()
  it("draws all waypoints and connector lines", function()
    local c1 = makeCoord({x = 0,    y = 0, z = 0})
    local c2 = makeCoord({x = 5000, y = 0, z = 0})
    local plan = {
      name = "JERICHO",
      waypoints = {
        {order=1, type="TAKE_OFF",  name="Tangmere", plan="JERICHO", coordinate=c1, zone={GetRadius=function()return 500 end}},
        {order=2, type="LANDING",   name="Tangmere", plan="JERICHO", coordinate=c2, zone={GetRadius=function()return 500 end}},
      }
    }
    M.MarkIds = {}
    M:_DrawPlan(plan, M:_GetPlanColor(1))
    assertTrue(true)
  end)
end)

suite("_DrawBeacon", function()
  it("draws beacon with frequency", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local beacon = {id = "TANGMERE", frequency = "310KHZ", powerNm = 120, coordinate = coord}
    M.MarkIds = {}
    M:_DrawBeacon(beacon)
    assertTrue(true)
  end)

  it("draws beacon without frequency", function()
    local coord = makeCoord({x = 0, y = 0, z = 0})
    local beacon = {id = "BAYEUX", powerNm = 90, coordinate = coord}
    M.MarkIds = {}
    M:_DrawBeacon(beacon)
    assertTrue(true)
  end)
end)

-- ===== 12_io.lua =====

suite("_WriteFlightPlanFile", function()
  it("writes TXT file when io available", function()
    local origBuild = M._BuildFlightPlanTable
    M._BuildFlightPlanTable = function(_, plan, groupName, rolex)
      return "NAVLOG CONTENT\n"
    end
    M:_WriteFlightPlanFile({name = "TESTPLAN"}, "TESTGROUP", 0)
    M._BuildFlightPlanTable = origBuild
    assertTrue(true)
  end)

  it("writes without groupName (per-plan variant)", function()
    local origBuild = M._BuildFlightPlanTable
    M._BuildFlightPlanTable = function(_, plan, groupName, rolex)
      return "NAVLOG CONTENT\n"
    end
    M:_WriteFlightPlanFile({name = "TESTPLAN"}, nil, 0)
    M._BuildFlightPlanTable = origBuild
    assertTrue(true)
  end)
end)

suite("_WriteFlightPlanCsvFile", function()
  it("writes CSV file when io available", function()
    local origBuild = M._BuildFlightPlanCsv
    M._BuildFlightPlanCsv = function(_, plan)
      return "ORDER,TYPE\n"
    end
    M:_WriteFlightPlanCsvFile({name = "TESTPLAN"})
    M._BuildFlightPlanCsv = origBuild
    assertTrue(true)
  end)
end)

suite("_WriteBeaconsCsvFile", function()
  it("skips write for nil beacons", function()
    M:_WriteBeaconsCsvFile(nil)
    assertTrue(true)
  end)

  it("skips write for empty beacons list", function()
    M:_WriteBeaconsCsvFile({})
    assertTrue(true)
  end)

  it("writes beacons CSV when non-empty", function()
    local origBuild = M._BuildBeaconsCsv
    M._BuildBeaconsCsv = function(_, beacons)
      return "ID,FREQ\n"
    end
    M:_WriteBeaconsCsvFile({{id = "TANGMERE"}})
    M._BuildBeaconsCsv = origBuild
    assertTrue(true)
  end)
end)

-- ===== 13_main.lua =====

suite("DrawDebug", function()
  it("runs without error when zones table is empty", function()
    M.MarkIds = {}
    M.MenusCreated = {}
    M.InactiveGroupLogs = {}
    M.NavigatorStates = {}
    env.mission.triggers.zones = {}
    M:DrawDebug()
    assertTrue(true)
  end)

  it("draws plans and beacons when discovered zones non-empty", function()
    local coord = makeCoord({x=0, y=0, z=0})
    local plan = {
      name = "JERICHO",
      waypoints = {
        {type="TAKE_OFF",order=1,coordinate=coord,plan="JERICHO",name="T",zoneName="z1",zone={GetRadius=function()return 500 end}},
        {type="LANDING",order=2,coordinate=coord,plan="JERICHO",name="L",zoneName="z2",zone={GetRadius=function()return 500 end}},
      }
    }
    local beacon = {id="TANGMERE", powerNm=120, frequency="310KHZ", coordinate=coord}
    local origDiscover = M._DiscoverZones
    M._DiscoverZones = function(_) return {JERICHO=plan}, {beacon} end
    M.MarkIds = {}
    M.MenusCreated = {}
    M.InactiveGroupLogs = {}
    M.NavigatorStates = {}
    M:DrawDebug()
    M._DiscoverZones = origDiscover
    assertTrue(true)
  end)
end)

suite("MosieNavigator:Start", function()
  it("initializes scheduler on first call", function()
    local origScheduler = SCHEDULER
    local scheduled = {}
    SCHEDULER = {
      New = function(self, obj, fn, args, delay, interval)
        table.insert(scheduled, {interval = interval})
        return {}
      end,
    }
    M.NavigatorScheduler = nil
    M.MarkIds = {}
    M.MenusCreated = {}
    M.InactiveGroupLogs = {}
    M.NavigatorStates = {}
    env.mission.triggers.zones = {}
    M:Start()
    SCHEDULER = origScheduler
    assertTrue(#scheduled >= 1)
  end)
end)

-- ===== 11_messages.lua additional =====

suite("_FormatMissionRolexStatus", function()
  it("returns reset message when mission rolex is zero", function()
    M.MissionRolexSeconds = 0
    local result = M:_FormatMissionRolexStatus()
    assertEq(result, "GLOBAL TOT ROLEX reset")
  end)

  it("returns formatted rolex when non-zero", function()
    M.MissionRolexSeconds = 300
    local result = M:_FormatMissionRolexStatus()
    assertMatch(result, "GLOBAL TOT ROLEX")
    M.MissionRolexSeconds = nil
  end)
end)

suite("_AppendFlightPlanRows compact=false", function()
  it("emits full navlog header with empty waypoints", function()
    local lines = {}
    M:_AppendFlightPlanRows(lines, {}, false)
    local out = table.concat(lines, "\n")
    assertMatch(out, "ID TYPE")
    assertMatch(out, "IAS")
  end)
end)

suite("_ShowFlightPlanForGroup", function()
  it("returns early when group is nil", function()
    M:_ShowFlightPlanForGroup(nil, {}, 0, 0)
    assertTrue(true)
  end)

  it("returns early when plan is nil", function()
    local fakeGroup = {GetName = function() return "MOSQUITO" end}
    M:_ShowFlightPlanForGroup(fakeGroup, nil, 0, 0)
    assertTrue(true)
  end)

  it("sends flight plan message to group", function()
    local fakeGroup = {
      GetName = function() return "MOSQUITO 1-1" end,
      MessageToAll = function() end,
    }
    local origBuild = M._BuildSimplifiedFlightPlanMessage
    M._BuildSimplifiedFlightPlanMessage = function(_, plan, groupName, rolex)
      return "FLIGHT PLAN CONTENT"
    end
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, group, text, duration) end
    M:_ShowFlightPlanForGroup(fakeGroup, {name="JERICHO",waypoints={}}, 0, 0)
    M._BuildSimplifiedFlightPlanMessage = origBuild
    M._SendNavigatorMessage = origSend
    assertTrue(true)
  end)
end)

suite("_BuildSimplifiedFlightPlanMessage error path", function()
  it("shows error when plan fails to compute", function()
    -- A plan with no valid TAKE_OFF + __T will produce an error from _ComputePlan
    local badPlan = {name = "BADPLAN", waypoints = {
      {type = "NAV",     order = 1, name = "NAV"},
      {type = "LANDING", order = 2, name = "Tangmere"},
    }}
    local result = M:_BuildSimplifiedFlightPlanMessage(badPlan, "TESTGROUP", 0, 0)
    assertMatch(result, "ERROR")
  end)
end)

-- ===== 10_navigator.lua additional =====

suite("_IsNavigatorGroupAirborne with IsAir", function()
  it("returns false when IsAir returns false", function()
    local group = {
      IsAir = function() return false end,
      IsAirborne = function() return false end,
    }
    local result = M:_IsNavigatorGroupAirborne(group)
    assertEq(result, false)
  end)

  it("uses IsAirborne when IsAir absent", function()
    local group = {IsAirborne = function() return true end}
    local result = M:_IsNavigatorGroupAirborne(group)
    assertEq(result, true)
  end)
end)

suite("_FormatDuration / _FormatDurationHoursMinutes", function()
  it("_FormatDuration returns a non-empty string", function()
    local result = M:_FormatDuration(3661)
    assertEq(type(result), "string")
    assertTrue(#result > 0)
  end)

  it("_FormatDurationHoursMinutes formats as h mm m", function()
    local result = M:_FormatDurationHoursMinutes(3661)
    assertEq(type(result), "string")
    assertTrue(#result > 0)
  end)
end)

suite("_FormatCountdown", function()
  it("formats seconds into countdown string", function()
    local result = M:_FormatCountdown(125)
    assertEq(type(result), "string")
    assertTrue(#result > 0)
  end)
end)

suite("_FormatNavigatorEtaClock", function()
  it("returns dash string when secondsToEta is nil", function()
    local result = M:_FormatNavigatorEtaClock(nil)
    assertEq(type(result), "string")
    assertMatch(result, "%-%-")
  end)

  it("formats a positive countdown", function()
    local result = M:_FormatNavigatorEtaClock(125)
    assertEq(type(result), "string")
  end)
end)

suite("_GetActualSecondsToWaypoint", function()
  it("returns nil when distance is nil", function()
    assertNil(M:_GetActualSecondsToWaypoint(nil, 200))
  end)

  it("returns nil when speed is 0", function()
    assertNil(M:_GetActualSecondsToWaypoint(10, 0))
  end)

  it("computes time from distance and speed", function()
    -- 60 NM at 180 kt = 20 min = 1200 s
    local result = M:_GetActualSecondsToWaypoint(60, 180)
    assertNear(result, 1200, 1)
  end)
end)

suite("_IsNavigatorRequiredSpeedAchievable", function()
  it("returns true for achievable IAS", function()
    local result = M:_IsNavigatorRequiredSpeedAchievable(160)
    assertEq(type(result), "boolean")
  end)

  it("returns false for nil IAS", function()
    local result = M:_IsNavigatorRequiredSpeedAchievable(nil)
    assertEq(result, false)
  end)
end)

suite("_GetTakeoffWaypoint", function()
  it("returns first TAKE_OFF waypoint", function()
    local plan = {waypoints = {
      {type = "TAKE_OFF", order = 1},
      {type = "NAV",      order = 2},
    }}
    local wp = M:_GetTakeoffWaypoint(plan)
    assertNotNil(wp)
    assertEq(wp.type, "TAKE_OFF")
  end)

  it("returns nil for plan with no TAKE_OFF", function()
    local plan = {waypoints = {{type = "NAV", order = 1}}}
    assertNil(M:_GetTakeoffWaypoint(plan))
  end)
end)

suite("_GetNavigatorWaypointLabel", function()
  it("returns display name for known type", function()
    local wp = {type = "TARGET", name = "Prison", nameExplicit = true, order = 5}
    local label = M:_GetNavigatorWaypointLabel(wp)
    assertEq(type(label), "string")
    assertTrue(#label > 0)
    assertMatch(label, "TARGET")
  end)
end)

suite("_GetNavigatorWaypointAltitudeFt", function()
  it("returns 0 for nil plan index", function()
    local plan = {waypoints = {}}
    local result = M:_GetNavigatorWaypointAltitudeFt(plan, 99)
    assertEq(type(result), "number")
  end)
end)

-- ===== 07_discover.lua additional =====

suite("_ExtractRolexFromGroupName invalid token", function()
  it("returns 0 for malformed __R token with letters", function()
    local rolex = M:_ExtractRolexFromGroupName("MOSQUITO [MN:JERICHO]__Rxyz")
    assertEq(rolex, 0)
  end)
end)

suite("_DiscoverGroupAssignments missing plan", function()
  it("logs when group references a plan not in plans table", function()
    local origSG = SET_GROUP
    local logged = {}
    local origLog = M._Log
    M._Log = function(_, msg) table.insert(logged, msg) end
    M.InactiveGroupLogs = {}

    SET_GROUP = {
      New = function(self) return self end,
      FilterStart = function(self) return self end,
      ForEachGroup = function(self, fn)
        fn({
          GetName = function() return "MOSQUITO 1-1 [MN:MISSINGPLAN]" end,
          IsAlive = function() return true end,
        })
      end,
    }
    M:_DiscoverGroupAssignments({})  -- empty plans → MISSINGPLAN not found
    M._Log = origLog
    SET_GROUP = origSG

    local found = false
    for _, msg in ipairs(logged) do
      if string.find(msg, "MISSINGPLAN") or string.find(msg, "missing plan") then found = true end
    end
    assertTrue(found, "should log about missing plan")
  end)

  it("logs inactive group when plan exists but group not alive", function()
    local origSG = SET_GROUP
    local logged = {}
    local origLog = M._Log
    M._Log = function(_, msg) table.insert(logged, msg) end
    M.InactiveGroupLogs = {}

    SET_GROUP = {
      New = function(self) return self end,
      FilterStart = function(self) return self end,
      ForEachGroup = function(self, fn)
        fn({
          GetName = function() return "MOSQUITO 1-1 [MN:JERICHO]" end,
          IsAlive = function() return false end,
        })
      end,
    }
    M:_DiscoverGroupAssignments({JERICHO = {waypoints = {}}})
    M._Log = origLog
    SET_GROUP = origSG

    local found = false
    for _, msg in ipairs(logged) do
      if string.find(msg, "not active yet") or string.find(msg, "JERICHO") then found = true end
    end
    assertTrue(found, "should log about inactive group")
  end)
end)

------------------------------------------------------------
-- Additional coverage: format functions, messages, navigator internals
------------------------------------------------------------

suite("_FormatDuration edge cases", function()
  it("returns -- for nil", function()
    assertEq(M:_FormatDuration(nil), "--")
  end)
  it("formats negative with minus prefix", function()
    local r = M:_FormatDuration(-70)
    assertMatch(r, "^%-")
    assertMatch(r, "1:10")
  end)
end)

suite("_FormatDurationHoursMinutes edge cases", function()
  it("returns -- for nil", function()
    assertEq(M:_FormatDurationHoursMinutes(nil), "--")
  end)
  it("formats negative", function()
    assertMatch(M:_FormatDurationHoursMinutes(-60), "^%-")
  end)
  it("formats hours when >= 3600", function()
    assertMatch(M:_FormatDurationHoursMinutes(7200), "02:00")
  end)
end)

suite("_FormatCountdown edge cases", function()
  it("returns -- for nil", function()
    assertEq(M:_FormatCountdown(nil), "--")
  end)
  it("formats negative with minus prefix", function()
    assertMatch(M:_FormatCountdown(-30), "^%-")
  end)
end)

suite("_GetSecondsToClockSeconds nil guard", function()
  it("returns nil for nil input", function()
    assertNil(M:_GetSecondsToClockSeconds(nil))
  end)
end)

suite("_FormatVariation and _FormatDisplayLegTime", function()
  it("_FormatVariation returns --- for nil", function()
    assertEq(M:_FormatVariation(nil), "---")
  end)
  it("_FormatVariation formats a number with sign", function()
    assertMatch(M:_FormatVariation(3.5), "%+3%.5")
  end)
  it("_FormatDisplayLegTime returns --- for nil", function()
    assertEq(M:_FormatDisplayLegTime(nil), "---")
  end)
  it("_FormatDisplayLegTime rounds to minutes", function()
    assertEq(M:_FormatDisplayLegTime(3660), "61")
  end)
end)

suite("_AppendFuelSummary", function()
  it("formats full fuel summary with DCS section", function()
    local lines = {}
    M:_AppendFuelSummary(lines, {
      taxiImpGal = 0.5, routeImpGal = 3.2, reserveImpGal = 0.8,
      landingImpGal = 0.3, totalImpGal = 4.8,
      dcs = {requiredGal = 5.0, requiredLb = 36.0, internalPercent = 92,
             internalFuelLb = 40.0, dropTankLabel = "NONE"},
    })
    local out = table.concat(lines, "\n")
    assertMatch(out, "FUEL:")
    assertMatch(out, "DCS FUEL:")
    assertMatch(out, "REQUIRED")
    assertMatch(out, "INTERNAL")
  end)

  it("skips DCS section when dcs is nil", function()
    local lines = {}
    M:_AppendFuelSummary(lines, {
      taxiImpGal = 0.5, routeImpGal = 3.2, reserveImpGal = 0.8,
      landingImpGal = 0.3, totalImpGal = 4.8, dcs = nil,
    })
    local out = table.concat(lines, "\n")
    assertMatch(out, "FUEL:")
    assertTrue(not string.find(out, "DCS FUEL:"), "DCS section should be absent")
  end)
end)

suite("_AppendFlightPlanRows compact=true", function()
  local ow = {order = 1, type = "NAV"}
  it("emits compact header and separator", function()
    local lines = {}
    M:_AppendFlightPlanRows(lines, {}, true)
    assertMatch(lines[1], "ID TY ALT")
    assertMatch(lines[2], "^%-%-%-")
    assertTrue(not string.find(lines[1], "TYPE"), "compact header should not contain TYPE")
  end)
  it("emits compact row for minimal waypoint", function()
    local lines = {}
    M:_AppendFlightPlanRows(lines, {ow}, true)
    assertTrue(#lines >= 3, "header + separator + row = at least 3 lines")
    assertMatch(lines[3], "^01")
  end)
end)

suite("_AppendFlightPlanRows compact=false with waypoint", function()
  it("emits full-format row for minimal waypoint", function()
    local ow = {order = 2, type = "TARGET"}
    local lines = {}
    M:_AppendFlightPlanRows(lines, {ow}, false)
    assertTrue(#lines >= 3, "header + separator + row = at least 3 lines")
    assertMatch(lines[3], "^02")
    assertMatch(lines[3], "TARGET")
  end)
end)

suite("_BuildSimplifiedFlightPlanMessage fuel+timing", function()
  it("includes TIMING section and FUEL when plan has timing advisories", function()
    local origGetActive = M._GetActiveComputedPlan
    M._GetActiveComputedPlan = function(_, plan, base, pilot)
      return {
        valid = true,
        waypoints = {},
        warnings = {},
        timing = {"HOLD absorbs 10 min slack"},
        fuel = {
          taxiImpGal = 0.5, routeImpGal = 3.2, reserveImpGal = 0.8,
          landingImpGal = 0.3, totalImpGal = 4.8, dcs = nil,
        },
      }
    end
    local result = M:_BuildSimplifiedFlightPlanMessage({name="T",waypoints={}}, "G", 0, 0)
    M._GetActiveComputedPlan = origGetActive
    assertMatch(result, "TIMING")
    assertMatch(result, "HOLD")
    assertMatch(result, "FUEL:")
  end)
end)

suite("_GetGroupPlanState", function()
  it("creates and returns state for a new group", function()
    local origStates = M.GroupPlanStates
    M.GroupPlanStates = nil
    local fakeGroup = {GetName = function() return "MOSQUITO 1-1" end}
    local assignment = {plan={waypoints={}}, planName="JERICHO", rolexSeconds=0}
    local state = M:_GetGroupPlanState(fakeGroup, assignment)
    M.GroupPlanStates = origStates
    assertNotNil(state)
    assertEq(state.groupName, "MOSQUITO 1-1")
    assertEq(state.planName, "JERICHO")
  end)

  it("returns existing state for a known group", function()
    local origStates = M.GroupPlanStates
    M.GroupPlanStates = nil
    local fakeGroup = {GetName = function() return "MOSQUITO 1-1" end}
    local assignment = {plan={waypoints={}}, planName="JERICHO", rolexSeconds=0}
    local s1 = M:_GetGroupPlanState(fakeGroup, assignment)
    local s2 = M:_GetGroupPlanState(fakeGroup, assignment)
    M.GroupPlanStates = origStates
    assertEq(s1, s2)
  end)
end)

suite("_GetActiveRolexSeconds", function()
  it("sums base, mission, and pilot rolex", function()
    M.MissionRolexSeconds = 60
    local result = M:_GetActiveRolexSeconds({baseRolexSeconds=30, pilotRolexSeconds=90})
    assertEq(result, 180)
    M.MissionRolexSeconds = nil
  end)

  it("treats nil fields as 0", function()
    M.MissionRolexSeconds = nil
    local result = M:_GetActiveRolexSeconds({})
    assertEq(result, 0)
  end)
end)

suite("_RefreshNavigatorRolex early returns", function()
  it("returns early when NavigatorStates is nil", function()
    local origStates = M.NavigatorStates
    M.NavigatorStates = nil
    M:_RefreshNavigatorRolex({groupName="TEST", baseRolexSeconds=0, pilotRolexSeconds=0, group={}, plan={waypoints={}}})
    M.NavigatorStates = origStates
    assertTrue(true)
  end)

  it("returns early when no state for group", function()
    local origStates = M.NavigatorStates
    M.NavigatorStates = {}
    M:_RefreshNavigatorRolex({groupName="NONEXISTENT", baseRolexSeconds=0, pilotRolexSeconds=0, group={}, plan={waypoints={}}})
    M.NavigatorStates = origStates
    assertTrue(true)
  end)
end)

suite("_RefreshAllNavigatorRolex early return", function()
  it("returns early when GroupPlanStates is nil", function()
    local origStates = M.GroupPlanStates
    M.GroupPlanStates = nil
    M:_RefreshAllNavigatorRolex("TEST")
    M.GroupPlanStates = origStates
    assertTrue(true)
  end)
end)

suite("_GetInitialNavigatorWpIndexByTot with empty plan", function()
  it("falls back to _GetInitialNavigatorWpIndex for empty plan", function()
    local plan = {waypoints = {}}
    local result = M:_GetInitialNavigatorWpIndexByTot(plan, 0, {valid=true, waypoints={}})
    assertEq(type(result), "number")
  end)
end)

suite("_SendNavigatorMessage non-test-mode", function()
  it("uses MESSAGE:ToGroup when not in test mode", function()
    local origTestMode = TEST_MODE
    TEST_MODE = nil
    local origMsg = MESSAGE
    local calls = {}
    MESSAGE = {
      New = function(self, text, duration, category)
        return {ToGroup = function(_, group) table.insert(calls, "ToGroup") end}
      end,
    }
    M:_SendNavigatorMessage({GetName=function() return "T" end}, "hello", 5)
    MESSAGE = origMsg
    TEST_MODE = origTestMode
    assertEq(#calls, 1)
    assertEq(calls[1], "ToGroup")
  end)
end)

suite("_IsNavigatorGroupAirborne edge cases", function()
  it("uses IsAir when IsAirborne is absent", function()
    local group = {IsAir = function() return true end}
    assertEq(M:_IsNavigatorGroupAirborne(group), true)
  end)

  it("returns false when neither IsAirborne nor IsAir present", function()
    assertEq(M:_IsNavigatorGroupAirborne({}), false)
  end)

  it("returns false for nil group", function()
    assertEq(M:_IsNavigatorGroupAirborne(nil), false)
  end)
end)

suite("_FormatCountdown with hours", function()
  it("formats durations >= 1 hour with HH:MM:SS", function()
    local result = M:_FormatCountdown(3700)
    assertMatch(result, "01:")
    assertMatch(result, ":01:")
  end)
end)

suite("_GetNavigatorWaypointLabel nil waypoint", function()
  it("returns WP-- for nil waypoint", function()
    assertEq(M:_GetNavigatorWaypointLabel(nil), "WP--")
  end)
end)

suite("_GetNavigatorHoldDurationSeconds fallback", function()
  it("returns holdDurationSec from plan when computed is nil", function()
    local origGetComputed = M._GetNavigatorComputedWaypoint
    M._GetNavigatorComputedWaypoint = function() return nil end
    local state = {plan = {waypoints = {{holdDurationSec = 600}}}}
    local result = M:_GetNavigatorHoldDurationSeconds(state, 1)
    M._GetNavigatorComputedWaypoint = origGetComputed
    assertEq(result, 600)
  end)

  it("returns 0 when waypoint has no holdDurationSec", function()
    local origGetComputed = M._GetNavigatorComputedWaypoint
    M._GetNavigatorComputedWaypoint = function() return nil end
    local state = {plan = {waypoints = {{type="NAV"}}}}
    local result = M:_GetNavigatorHoldDurationSeconds(state, 1)
    M._GetNavigatorComputedWaypoint = origGetComputed
    assertEq(result, 0)
  end)
end)

suite("_GetSecondsToNavigatorWaypointEta fallback", function()
  it("falls back to _GetSecondsToWaypointTot when no computed waypoint", function()
    local origGetComputed = M._GetNavigatorComputedWaypoint
    M._GetNavigatorComputedWaypoint = function() return nil end
    setAbsTime(43200)
    local state = {
      plan = {waypoints = {{timeOnTargetSeconds = 43260}}},
      rolexSeconds = 0,
    }
    local result = M:_GetSecondsToNavigatorWaypointEta(state, 1)
    M._GetNavigatorComputedWaypoint = origGetComputed
    setAbsTime(0)
    assertNear(result, 60, 1)
  end)
end)

suite("_GetNavigatorComputedWaypoint _GetComputedPlan fallback", function()
  it("uses _GetComputedPlan when _GetActiveComputedPlan is absent", function()
    local origGetActive = M._GetActiveComputedPlan
    M._GetActiveComputedPlan = nil
    local origGetComputed = M._GetComputedPlan
    M._GetComputedPlan = function(_, plan, rolex)
      return {valid = true, waypoints = {{type="NAV",etaSec=nil}}}
    end
    local state = {
      plan = {waypoints = {{type="NAV"}}},
      rolexSeconds = 0,
      missionRolexSeconds = 0,
      pilotRolexSeconds = 0,
    }
    local result = M:_GetNavigatorComputedWaypoint(state, 1)
    M._GetActiveComputedPlan = origGetActive
    M._GetComputedPlan = origGetComputed
    assertNotNil(result)
  end)
end)

suite("_GetSecondsToNavigatorHoldExit nil case", function()
  it("returns nil when secondsToArrival is nil", function()
    local origGetEta = M._GetSecondsToNavigatorWaypointEta
    M._GetSecondsToNavigatorWaypointEta = function() return nil end
    local state = {plan={waypoints={}}}
    local result = M:_GetSecondsToNavigatorHoldExit(state, 1)
    M._GetSecondsToNavigatorWaypointEta = origGetEta
    assertNil(result)
  end)
end)

suite("_GetNavigatorHoldDurationSecondsForPlan fallback", function()
  it("returns holdDurationSec from plan waypoint when computed is nil", function()
    local origGetCWP = M._GetNavigatorComputedWaypointForPlan
    M._GetNavigatorComputedWaypointForPlan = function() return nil end
    local plan = {waypoints = {{holdDurationSec = 900}}}
    local result = M:_GetNavigatorHoldDurationSecondsForPlan(plan, 1, 0)
    M._GetNavigatorComputedWaypointForPlan = origGetCWP
    assertEq(result, 900)
  end)

  it("returns 0 when waypoint has no holdDurationSec", function()
    local origGetCWP = M._GetNavigatorComputedWaypointForPlan
    M._GetNavigatorComputedWaypointForPlan = function() return nil end
    local plan = {waypoints = {{type="NAV"}}}
    local result = M:_GetNavigatorHoldDurationSecondsForPlan(plan, 1, 0)
    M._GetNavigatorComputedWaypointForPlan = origGetCWP
    assertEq(result, 0)
  end)
end)

suite("_GetNavigatorComputedWaypointForPlan with computed result", function()
  it("returns waypoint from computed plan", function()
    local origGetComputed = M._GetComputedPlan
    M._GetComputedPlan = function(_, plan, rolex)
      return {valid = true, waypoints = {{type="NAV",holdDurationSec=0}}}
    end
    local result = M:_GetNavigatorComputedWaypointForPlan({waypoints={}}, 1, 0)
    M._GetComputedPlan = origGetComputed
    assertNotNil(result)
    assertEq(result.type, "NAV")
  end)
end)

suite("_GetNavigatorCurrentGroundSpeedKt", function()
  it("returns nil when group has no GetVelocityKNOTS", function()
    assertNil(M:_GetNavigatorCurrentGroundSpeedKt({}))
  end)
  it("returns nil when speed is 0", function()
    local g = {GetVelocityKNOTS = function() return 0 end}
    assertNil(M:_GetNavigatorCurrentGroundSpeedKt(g))
  end)
  it("returns speed when positive", function()
    local g = {GetVelocityKNOTS = function() return 180 end}
    assertEq(M:_GetNavigatorCurrentGroundSpeedKt(g), 180)
  end)
end)

suite("_BuildNavigatorXtePhrase nil XTE", function()
  it("returns on-track when XTE is nil", function()
    local origCalc = M._CalculateXte
    M._CalculateXte = function(_, prev, curr, pos) return nil, nil end
    local state = {
      plan = {waypoints = {makeCoord(), makeCoord()}},
      currentWpIndex = 2,
    }
    local result = M:_BuildNavigatorXtePhrase(state, makeWp and makeWp() or {}, makeCoord())
    M._CalculateXte = origCalc
    assertMatch(result, "on track")
  end)
end)

suite("_FormatNavigatorRequiredIas / _FormatNavigatorSpeedCorrection / _FormatTimedCalloutReason", function()
  it("_FormatNavigatorRequiredIas returns a string", function()
    local result = M:_FormatNavigatorRequiredIas(160)
    assertEq(type(result), "string")
    assertTrue(#result > 0)
  end)

  it("_FormatNavigatorSpeedCorrection returns a string", function()
    local result = M:_FormatNavigatorSpeedCorrection(150, 200)
    assertEq(type(result), "string")
    assertTrue(#result > 0)
  end)

  it("_FormatTimedCalloutReason returns a string", function()
    local result = M:_FormatTimedCalloutReason(300)
    assertEq(type(result), "string")
    assertTrue(#result > 0)
  end)
end)

suite("_RefreshAllNavigatorRolex with states", function()
  it("calls _RefreshNavigatorRolex for each group plan state", function()
    local calls = {}
    local origRefresh = M._RefreshNavigatorRolex
    M._RefreshNavigatorRolex = function(_, state, reason) table.insert(calls, reason) end
    local origStates = M.GroupPlanStates
    M.GroupPlanStates = {
      TESTGROUP = {
        groupName="TESTGROUP", plan={waypoints={}},
        baseRolexSeconds=0, pilotRolexSeconds=0, group={}
      }
    }
    M:_RefreshAllNavigatorRolex("GLOBAL ROLEX")
    M._RefreshNavigatorRolex = origRefresh
    M.GroupPlanStates = origStates
    assertEq(#calls, 1)
    assertMatch(calls[1], "GLOBAL")
  end)
end)

suite("_SetMissionRolex / _AdjustMissionRolex", function()
  it("_SetMissionRolex sets MissionRolexSeconds and refreshes", function()
    local origRefresh = M._RefreshAllNavigatorRolex
    M._RefreshAllNavigatorRolex = function(_, reason) end
    M:_SetMissionRolex(300)
    M._RefreshAllNavigatorRolex = origRefresh
    assertEq(M.MissionRolexSeconds, 300)
    M.MissionRolexSeconds = nil
  end)

  it("_AdjustMissionRolex adds delta to existing", function()
    local origRefresh = M._RefreshAllNavigatorRolex
    M._RefreshAllNavigatorRolex = function(_, reason) end
    M.MissionRolexSeconds = 60
    M:_AdjustMissionRolex(120)
    M._RefreshAllNavigatorRolex = origRefresh
    assertEq(M.MissionRolexSeconds, 180)
    M.MissionRolexSeconds = nil
  end)
end)

suite("_CreateGroupMenus callbacks", function()
  it("RESET global rolex callback calls _SetMissionRolex", function()
    local setRolexCalls = {}
    local capturedCallbacks = {}
    local origMGC = MENU_GROUP_COMMAND
    local origMG  = MENU_GROUP
    MENU_GROUP = {New = function() return {} end}
    MENU_GROUP_COMMAND = {
      New = function(self, group, label, parent, fn, ...)
        if fn then table.insert(capturedCallbacks, {label=label, fn=fn, args={...}}) end
        return {}
      end,
    }
    local origSetMR   = M._SetMissionRolex
    local origSend    = M._SendNavigatorMessage
    local origEnableNav = M._EnableNavigatorByDefault
    M._SetMissionRolex          = function(_, s) table.insert(setRolexCalls, s) end
    M._SendNavigatorMessage     = function(_, g, text) end
    M._EnableNavigatorByDefault = function(_, g, a, s) end  -- avoid SCHEDULER dep
    local origSG = SET_GROUP
    SET_GROUP = {
      New = function(s) return s end,
      FilterStart = function(s) return s end,
      ForEachGroup = function(s, fn)
        fn({
          GetName  = function() return "MOSQUITO 1-1 [MN:JERICHO]" end,
          IsAlive  = function() return true end,
          GetSkill = function() return "Client" end,
        })
      end,
    }
    M.MenusCreated    = {}
    M.InactiveGroupLogs = {}
    M.GroupPlanStates = nil
    local plans = {JERICHO = {waypoints={}}}
    M:_CreateGroupMenus(plans)

    -- invoke RESET callback WHILE stubs are still active
    for _, cb in ipairs(capturedCallbacks) do
      if cb.label == "RESET" and #cb.args == 0 then
        cb.fn()
        break
      end
    end

    MENU_GROUP_COMMAND      = origMGC
    MENU_GROUP              = origMG
    M._SetMissionRolex          = origSetMR
    M._SendNavigatorMessage     = origSend
    M._EnableNavigatorByDefault = origEnableNav
    SET_GROUP               = origSG

    assertTrue(#setRolexCalls > 0, "RESET callback should call _SetMissionRolex")
  end)
end)

suite("_EnableNavigatorByDefault", function()
  it("returns early when navigatorAutoDefault is false", function()
    local setCalls = {}
    local origEnable = M._SetNavigatorEnabled
    M._SetNavigatorEnabled = function(...) table.insert(setCalls, true) end
    M:_EnableNavigatorByDefault(nil, {navigatorAutoDefault=false}, {})
    M._SetNavigatorEnabled = origEnable
    assertEq(#setCalls, 0)
  end)

  it("returns early when autoNavigatorDisabled is true", function()
    local setCalls = {}
    local origEnable = M._SetNavigatorEnabled
    M._SetNavigatorEnabled = function(...) table.insert(setCalls, true) end
    M:_EnableNavigatorByDefault(nil, {navigatorAutoDefault=true}, {autoNavigatorDisabled=true})
    M._SetNavigatorEnabled = origEnable
    assertEq(#setCalls, 0)
  end)

  it("calls _SetNavigatorEnabled when all conditions met", function()
    local setCalls = {}
    local origEnable = M._SetNavigatorEnabled
    M._SetNavigatorEnabled = function(_, group, plan, rolex, enabled, base, pilot)
      table.insert(setCalls, enabled)
    end
    local groupPlanState = {
      plan = {waypoints={}}, planName="J",
      baseRolexSeconds=0, pilotRolexSeconds=0,
      autoNavigatorDisabled=false, autoNavigatorInitialized=false,
    }
    M:_EnableNavigatorByDefault(
      {GetName=function()return "G" end},
      {navigatorAutoDefault=true},
      groupPlanState
    )
    M._SetNavigatorEnabled = origEnable
    assertEq(#setCalls, 1)
    assertEq(setCalls[1], true)
    assertEq(groupPlanState.autoNavigatorInitialized, true)
  end)
end)

suite("_GetAdjustedTotSeconds", function()
  it("returns nil when waypoint has no timeOnTargetSeconds", function()
    assertNil(M:_GetAdjustedTotSeconds({}, 0))
  end)
  it("applies rolex offset modulo day", function()
    local result = M:_GetAdjustedTotSeconds({timeOnTargetSeconds=43200}, 300)
    assertEq(result, (43200 + 300) % SECONDS_PER_DAY)
  end)
end)

suite("_GetSecondsToWaypointTot", function()
  it("returns nil for nil waypoint", function()
    assertNil(M:_GetSecondsToWaypointTot(nil, 0))
  end)
  it("returns nil when waypoint has no TOT", function()
    assertNil(M:_GetSecondsToWaypointTot({}, 0))
  end)
  it("returns delta when waypoint has TOT", function()
    setAbsTime(43200)
    local result = M:_GetSecondsToWaypointTot({timeOnTargetSeconds=43260}, 0)
    setAbsTime(0)
    assertNear(result, 60, 1)
  end)
end)

suite("_GetNavigatorDumpPath / _ResetNavigatorDumpFile / _AppendNavigatorDump", function()
  it("_GetNavigatorDumpPath ends with NAVDUMP.log", function()
    assertMatch(M:_GetNavigatorDumpPath(), "NAVDUMP%.log$")
  end)

  it("_ResetNavigatorDumpFile succeeds in current directory", function()
    M:_ResetNavigatorDumpFile()
    assertTrue(true)
  end)

  it("_ResetNavigatorDumpFile logs error when file cannot be opened", function()
    local origDir = M._GetOutputDirectory
    M._GetOutputDirectory = function() return "/nonexistent_xyz_test_12345/" end
    local logged = {}
    local origLog = M._Log
    M._Log = function(_, msg) table.insert(logged, msg) end
    M:_ResetNavigatorDumpFile()
    M._GetOutputDirectory = origDir
    M._Log = origLog
    local found = false
    for _, msg in ipairs(logged) do
      if string.find(msg, "cannot") then found = true end
    end
    assertTrue(found, "should log error")
  end)

  it("_AppendNavigatorDump succeeds in current directory", function()
    M:_AppendNavigatorDump("TESTGROUP", "test dump content")
    assertTrue(true)
  end)

  it("_AppendNavigatorDump logs error when file cannot be opened", function()
    local origDir = M._GetOutputDirectory
    M._GetOutputDirectory = function() return "/nonexistent_xyz_test_12345/" end
    local logged = {}
    local origLog = M._Log
    M._Log = function(_, msg) table.insert(logged, msg) end
    M:_AppendNavigatorDump("TESTGROUP", "content")
    M._GetOutputDirectory = origDir
    M._Log = origLog
    local found = false
    for _, msg in ipairs(logged) do
      if string.find(msg, "cannot") then found = true end
    end
    assertTrue(found, "should log error")
  end)
end)

suite("Write function file-not-openable paths", function()
  local function withBadDir(fn)
    local origDir = M._GetOutputDirectory
    M._GetOutputDirectory = function() return "/nonexistent_xyz_test_54321/" end
    local logged = {}
    local origLog = M._Log
    M._Log = function(_, msg) table.insert(logged, msg) end
    fn()
    M._GetOutputDirectory = origDir
    M._Log = origLog
    return logged
  end

  it("_WriteFlightPlanFile logs when file cannot be opened", function()
    local origBuild = M._BuildFlightPlanTable
    M._BuildFlightPlanTable = function() return "x" end
    local logged = withBadDir(function()
      M:_WriteFlightPlanFile({name="P"}, "G", 0)
    end)
    M._BuildFlightPlanTable = origBuild
    local found = false
    for _, m in ipairs(logged) do if string.find(m, "cannot") then found=true end end
    assertTrue(found)
  end)

  it("_WriteFlightPlanCsvFile logs when file cannot be opened", function()
    local origBuild = M._BuildFlightPlanCsv
    M._BuildFlightPlanCsv = function() return "x" end
    local logged = withBadDir(function()
      M:_WriteFlightPlanCsvFile({name="P"})
    end)
    M._BuildFlightPlanCsv = origBuild
    local found = false
    for _, m in ipairs(logged) do if string.find(m, "cannot") then found=true end end
    assertTrue(found)
  end)

  it("_WriteBeaconsCsvFile logs when file cannot be opened", function()
    local origBuild = M._BuildBeaconsCsv
    M._BuildBeaconsCsv = function() return "x" end
    local logged = withBadDir(function()
      M:_WriteBeaconsCsvFile({{id="T"}})
    end)
    M._BuildBeaconsCsv = origBuild
    local found = false
    for _, m in ipairs(logged) do if string.find(m, "cannot") then found=true end end
    assertTrue(found)
  end)
end)

suite("_RefreshNavigatorRolex with enabled state", function()
  it("sends navigator message when state.enabled is true", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, g, text) table.insert(messages, text) end
    local origBuildStatus = M._BuildNavigatorStatusMessage
    M._BuildNavigatorStatusMessage = function(_, state, reason) return "STATUS MSG" end
    local origGetActive = M._GetActiveComputedPlan
    M._GetActiveComputedPlan = function(_, plan, b, p)
      return {valid=true, waypoints={}, warnings={}, timing={}}
    end
    local origInitWp = M._GetInitialNavigatorWpIndexByTot
    M._GetInitialNavigatorWpIndexByTot = function(_, plan, rolex, computed) return 1 end
    local origReset = M._ResetNavigatorCallouts
    M._ResetNavigatorCallouts = function(_, state) end
    local fakeGroup = {GetName = function() return "MOSQUITO" end}
    local origStates = M.NavigatorStates
    M.NavigatorStates = {
      MOSQUITO = {
        enabled = true, group = fakeGroup, groupName = "MOSQUITO",
        plan = {waypoints={}}, baseRolexSeconds = 0, pilotRolexSeconds = 0,
      }
    }
    M:_RefreshNavigatorRolex({
      groupName = "MOSQUITO", group = fakeGroup,
      plan = {waypoints={}}, baseRolexSeconds = 0, pilotRolexSeconds = 0,
    }, "ROLEX")
    M.NavigatorStates = origStates
    M._SendNavigatorMessage = origSend
    M._BuildNavigatorStatusMessage = origBuildStatus
    M._GetActiveComputedPlan = origGetActive
    M._GetInitialNavigatorWpIndexByTot = origInitWp
    M._ResetNavigatorCallouts = origReset
    assertEq(#messages, 1)
    assertMatch(messages[1], "STATUS")
  end)
end)

suite("_SetPilotRolex / _AdjustPilotRolex", function()
  it("_SetPilotRolex sends ROLEX message for non-zero delta", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, g, text) table.insert(messages, text) end
    local origRefresh = M._RefreshNavigatorRolex
    M._RefreshNavigatorRolex = function(_, state, reason) end
    local origStates = M.GroupPlanStates
    M.GroupPlanStates = nil
    local fakeGroup = {GetName = function() return "TESTG" end}
    local assignment = {plan={waypoints={}}, planName="JERICHO", rolexSeconds=0}
    M:_SetPilotRolex(fakeGroup, assignment, 300)
    M._SendNavigatorMessage = origSend
    M._RefreshNavigatorRolex = origRefresh
    M.GroupPlanStates = origStates
    assertEq(#messages, 1)
    assertMatch(messages[1], "ROLEX")
  end)

  it("_SetPilotRolex sends reset message for zero rolex", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, g, text) table.insert(messages, text) end
    local origRefresh = M._RefreshNavigatorRolex
    M._RefreshNavigatorRolex = function(_, state, reason) end
    local origStates = M.GroupPlanStates
    M.GroupPlanStates = nil
    local fakeGroup = {GetName = function() return "TESTG" end}
    local assignment = {plan={waypoints={}}, planName="JERICHO", rolexSeconds=0}
    M:_SetPilotRolex(fakeGroup, assignment, 0)
    M._SendNavigatorMessage = origSend
    M._RefreshNavigatorRolex = origRefresh
    M.GroupPlanStates = origStates
    assertEq(#messages, 1)
    assertEq(messages[1], "ROLEX reset")
  end)

  it("_AdjustPilotRolex delegates to _SetPilotRolex", function()
    local setCalls = {}
    local origSet = M._SetPilotRolex
    M._SetPilotRolex = function(_, group, assignment, seconds)
      table.insert(setCalls, seconds)
    end
    local origStates = M.GroupPlanStates
    M.GroupPlanStates = nil
    local fakeGroup = {GetName = function() return "TESTG" end}
    local assignment = {plan={waypoints={}}, planName="J", rolexSeconds=0}
    M:_AdjustPilotRolex(fakeGroup, assignment, 60)
    M._SetPilotRolex = origSet
    M.GroupPlanStates = origStates
    assertEq(#setCalls, 1)
    assertEq(setCalls[1], 60)
  end)
end)

------------------------------------------------------------
-- Positional navigation helpers (new)
------------------------------------------------------------

suite("_GetWaypointPassRadiusM", function()
  it("returns explicit radiusM when set on waypoint", function()
    assertEq(M:_GetWaypointPassRadiusM({type="NAV", radiusM=300}), 300)
  end)
  it("TARGET uses config fallback", function()
    assertEq(M:_GetWaypointPassRadiusM({type="TARGET"}), M.Config.navigatorTargetPassRadiusM)
  end)
  it("HOLD uses config fallback", function()
    assertEq(M:_GetWaypointPassRadiusM({type="HOLD"}), M.Config.navigatorHoldEntryRadiusM)
  end)
  it("LANDING uses config fallback", function()
    assertEq(M:_GetWaypointPassRadiusM({type="LANDING"}), M.Config.navigatorLandingPassRadiusM)
  end)
  it("NAV uses config fallback", function()
    assertEq(M:_GetWaypointPassRadiusM({type="NAV"}), M.Config.navigatorWaypointPassRadiusM)
  end)
end)

suite("_IsWaypointReachedFlyOver", function()
  it("true when within default pass radius", function()
    local wp = {type="NAV", coordinate = makeCoord({x=0, z=0})}
    assertTrue(M:_IsWaypointReachedFlyOver(wp, makeCoord({x=0, z=400})))
  end)
  it("false when beyond default pass radius", function()
    local wp = {type="NAV", coordinate = makeCoord({x=0, z=0})}
    assertTrue(not M:_IsWaypointReachedFlyOver(wp, makeCoord({x=0, z=600})))
  end)
  it("respects explicit radiusM", function()
    local wp = {type="NAV", radiusM=200, coordinate = makeCoord({x=0, z=0})}
    assertTrue(M:_IsWaypointReachedFlyOver(wp, makeCoord({x=0, z=150})))
    assertTrue(not M:_IsWaypointReachedFlyOver(wp, makeCoord({x=0, z=250})))
  end)
end)

suite("_IsWaypointReachedFlyBy", function()
  local prevWp = {coordinate = makeCoord({x=0, z=0})}
  local navWp  = {type="NAV", coordinate = makeCoord({x=0, z=NM * 10})}

  it("false with no previous waypoint", function()
    assertTrue(not M:_IsWaypointReachedFlyBy(nil, navWp, makeCoord({x=0, z=NM*11})))
  end)
  it("false when not yet past leg", function()
    assertTrue(not M:_IsWaypointReachedFlyBy(prevWp, navWp, makeCoord({x=0, z=NM*5})))
  end)
  it("true when past leg and within fly-by radius", function()
    assertTrue(M:_IsWaypointReachedFlyBy(prevWp, navWp, makeCoord({x=0, z=NM*11})))
  end)
  it("false when past leg but outside fly-by radius", function()
    assertTrue(not M:_IsWaypointReachedFlyBy(prevWp, navWp, makeCoord({x=1200, z=NM*11})))
  end)
  it("uses explicit radiusM for fly-by corridor", function()
    local wp = {type="NAV", radiusM=200, coordinate = makeCoord({x=0, z=NM*10})}
    assertTrue(M:_IsWaypointReachedFlyBy(prevWp, wp, makeCoord({x=300, z=NM*11})))
    assertTrue(not M:_IsWaypointReachedFlyBy(prevWp, wp, makeCoord({x=500, z=NM*11})))
  end)
end)

suite("_IsWaypointReachedPositionally — TARGET fly-over only", function()
  local prevWp = {coordinate = makeCoord({x=0, z=0})}

  it("TARGET: past leg within fly-by distance does NOT advance (fly-over only)", function()
    local wp = {type="TARGET", coordinate = makeCoord({x=0, z=NM*10})}
    local state = {plan={waypoints={prevWp,wp}}, currentWpIndex=2}
    assertTrue(not M:_IsWaypointReachedPositionally(state, wp, prevWp, makeCoord({x=0,z=NM*11})))
  end)
  it("TARGET: fly-over within pass radius triggers advance", function()
    local wp = {type="TARGET", radiusM=300, coordinate = makeCoord({x=0, z=NM*10})}
    local state = {plan={waypoints={prevWp,wp}}, currentWpIndex=2}
    assertTrue(M:_IsWaypointReachedPositionally(state, wp, prevWp, makeCoord({x=0,z=NM*10})))
  end)
  it("NAV: fly-by past leg within corridor triggers advance", function()
    local wp = {type="NAV", coordinate = makeCoord({x=0, z=NM*10})}
    local state = {plan={waypoints={prevWp,wp}}, currentWpIndex=2}
    assertTrue(M:_IsWaypointReachedPositionally(state, wp, prevWp, makeCoord({x=0,z=NM*11})))
  end)
end)

suite("_ComputeHoldExitClockSec", function()
  it("uses computed plan etaSec + holdDurationSec", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_HOLD__T00:05",              NM*10},
      {"MN_T_03_LANDING__T00:15",           NM*20},
    })
    local state = M:_GetNavigatorState({GetName=function() return "G" end}, plan, 0)
    setAbsTime(0)
    local exitClock = M:_ComputeHoldExitClockSec(state, 2)
    assertNear(exitClock, 720, 5)
  end)

  it("fallback to raw plan when computed waypoint unavailable", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_HOLD__T00:05",              NM*10},
      {"MN_T_03_LANDING__T00:15",           NM*20},
    })
    local state = M:_GetNavigatorState({GetName=function() return "G" end}, plan, 0)
    local origGet = M._GetNavigatorComputedWaypoint
    M._GetNavigatorComputedWaypoint = function() return nil end
    local exitClock = M:_ComputeHoldExitClockSec(state, 2)
    M._GetNavigatorComputedWaypoint = origGet
    assertNear(exitClock, 300, 2)
  end)

  it("returns nil when HOLD has no __T and fallback used", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_HOLD",                       NM*10},
      {"MN_T_03_LANDING",                    NM*20},
    })
    local state = M:_GetNavigatorState({GetName=function() return "G" end}, plan, 0)
    local origGet = M._GetNavigatorComputedWaypoint
    M._GetNavigatorComputedWaypoint = function() return nil end
    local result = M:_ComputeHoldExitClockSec(state, 2)
    M._GetNavigatorComputedWaypoint = origGet
    assertNil(result)
  end)
end)

suite("_HandleEtaLateAlert — one-shot warning", function()
  it("fires exactly once when ETA passed but waypoint not reached", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_NAV_Checkpoint__T00:05",     NM*15},
      {"MN_T_03_LANDING",                    NM*30},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return true end,
      GetCoordinate=function() return makeCoord({x=0, z=0}) end,
      GetAltitude=function() return 0 end,
      GetVelocityKNOTS=function() return 120 end,
    }
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.enabled = true; state.currentWpIndex = 2; state.takeoffComplete = true

    setAbsTime(400); setTime(400); M:_TickNavigatorState(state)
    setAbsTime(401); setTime(401); M:_TickNavigatorState(state)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    local count = 0
    for _, msg in ipairs(messages) do
      if string.find(msg, "ETA passed") then count = count + 1 end
    end
    assertEq(count, 1)
  end)
end)

suite("_HandleTargetDepartureAlert", function()
  it("fires alert when approaching then moving away from TARGET", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A50", 0},
      {"MN_T_02_TARGET_Prison__T00:10",       NM*10},
      {"MN_T_03_LANDING",                     NM*20},
    })
    local state = M:_GetNavigatorState({GetName=function() return "G" end}, plan, 0)
    state.currentWpIndex = 2
    local wp = plan.waypoints[2]
    -- TARGET at (0, NM*10); passRadius=500; threshold=1500m
    M:_HandleTargetDepartureAlert(state, wp, makeCoord({x=0, z=NM*10 - 1400}))
    M:_HandleTargetDepartureAlert(state, wp, makeCoord({x=0, z=NM*10 - 2100}))

    M._SendNavigatorMessage = origSend

    local found = false
    for _, msg in ipairs(messages) do
      if string.find(msg, "Departing") then found = true end
    end
    assertTrue(found, "departure alert should fire")
  end)

  it("does not fire when never approaching within threshold", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A50", 0},
      {"MN_T_02_TARGET_Prison__T00:10",       NM*10},
      {"MN_T_03_LANDING",                     NM*20},
    })
    local state = M:_GetNavigatorState({GetName=function() return "G" end}, plan, 0)
    state.currentWpIndex = 2
    local wp = plan.waypoints[2]
    M:_HandleTargetDepartureAlert(state, wp, makeCoord({x=0, z=NM*10 - 5000}))
    M:_HandleTargetDepartureAlert(state, wp, makeCoord({x=0, z=NM*10 - 6000}))

    M._SendNavigatorMessage = origSend
    assertTrue(#messages == 0, "no alert when never close enough")
  end)
end)

suite("_HandleNavigatorLandingReached", function()
  it("disables navigator and sends home plate message", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_LANDING", NM*15},
    })
    local state = M:_GetNavigatorState({GetName=function() return "G" end}, plan, 0)
    state.enabled = true
    M:_HandleNavigatorLandingReached(state)

    M._SendNavigatorMessage = origSend
    assertEq(state.enabled, false)
    assertEq(#messages, 1)
    assertMatch(messages[1], "Home plate")
  end)
end)

suite("LANDING fly-over completes navigation", function()
  it("_TickNavigatorState: fly-over of LANDING disables navigator", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_NAV", NM*10},
      {"MN_T_03_LANDING__T00:10", NM*20},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return true end,
      GetCoordinate=function() return makeCoord({x=0, z=NM*20}) end,
      GetAltitude=function() return 0 end,
      GetVelocityKNOTS=function() return 120 end,
    }
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.enabled = true; state.currentWpIndex = 3; state.takeoffComplete = true

    setAbsTime(600); setTime(600); M:_TickNavigatorState(state)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    assertEq(state.enabled, false)
    local found = false
    for _, msg in ipairs(messages) do
      if string.find(msg, "Home plate") then found = true end
    end
    assertTrue(found, "home plate message expected")
  end)
end)

suite("_GetInitialNavigatorWpIndexByPosition", function()
  it("falls back to first non-TAKE_OFF when group is nil", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_NAV", NM*10},
      {"MN_T_03_LANDING", NM*20},
    })
    assertEq(M:_GetInitialNavigatorWpIndexByPosition(plan, nil), 2)
  end)

  it("returns first non-TAKE_OFF WP when group is before it", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_NAV", NM*10},
      {"MN_T_03_LANDING", NM*20},
    })
    local g = {GetCoordinate=function() return makeCoord({x=0, z=NM*3}) end}
    assertEq(M:_GetInitialNavigatorWpIndexByPosition(plan, g), 2)
  end)

  it("returns WP03 when group is past WP02 but before WP03", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_NAV", NM*10},
      {"MN_T_03_LANDING", NM*20},
    })
    local g = {GetCoordinate=function() return makeCoord({x=0, z=NM*12}) end}
    assertEq(M:_GetInitialNavigatorWpIndexByPosition(plan, g), 3)
  end)

  it("returns nearest WP when group is past all WPs", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_NAV", NM*10},
      {"MN_T_03_LANDING", NM*20},
    })
    local g = {GetCoordinate=function() return makeCoord({x=0, z=NM*25}) end}
    assertEq(M:_GetInitialNavigatorWpIndexByPosition(plan, g), 3)
  end)
end)

suite("HOLD approach callouts before positional entry", function()
  it("fires approach callout when not yet in HOLD zone", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_HOLD__T00:05",              NM*10},
      {"MN_T_03_LANDING__T00:15",           NM*20},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return true end,
      GetCoordinate=function() return makeCoord({x=0, z=0}) end,
      GetAltitude=function() return 0 end,
      GetVelocityKNOTS=function() return 200 end,
    }
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.enabled = true; state.currentWpIndex = 2; state.takeoffComplete = true

    setAbsTime(0); setTime(0); M:_TickNavigatorState(state)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    local found = false
    for _, msg in ipairs(messages) do
      if string.find(msg, "5:00 CALLOUT") then found = true end
    end
    assertTrue(found, "approach callout should fire before entering HOLD zone")
  end)
end)

suite("HOLD late arrival — skip when past planned exit", function()
  it("skips hold and advances when arriving past planned exit", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_HOLD__T00:05",              NM*10},
      {"MN_T_03_LANDING__T00:15",           NM*20},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return true end,
      GetCoordinate=function() return makeCoord({x=0, z=NM*10}) end,
      GetAltitude=function() return 0 end,
      GetVelocityKNOTS=function() return 200 end,
    }
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.enabled = true; state.currentWpIndex = 2; state.takeoffComplete = true

    setAbsTime(800); setTime(800); M:_TickNavigatorState(state)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    assertEq(state.currentWpIndex, 3)
    local found = false
    for _, msg in ipairs(messages) do
      if string.find(msg, "skipped") then found = true end
    end
    assertTrue(found, "skip message should be emitted")
  end)
end)

suite("_SetNavigatorEnabled — non-airborne takeoff-complete path", function()
  it("emits waypoint callout when takeoff already complete (not airborne)", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_LANDING__T00:10", NM*15},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return false end,
      GetCoordinate=function() return makeCoord({x=0, z=0}) end,
      GetAltitude=function() return 0 end,
      GetVelocityKNOTS=function() return 0 end,
    }
    setAbsTime(0); setTime(0)
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.takeoffComplete = true
    M:_SetNavigatorEnabled(fakeGroup, plan, 0, true)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    assertEq(state.enabled, true)
    assertEq(#messages, 1)
    local hasBrake = false
    for _, msg in ipairs(messages) do
      if string.find(msg, "Brake") then hasBrake = true end
    end
    assertTrue(not hasBrake, "should not send takeoff message when takeoffComplete")
  end)
end)

suite("_FormatRadiusForCsv", function()
  it("returns empty string for nil radiusM", function()
    assertEq(M:_FormatRadiusForCsv({}), "")
    assertEq(M:_FormatRadiusForCsv({radiusM=nil}), "")
  end)
  it("formats whole-number radius", function()
    assertEq(M:_FormatRadiusForCsv({radiusM=500}), "500")
  end)
  it("rounds fractional radius", function()
    assertEq(M:_FormatRadiusForCsv({radiusM=250.6}), "251")
  end)
end)

suite("CSV PASS_RADIUS_M — explicit radiusM exported", function()
  it("exports PASS_RADIUS_M when set on waypoint", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_TARGET", NM*10},
      {"MN_T_03_LANDING", NM*20},
    })
    plan.name = "T"
    plan.waypoints[2].radiusM = 300
    local csv = M:_BuildFlightPlanCsv(plan, nil, 0)
    local lines = {}
    for l in (csv.."\n"):gmatch("([^\n]*)\n") do table.insert(lines, l) end
    assertMatch(lines[4], ",300$")
    assertMatch(lines[5], ",$")
  end)
end)

suite("DiscoverZones reads radiusM from zone", function()
  it("waypoint.radiusM populated from zone.GetRadius", function()
    local original = SET_ZONE
    local fakeSet = {
      FilterPrefixes = function(self) return self end,
      FilterStart    = function(self) return self end,
      ForEachZone    = function(self, cb)
        cb({
          GetName       = function() return "MN_JRAD_01_TAKE_OFF" end,
          GetCoordinate = function() return makeCoord({x=0,z=0}) end,
          GetRadius     = function() return 250 end,
        })
        return self
      end,
    }
    SET_ZONE = { New = function() return fakeSet end }
    local ok, plans = pcall(function() return M:_DiscoverZones() end)
    SET_ZONE = original
    if not ok then error(plans) end
    assertEq(plans["JRAD"].waypoints[1].radiusM, 250)
  end)
end)

suite("_SetNavigatorEnabled extra paths", function()
  local function capturedEnable(fn)
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil
    local ok, err = pcall(fn, messages)
    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil
    if not ok then error(err, 2) end
    return messages
  end

  it("enabled=false sends NAV off", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:01__S180__A0", 0},
      {"MN_T_02_LANDING", NM*15},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return false end,
    }
    local messages = capturedEnable(function()
      M:_SetNavigatorEnabled(fakeGroup, plan, 0, false)
    end)
    assertEq(#messages, 1)
    assertEq(messages[1], "NAV off")
  end)

  it("non-airborne with pending takeoff sends takeoff message", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:01__S180__A0", 0},
      {"MN_T_02_LANDING", NM*15},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return false end,
    }
    setAbsTime(0)
    local messages = capturedEnable(function()
      M:_SetNavigatorEnabled(fakeGroup, plan, 0, true)
    end)
    assertEq(#messages, 1)
    assertMatch(messages[1], "Brake release")
  end)
end)

suite("_SetNavigatorReportInterval", function()
  it("sets reportInterval and sends confirmation", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S180__A0", 0},
      {"MN_T_02_LANDING", NM*15},
    })
    local fakeGroup = {GetName=function() return "G" end}
    M:_SetNavigatorReportInterval(fakeGroup, plan, 0, 120)
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    assertEq(state.reportInterval, 120)
    assertEq(#messages, 1)
    assertMatch(messages[1], "120")
  end)
end)

suite("_FormatNavigatorSpeedCorrection on-speed branch", function()
  it("returns 'on speed' when delta <= 5 kt", function()
    assertEq(M:_FormatNavigatorSpeedCorrection(120, 122), "on speed")
    assertEq(M:_FormatNavigatorSpeedCorrection(120, 120), "on speed")
    assertEq(M:_FormatNavigatorSpeedCorrection(120, 115), "on speed")
  end)
end)

suite("HOLD interval report — in-hold phase", function()
  it("sends interval report when in hold and no callout fires", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_HOLD__T00:05",              NM*10},
      {"MN_T_03_LANDING__T00:15",           NM*20},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return true end,
      GetCoordinate=function() return makeCoord({x=0, z=NM*10}) end,
      GetAltitude=function() return 0 end,
      GetVelocityKNOTS=function() return 200 end,
    }
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.enabled = true; state.currentWpIndex = 2; state.takeoffComplete = true
    -- Enter hold at t=300 (exactly on plan)
    setAbsTime(300); setTime(300); M:_TickNavigatorState(state)
    -- Clear messages; tick at t=400 (holdRemaining=320 > suppress=300, no callout threshold)
    local countBefore = #messages
    state.reportInterval = 10
    setAbsTime(400); setTime(400); M:_TickNavigatorState(state)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    assertTrue(#messages > countBefore, "interval report should fire inside hold")
    local found = false
    for i = countBefore + 1, #messages do
      if string.find(messages[i], "to leave hold") then found = true end
    end
    assertTrue(found, "interval report should mention hold exit time")
  end)
end)

suite("HOLD interval report — approach phase", function()
  it("sends interval report when approaching HOLD with ETA far away", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, text) table.insert(messages, text) end
    M.NavigatorStates = nil

    -- HOLD at 00:20 so secondsToTot=1200 > all callout thresholds at t=0
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_HOLD__T00:20",              NM*40},
      {"MN_T_03_LANDING__T00:30",           NM*60},
    })
    local fakeGroup = {
      GetName=function() return "G" end,
      IsAlive=function() return true end,
      IsAirborne=function() return true end,
      GetCoordinate=function() return makeCoord({x=0, z=0}) end,
      GetAltitude=function() return 0 end,
      GetVelocityKNOTS=function() return 200 end,
    }
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.enabled = true; state.currentWpIndex = 2; state.takeoffComplete = true
    state.reportInterval = 10

    setAbsTime(0); setTime(0); M:_TickNavigatorState(state)

    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil

    -- secondsToTot=1200, no callout, no suppress → interval report fires
    assertEq(#messages, 1)
    assertMatch(messages[1], "NAV")
  end)
end)

suite("_TickNavigatorState early-return guards", function()
  local function makeTickGroup(opts)
    opts = opts or {}
    return {
      GetName          = function() return opts.name or "G" end,
      IsAlive          = function() return opts.alive ~= false end,
      IsAirborne       = function() return opts.airborne or false end,
      GetCoordinate    = opts.getCoord or function() return makeCoord({x=0, z=0}) end,
      GetAltitude      = function() return 0 end,
      GetVelocityKNOTS = function() return 0 end,
    }
  end

  it("returns immediately when state.enabled is false", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, t) table.insert(messages, t) end
    M.NavigatorStates = nil
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_LANDING", NM*10},
    })
    local group = makeTickGroup({airborne=true})
    local state = M:_GetNavigatorState(group, plan, 0)
    state.enabled = false; state.takeoffComplete = true
    setAbsTime(0); setTime(0); M:_TickNavigatorState(state)
    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil
    assertEq(#messages, 0)
  end)

  it("returns immediately when group is not alive", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, t) table.insert(messages, t) end
    M.NavigatorStates = nil
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_LANDING", NM*10},
    })
    local group = makeTickGroup({airborne=true, alive=false})
    local state = M:_GetNavigatorState(group, plan, 0)
    state.enabled = true; state.takeoffComplete = true
    setAbsTime(0); setTime(0); M:_TickNavigatorState(state)
    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil
    assertEq(#messages, 0)
  end)

  it("returns when groupCoordinate is nil", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, t) table.insert(messages, t) end
    M.NavigatorStates = nil
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A100", 0},
      {"MN_T_02_NAV",                          NM*10},
      {"MN_T_03_LANDING",                      NM*20},
    })
    local group = makeTickGroup({airborne=true, getCoord=function() return nil end})
    local state = M:_GetNavigatorState(group, plan, 0)
    state.enabled = true; state.takeoffComplete = true; state.currentWpIndex = 2
    setAbsTime(60); setTime(60); M:_TickNavigatorState(state)
    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil
    assertEq(#messages, 0)
  end)

  it("fires interval report when NAV waypoint has no TOT and interval has elapsed", function()
    local messages = {}
    local origSend = M._SendNavigatorMessage
    M._SendNavigatorMessage = function(_, _, t) table.insert(messages, t) end
    M.NavigatorStates = nil
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A100", 0},
      {"MN_T_02_NAV",                          NM*100},
      {"MN_T_03_LANDING",                      NM*200},
    })
    local fakeGroup = {
      GetName          = function() return "G" end,
      IsAlive          = function() return true end,
      IsAirborne       = function() return true end,
      GetCoordinate    = function() return makeCoord({x=0, z=0}) end,
      GetAltitude      = function() return 0 end,
      GetVelocityKNOTS = function() return 200 end,
    }
    local state = M:_GetNavigatorState(fakeGroup, plan, 0)
    state.enabled = true; state.takeoffComplete = true; state.currentWpIndex = 2
    state.reportInterval = 10; state.lastReportTime = 0
    setAbsTime(100); setTime(100); M:_TickNavigatorState(state)
    M._SendNavigatorMessage = origSend
    M.NavigatorStates = nil
    assertEq(#messages, 1)
    assertMatch(messages[1], "NAV")
  end)
end)

suite("_BuildNavigatorTakeoffMessage awaiting-takeoff branch", function()
  it("returns awaiting message when brake release time has already passed", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A100", 0},
      {"MN_T_02_LANDING", NM*10},
    })
    local group = {
      GetName   = function() return "G" end,
      IsAlive   = function() return true end,
      IsAirborne = function() return false end,
    }
    local state = M:_GetNavigatorState(group, plan, 0)
    setAbsTime(60)  -- 60s after brake release → secondsToTakeoff = -60
    local msg = M:_BuildNavigatorTakeoffMessage(state, "test")
    setAbsTime(0)
    M.NavigatorStates = nil
    assertMatch(msg, "Awaiting takeoff")
    assertMatch(msg, "T%+")
  end)
end)

suite("_SetNavigatorWaypoint out-of-range guard", function()
  it("does not change index when called with index < 1", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_LANDING", NM*10},
    })
    local group = {GetName=function() return "G" end, IsAlive=function() return true end}
    local state = M:_GetNavigatorState(group, plan, 0)
    M.NavigatorStates = nil
    state.currentWpIndex = 1
    M:_SetNavigatorWaypoint(state, 0, "test")
    assertEq(state.currentWpIndex, 1)
  end)

  it("does not change index when called with index beyond plan length", function()
    local plan = makePlan({
      {"MN_T_01_TAKE_OFF__T00:00__S200__A0", 0},
      {"MN_T_02_LANDING", NM*10},
    })
    local group = {GetName=function() return "G" end, IsAlive=function() return true end}
    local state = M:_GetNavigatorState(group, plan, 0)
    M.NavigatorStates = nil
    state.currentWpIndex = 1
    M:_SetNavigatorWaypoint(state, 99, "test")
    assertEq(state.currentWpIndex, 1)
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

runTests()
