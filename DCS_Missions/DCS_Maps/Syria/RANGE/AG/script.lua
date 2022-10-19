
--0.1 - CONST
CONST = {
    RGB = {
        range = {1,.5,0},
        farp = {.5,.5,1},
        zone_red = {1, 0 ,0},
        zone_patrol = {1, 1, 0},
        zone_bvr = {1, .5, 1}
    }
}

menu_dump_to_file = true
--1.1 - VARIABLES
FREQUENCIES = {
    AWACS = {
        darkstar = {249.00, "AWACS @MOOSE Darkstar UHF", "AM"},
        wizard = {250.00, "AWACS @ DCS Wizard UHF", "AM"},
    },
    AAR = {
        shell_1 = {252.10, "Tanker Shell One UHF", "AM"},
        shell_2 = {252.20, "Tanker Shell Two UHF", "AM"},
        texaco_1 = {252.30, "Tanker Texaco One UHF", "AM"},
        arco = {252.50, "Tanker Arco UHF", "AM"}
    },
    FLIGHTS = {
        vfma212_1_u = {266.20, "SQUADRON VFMA-212 UHF", "AM"},
        vfma212_2_u = {266.25, "SQUADRON VFMA-212 UHF", "AM"},
        vfma212_3_u = {266.80, "SQUADRON VFMA-212 UHF", "AM"},
        templar_u = {266.30, "TEMPLAR UHF", "AM"},
        assasin_u = {266.35, "ASSASIN UHF", "AM"},
        palladin_u = {266.40, "PALLADIN UHF", "AM"},
        crusader_u = {266.70, "CRUSADER UHF", "AM"},
        knight_u = {266.75, "KNIGHT UHF", "AM"},
        viper = {270.10, "VIPER ONE UHF", "AM"},
        viper = {270.20, "VIPER ONE UHF", "AM"},
        viper_3 = {270.30, "VIPER ONE UHF", "AM"},
        viper_4 = {270.40, "VIPER ONE UHF", "AM"}
    },
    CV = {
        dcs_sc = {127.50, "DCS SC ATC VHF", "AM"},
        btn1 = {260.00, "B-1 HUMAN Paddles/Tower C1 UHF", "AM"},
        btn2 = {260.10, "B-2 HUMAN Departure C2/C3 UHF", "AM"},
        btn3 = {249.10, "B-3 HUMAN Strike UHF", "AM"},
        btn4 = {258.20, "B-4 HUMAN Red Crown UHF", "AM"},
        btn15 = {260.20, "B-15 HUMAN CCA Fianal A", "AM"},
        btn16 = {260.30, "B-16 AIRBOSS/HUMAN Marshal UHF", "AM"},
        btn17 = {260.40, "B-17 HUMAN CCA Fianal B", "AM"},
    },
    LHA = {
        dcs_sc = {127.8, "LHA-1 DCS VHF", "AM"},
        tower = {267.00, "LHA-1 HUMAN Tower UHF", "AM"},
        radar = {267.50, "LHA-1 AIRBOSS/HUMAN Marshal UHF", "AM"},
    },
    GROUND = {
        atis_lcra = {125.000, "ATIS RAF Akrotiri VHF", "AM"},
        twr_lcra_v = {130.075, "Tower RAF Akrotiri VHF", "AM"},
        twr_lcra_u = {339.850, "Tower RAF Akrotiri UHF", "AM"},
        app_lcra_v = {123.600, "Approach RAF Akrotiri VHF", "AM"},
        app_lcra_u = {235.050, "Approach RAF Akrotiri UHF", "AM"},
        gnd_lcra_v = {122.100, "Ground RAF Akrotiri VHF", "AM"},
        gnd_lcra_u = {240.100, "Ground RAF Akrotiri UHF", "AM"},
    },
    SPECIAL = {
        guard_hi = {243.00, "Guard UHF", "AM"},
        guard_lo = {121.50, "Guard VHF", "AM"},
        ch_16 = {156.8, "Maritime Ch16 VHF", "FM"}
    }
}
ICLS = {
    sc = {11, "CV", "ICLS CVN-75"},
    lha = {6, "LH", "ICLS LHA-1"},
}
TACAN = {
    sc = {74, "X", "CVN", "CVN-75"},
    lha = {66, "X", "LHA", "LHA-1"},
    arco = {1, "Y", "RCV", "Recovery Tanker CVN-75", false},
    shell_1 = {51, "Y", "SHE", "Tanker Shell One", false},
    shell_2 = {53, "Y", "SCO", "Tanker Shell Two", false},
    texaco_1 = {52, "Y", "TEX", "Tanker Texaco One", false},
}
YARDSTICKS = {
    sting_1 = {"STING ONE", 37, 100, "Y"},
    joker_1 = {"JOKER TWO", 38, 101, "Y"},
    hawk_1 = {"HAWK ONE", 39, 102, "Y"},
    devil_1 = {"DEVIL TWO", 40, 103, "Y"},
    squid_1 = {"SQUID ONE", 41, 104, "Y"},
    check_1 = {"CHECK TWO", 42, 105, "Y"},
    viper_1 = {"VIPER ONE", 43, 106, "Y"},
    venom_1 = {"VENOM TWO", 44, 107, "Y"},
    jedi_1 = {"JEDI ONE", 45, 108, "Y"},
    ninja_1 = {"NINJA TWO", 46, 109, "Y"},
}


--1.2 - COMMON

function save_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"w")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end

function append_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"a")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end

function random(x, y)
    if x ~= nil and y ~= nil then
		return math.floor(x +(math.random()*999999 %y))
    else
        return math.floor((math.random()*100))
    end
end

for i=1, random(100,1000) do
	random(1,3)
end

function sleep(n)  -- seconds
   local t0 = os.clock()
   while ((os.clock() - t0) <= n) do
   end
end

function calculateCoordinateFromRoute(startCoordObject, course, distance)
	return startCoordObject:Translate(UTILS.NMToMeters(distance), course, false, false)
end
--2.1 - MENU
local ordered_flight_freq = {
    FREQUENCIES.AWACS.darkstar,
    FREQUENCIES.AWACS.wizard,
    FREQUENCIES.AAR.shell_1,
    FREQUENCIES.AAR.shell_2,
    FREQUENCIES.AAR.texaco_1,
    FREQUENCIES.AAR.arco,
}
local ordered_cvn = {
    FREQUENCIES.CV.dcs_sc,
    FREQUENCIES.CV.btn1,
    FREQUENCIES.CV.btn2,
    FREQUENCIES.CV.btn3,
    FREQUENCIES.CV.btn4,
    FREQUENCIES.CV.btn15,
    FREQUENCIES.CV.btn16,
    FREQUENCIES.CV.btn17,
    FREQUENCIES.CV.darkstar,

}
local ordered_lha = {
    FREQUENCIES.LHA.dcs_sc,
    FREQUENCIES.LHA.tower,
    FREQUENCIES.LHA.radar,
}
local ordered_ground_freq = {
    FREQUENCIES.GROUND.atis_lcra,
    FREQUENCIES.GROUND.gnd_lcra_v,
    FREQUENCIES.GROUND.twr_lcra_v,
    FREQUENCIES.GROUND.app_lcra_v,
    FREQUENCIES.GROUND.gnd_lcra_u,
    FREQUENCIES.GROUND.twr_lcra_u,
    FREQUENCIES.GROUND.app_lcra_u
}
local ordered_special_freq = {
    FREQUENCIES.SPECIAL.guard_hi,
    FREQUENCIES.SPECIAL.guard_lo,
    FREQUENCIES.SPECIAL.ch_16
}
local ordered_tacan_data = {
    TACAN.sc,
    TACAN.lha,
    TACAN.arco,
    TACAN.shell_1,
    TACAN.shell_2,
    TACAN.texaco_1
}
local ordered_yardstick_data = {
    --ARDSTICKS.ninja_1,
}
local ordered_icls_data = {
    ICLS.sc,
    ICLS.lha
}

function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

local function freq_text(general_freqs)
    local tmp_table = {}
    local msg = string.format("General freq in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_freqs) do
        local tmp_string = "empty"
        if (type(v[1]) == "string") then
            tmp_string = string.format("%s -> %s \n", v[1], v[2])
        else    
            tmp_string = string.format("%.2f -> %s %s \n", v[1], v[2], v[3])
        end
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function tacans_text(general_tacans)
    local tmp_table = {}
    local msg = string.format("TACANs in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_tacans) do
        local tmp_string = string.format("Ch %d %s Code: %s -> %s \n", v[1], v[2], v[3], v[4])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function yardsticks_text(general_yardsticks)
    local tmp_table = {}
    local msg = string.format("YARDSTICK's in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_yardsticks) do
        local tmp_string = string.format("%s -> Leader: %d <-> Wingman: %d (%s) \n", v[1], v[2], v[3], v[4])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function icls_text(general_icls)
    local tmp_table = {}
    local msg = string.format("ICLS/ILS in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_icls) do
        local tmp_string = string.format("Ch %s Code: %s -> %s \n", v[1], v[2], v[3])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local cvn_freqs_info = freq_text(ordered_cvn)
local lha_freqs_info = freq_text(ordered_lha)

local flight_freqs_info = freq_text(ordered_flight_freq)
local ground_freqs_info = freq_text(ordered_ground_freq)
local special_freqs_info = freq_text(ordered_special_freq)
local tacan_info = tacans_text(ordered_tacan_data)
local yardsticks_info = yardsticks_text(ordered_yardstick_data)
local icls_info = icls_text(ordered_icls_data)

local freqs_info = flight_freqs_info .. ground_freqs_info .. special_freqs_info .. cvn_freqs_info .. lha_freqs_info

MenuSrver = MENU_MISSION:New("Server Menu")

if (menu_dump_to_file) then
    save_to_file("freqs_info", freqs_info)
    save_to_file("tacan_info", tacan_info)
    save_to_file("yardstick_info", yardsticks_info)
    save_to_file("icls_info", icls_info)
end

info_msg=SOCKET:New()
info_msg:SendText(tacan_info)
info_msg:SendText(icls_info)
info_msg:SendText(freqs_info)

--3.1 - ATIS
AtisHatay = ATIS:New(AIRBASE.Syria.Akrotiri, FREQUENCIES.GROUND.atis_lcra[1])
AtisHatay:SetRadioRelayUnitName("LCRA Relay")
AtisHatay:SetTowerFrequencies({FREQUENCIES.GROUND.twr_lcra_v[1], FREQUENCIES.GROUND.twr_lcra_u[1]})
AtisHatay:AddILS(109.70, "29")
AtisHatay:AddNDBinner(365.00)
AtisHatay:SetSRS(SRS_PATH, "female", "en-US")
AtisHatay:SetMapMarks()
AtisHatay:Start()

--3.2 - AIRBOSS
name_CVN_75 = "CVN-75"
name_CVN_75_SAR = "CVN-SAR"
name_CVN_75_AWACS = "CVN-AWACS"
name_CVN_75_TANKER = "CVN-TANKER"
name_CVN_75_RALAY_MARSHAL = "CVN-RELAY-MARSHAL"

-- S-3B Recovery Tanker
cvn_75_tanker = RECOVERYTANKER:New(UNIT:FindByName(name_CVN_75), name_CVN_75_TANKER)
cvn_75_tanker:SetSpeed(274)
cvn_75_tanker:SetAltitude(6000)
cvn_75_tanker:SetRacetrackDistances(6, 8)
cvn_75_tanker:SetRadio(FREQUENCIES.AAR.arco[1])
cvn_75_tanker:SetCallsign(CALLSIGN.Tanker.Arco)
cvn_75_tanker:SetTACANoff()
cvn_75_tanker:SetTakeoffHot()
cvn_75_tanker:Start()

function cvn_75_tanker:OnAfterStart(From, Event, To)
    env.info(string.format("YAUTAY RECOVERY TANKER EVENT %S from %s to %s", Event, From, To))
    local unit = UNIT:FindByName(cvn_75_tanker:GetUnit())
    local beacon = unit:GetBeacon()
    beacon:ActivateTACAN(TACAN.arco[1], TACAN.arco[2], TACAN.arco[3], TACAN.arco[5])
end

-- E-2D AWACS
cvn_75_awacs = RECOVERYTANKER:New(name_CVN_75, name_CVN_75_AWACS)
cvn_75_awacs:SetAWACS()
cvn_75_awacs:SetRadio(FREQUENCIES.AWACS.wizard[1])
cvn_75_awacs:SetAltitude(22000)
cvn_75_awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
cvn_75_awacs:SetRacetrackDistances(20, 10)
cvn_75_awacs:SetTACANoff()
cvn_75_awacs:SetTakeoffHot()
cvn_75_awacs:Start()

-- Rescue Helo
cvn_75_sar = RESCUEHELO:New(UNIT:FindByName(name_CVN_75), name_CVN_75_SAR)
cvn_75_sar:Start()

-- AIRBOSS object.
cvn_75_airboss = AIRBOSS:New(name_CVN_75)
cvn_75_airboss:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3])
cvn_75_airboss:SetICLS(ICLS.sc[1], ICLS.sc[2])
cvn_75_airboss:SetMarshalRadio(FREQUENCIES.CV.btn16[1], FREQUENCIES.CV.btn16[3])
cvn_75_airboss:SetRadioRelayMarshal(name_CVN_75_RALAY_MARSHAL)
cvn_75_airboss:SetQueueUpdateTime(30)

--local case1 = cvn_75_airboss:AddRecoveryWindow("18:17", "19:00", 1, nil, true, 25)
--local case2_2 = cvn_75_airboss:AddRecoveryWindow("19:05", "19:30", 2, nil, true, 25)
--local case3 = cvn_75_airboss:AddRecoveryWindow("19:45", "05:30+1", 3, 30, true, 25)
--local case2_1 = cvn_75_airboss:AddRecoveryWindow("05:35+1", "06:30+1", 2, nil, true, 25)
--local case1_2 = cvn_75_airboss:AddRecoveryWindow("06:35+1", "19:00+1", 1, nil, true, 25)

cvn_75_airboss:SetDefaultPlayerSkill("Naval Aviator")
cvn_75_airboss:SetMenuRecovery(30, 28, false)
cvn_75_airboss:SetDespawnOnEngineShutdown()
cvn_75_airboss:Load()
cvn_75_airboss:SetAutoSave()
cvn_75_airboss:SetTrapSheet(nil, "TRAP-")
cvn_75_airboss:SetHandleAION()
cvn_75_airboss:Start()

function cvn_75_airboss:OnAfterStart(From, Event, To)
    env.info(string.format("YAUTAY ARIBOSS EVENT %S from %s to %s", Event, From, To))
end

--- Function called when a player gets graded by the LSO.
function cvn_75_airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
    local PlayerData = playerData --Ops.Airboss#AIRBOSS.PlayerData
    local Grade = grade --Ops.Airboss#AIRBOSS.LSOgrade
    local score = tonumber(Grade.points)
    local gradeLso = tostring(Grade.grade)
    local timeInGrove = tonumber(Grade.Tgroove)
    local wire = tonumber(Grade.wire)
    local name = tostring(PlayerData.name)

    ----------------------------------------
    --- Interface your Discord bot here! ---
    ----------------------------------------
    cvn_75_airboss:SetFunkManOn()
    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("YAUTAY CVN LSO REPORT! : Player %s scored %.1f - wire %d", name, score, wire))
end

name_LHA_1 = "LHA-1"
name_LHA_1_SAR = "LHA-SAR"
name_LHA_1_RALAY_MARSHAL = "LHA-RELAY-MARSHAL"

-- Rescue Helo
lha_1_sar = RESCUEHELO:New(UNIT:FindByName(name_LHA_1), name_LHA_1_SAR)
lha_1_sar:Start()

-- AIRBOSS object.
lha_1_airboss = AIRBOSS:New(name_LHA_1)
lha_1_airboss:SetTACAN(TACAN.lha[1], TACAN.lha[2], TACAN.lha[3])
lha_1_airboss:SetICLS(ICLS.lha[1], ICLS.lha[2])
lha_1_airboss:SetMarshalRadio(FREQUENCIES.LHA.radar[1], FREQUENCIES.LHA.radar[3])
lha_1_airboss:SetRadioRelayMarshal(name_LHA_1_RALAY_MARSHAL)
lha_1_airboss:SetQueueUpdateTime(30)
lha_1_airboss:SetDefaultPlayerSkill("Naval Aviator")
lha_1_airboss:SetMenuRecovery(30, 7, false)
lha_1_airboss:SetDespawnOnEngineShutdown()
lha_1_airboss:SetHandleAION()
lha_1_airboss:Start()

function lha_1_airboss:OnAfterStart(From, Event, To)
    env.info(string.format("YAUTAY ARIBOSS EVENT %S from %s to %s", Event, From, To))
end
--- Function called when a player gets graded by the LSO.
function lha_1_airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
    local PlayerData = playerData --Ops.Airboss#AIRBOSS.PlayerData
    local Grade = grade --Ops.Airboss#AIRBOSS.LSOgrade
    local score = tonumber(Grade.points)
    local gradeLso = tostring(Grade.grade)
    local timeInGrove = tonumber(Grade.Tgroove)
    local wire = tonumber(Grade.wire)
    local name = tostring(PlayerData.name)

    ----------------------------------------
    --- Interface your Discord bot here! ---
    ----------------------------------------
    lha_1_airboss:SetFunkManOn()
    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("YAUTAY LHA LSO REPORT! : Player %s scored %.1f - wire %d", name, score, wire))
end
--4.2 - CSAR
-- Instantiate and start a CSAR for the blue side, with template "Downed Pilot" and alias "Luftrettung"
mycsar = CSAR:New(coalition.side.BLUE,"Downed Pilot","MIA")
-- options
mycsar.immortalcrew = true -- downed pilot spawn is immortal
mycsar.invisiblecrew = false -- downed pilot spawn is visible
-- start the FSM
mycsar:__Start(5)
mycsar.allowDownedPilotCAcontrol = true -- Set to false if you don\'t want to allow control by Combined Arms.
mycsar.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
mycsar.FARPRescueDistance = 1000 -- you need to be this close to a FARP or Airport for the pilot to be rescued.
mycsar.autosmoke = true -- automatically smoke a downed pilot\'s location when a heli is near.
mycsar.autosmokedistance = 1000 -- distance for autosmoke
mycsar.coordtype = 2 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
mycsar.csarOncrash = true -- (WIP) If set to true, will generate a downed pilot when a plane crashes as well.
mycsar.enableForAI = true -- set to false to disable AI pilots from being rescued.
mycsar.pilotRuntoExtractPoint = true -- Downed pilot will run to the rescue helicopter up to mycsar.extractDistance in meters.
mycsar.extractDistance = 500 -- Distance the downed pilot will start to run to the rescue helicopter.
mycsar.immortalcrew = true -- Set to true to make wounded crew immortal.
mycsar.invisiblecrew = false -- Set to true to make wounded crew insvisible.
mycsar.loadDistance = 75 -- configure distance for pilots to get into helicopter in meters.
mycsar.mashprefix = {"MASH"} -- prefixes of #GROUP objects used as MASHes.
mycsar.max_units = 6 -- max number of pilots that can be carried if #CSAR.AircraftType is undefined.
mycsar.messageTime = 30 -- Time to show messages for in seconds. Doubled for long messages.
mycsar.radioSound = "beacon.ogg" -- the name of the sound file to use for the pilots\' radio beacons.
mycsar.smokecolor = 4 -- Color of smokemarker, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue.
mycsar.useprefix = true  -- Requires CSAR helicopter #GROUP names to have the prefix(es) defined below.
mycsar.csarPrefix = {"MEDEVAC", "CSAR"} -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor!
if (debug_csar) then
	mycsar.verbose = 2 -- set to > 1 for stats output for debugging.
	-- (added 0.1.4) limit amount of downed pilots spawned by **ejection** events
else
	mycsar.verbose = 0
end
mycsar.limitmaxdownedpilots = true
mycsar.maxdownedpilots = 10
-- (added 0.1.8) - allow to set far/near distance for approach and optionally pilot must open doors
mycsar.approachdist_far = 5000 -- switch do 10 sec interval approach mode, meters
mycsar.approachdist_near = 3000 -- switch to 5 sec interval approach mode, meters
mycsar.pilotmustopendoors = true -- switch to true to enable check of open doors
-- (added 0.1.9)
mycsar.suppressmessages = false -- switch off all messaging if you want to do your own
-- (added 0.1.11)
mycsar.rescuehoverheight = 20 -- max height for a hovering rescue in meters
mycsar.rescuehoverdistance = 10 -- max distance for a hovering rescue in meters
-- (added 0.1.12)
-- Country codes for spawned pilots
mycsar.countryblue= country.id.USA
mycsar.countryred = country.id.RUSSIA
mycsar.countryneutral = country.id.UN_PEACEKEEPERS


mycsar.useSRS = true -- Set true to use FF\'s SRS integration
mycsar.SRSPath = SRS_PATH -- adjust your own path in your SRS installation -- server(!)
mycsar.SRSchannel = FREQUENCIES.SPECIAL.guard_lo -- radio channel
mycsar.SRSModulation = radio.modulation.AM -- modulation
mycsar.SRSport = SRS_PORT  -- and SRS Server port
mycsar.SRSCulture = "en-GB" -- SRS voice culture
mycsar.SRSVoice = nil -- SRS voice, relevant for Google TTS
mycsar.SRSGPathToCredentials = nil -- Path to your Google credentials json file, set this if you want to use Google TTS
mycsar.SRSVolume = 1 -- Volume, between 0 and 1
--
mycsar.csarUsePara = false -- If set to true, will use the LandingAfterEjection Event instead of Ejection --shagrat
-- mycsar.wetfeettemplate = "man in floating thingy" -- if you use a mod to have a pilot in a rescue float, put the template name in here for wet feet spawns. Note: in conjunction with csarUsePara this might create dual ejected pilots in edge cases.


--AW.1 - AW AKROTIRI
function orbit_mark(route, text)
    route[1]:LineToAll(calculateCoordinateFromRoute(route[1], route[4], route[5], false, false), 2, CONST.RGB.range, 1, 2, true, text)
end

ZONE_SHELL_1_AAR = ZONE:New("SHELL_1_AAR")
ZONE_TEXACO_1_AAR = ZONE:New("TEXACO_1_AAR")
ZONE_DARKSTAR_1_AWACS = ZONE:New("DARKSTAR_1_AWACS")
ZONE_PATROL = ZONE_POLYGON:NewFromGroupName("LARNACA_PARTOL"):DrawZone(2, CONST.RGB.zone_patrol, 1, CONST.RGB.zone_patrol, .5, 1, true)
ZONE_ENGAGE = ZONE_POLYGON:NewFromGroupName("KILLBOX"):DrawZone(2, CONST.RGB.zone_bvr, 1, CONST.RGB.zone_bvr, .5, 1, true)

AW_LCRA = AIRWING:New("WH Akrotiri", "Akrotiri Air Wing")

AW_LCRA:SetMarker(false)
AW_LCRA:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Akrotiri))
AW_LCRA:SetRespawnAfterDestroyed(600)
AW_LCRA:__Start(2)

AW_LCRA_AAR_MPRS = SQUADRON:New("ME AAR MPRS", 3, "AAR Squadron")
AW_LCRA_AAR_MPRS:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LCRA_AAR_MPRS:SetTakeoffType("Hot")
AW_LCRA_AAR_MPRS:SetFuelLowRefuel(false)
AW_LCRA_AAR_MPRS:SetFuelLowThreshold(0.3)
AW_LCRA_AAR_MPRS:SetTurnoverTime(30, 5)
AW_LCRA:AddSquadron(AW_LCRA_AAR_MPRS)
AW_LCRA:NewPayload("ME AAR MPRS", -1, { AUFTRAG.Type.TANKER }, 100)

AW_LCRA_AAR = SQUADRON:New("ME AAR", 3, "AAR")
AW_LCRA_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LCRA_AAR:SetTakeoffType("Hot")
AW_LCRA_AAR:SetFuelLowRefuel(false)
AW_LCRA_AAR:SetFuelLowThreshold(0.3)
AW_LCRA_AAR:SetTurnoverTime(30, 5)
AW_LCRA:AddSquadron(AW_LCRA_AAR)
AW_LCRA:NewPayload("ME AAR", -1, { AUFTRAG.Type.TANKER }, 100)

local Shell_1_1_route = {ZONE_SHELL_1_AAR:GetCoordinate(), 28000, 480, 135, 40}
orbit_mark(Shell_1_1_route, "SHELL 1-1")

MISSION_Shell_1 = AUFTRAG:NewTANKER(Shell_1_1_route[1], Shell_1_1_route[2], Shell_1_1_route[3], Shell_1_1_route[4], Shell_1_1_route[5], 1)
MISSION_Shell_1:AssignSquadrons({ AW_LCRA_AAR_MPRS })
MISSION_Shell_1:SetRadio(FREQUENCIES.AAR.shell_1[1])
MISSION_Shell_1:SetName("Shell One")
AW_LCRA:AddMission(MISSION_Shell_1)

local Texaco_1_1_route = {ZONE_TEXACO_1_AAR:GetCoordinate(), 30000, 480, 0, 40}
orbit_mark(Texaco_1_1_route, "TEXACO 1-1")

MISSION_Texaco_1 = AUFTRAG:NewTANKER(Texaco_1_1_route[1], Texaco_1_1_route[2], Texaco_1_1_route[3], Texaco_1_1_route[4], Texaco_1_1_route[5], 0)
MISSION_Texaco_1:AssignSquadrons({ AW_LCRA_AAR })
MISSION_Texaco_1:SetRadio(FREQUENCIES.AAR.texaco_1[1])
MISSION_Texaco_1:SetName("Texaco One")
AW_LCRA:AddMission(MISSION_Texaco_1)

AW_LCRA_AWACS = SQUADRON:New("ME AWACS RJ", 2, "AWACS")
AW_LCRA_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_LCRA_AWACS:SetTakeoffType("Hot")
AW_LCRA_AWACS:SetFuelLowRefuel(true)
AW_LCRA_AWACS:SetFuelLowThreshold(0.4)
AW_LCRA_AWACS:SetTurnoverTime(30, 5)
AW_LCRA_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_LCRA:AddSquadron(AW_LCRA_AWACS)
AW_LCRA:NewPayload("ME AWACS RJ", -1, { AUFTRAG.Type.ORBIT }, 100)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Darkstar_1_1_route = {ZONE_DARKSTAR_1_AWACS:GetCoordinate(), 35000, 450, 180, 80}
orbit_mark(Darkstar_1_1_route, "DARKSTAR 1-1")

AWACS_DARKSTAR = AWACS:New("DARKSTAR", AW_LCRA, "blue", AIRBASE.Syria.Akrotiri, "DARKSTAR_1_AWACS", "KILLBOX", "LARNACA_PARTOL", FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWACS_DARKSTAR:SetBullsEyeAlias("CRUSADER")
AWACS_DARKSTAR:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, Darkstar_1_1_route[2], Darkstar_1_1_route[3], Darkstar_1_1_route[4], Darkstar_1_1_route[5])
AWACS_DARKSTAR:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_DARKSTAR:SetModernEraAggressive()

AWACS_DARKSTAR.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_DARKSTAR.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_DARKSTAR.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_DARKSTAR.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_DARKSTAR.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_DARKSTAR.maxassigndistance = 150 -- Don't assign targets further out than this, in NM.
AWACS_DARKSTAR.NoMissileCalls = false -- suppress missile callouts
AWACS_DARKSTAR.PlayerCapAssigment = true -- no task assignment for players
AWACS_DARKSTAR.invisible = true -- set AWACS to be invisible to hostiles
AWACS_DARKSTAR.immortal = true -- set AWACS to be immortal
AWACS_DARKSTAR.GoogleTTSPadding = 1 -- seconds
AWACS_DARKSTAR.WindowsTTSPadding = 2.5 -- seconds

AWACS_DARKSTAR:SuppressScreenMessages(true)
AWACS_DARKSTAR:__Start(2)

--AW.2 - AW LARNACA
function orbit_mark(route, text)
    route[1]:LineToAll(calculateCoordinateFromRoute(route[1], route[4], route[5], false, false), 2, CONST.RGB.range, 1, 2, true, text)
end

ZONE_SHELL_2_AAR = ZONE:New("SHELL_2_AAR")

AW_LCLK = AIRWING:New("WH Larnaca", "Larnaca Air Wing")

AW_LCLK:SetMarker(false)
AW_LCLK:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Larnaca))
AW_LCLK:SetRespawnAfterDestroyed(600)
AW_LCLK:__Start(2)

AW_LCLK_AAR_C130 = SQUADRON:New("ME AAR C130", 6, "AAR Squadron C130")
AW_LCLK_AAR_C130:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LCLK_AAR_C130:SetTakeoffType("Hot")
AW_LCLK_AAR_C130:SetFuelLowRefuel(false)
AW_LCLK_AAR_C130:SetFuelLowThreshold(0.4)
AW_LCLK_AAR_C130:SetTurnoverTime(30, 5)
AW_LCLK:AddSquadron(AW_LCLK_AAR_C130)
AW_LCLK:NewPayload("ME AAR C130", -1, { AUFTRAG.Type.TANKER }, 100)

local Shell_2_1_route = {ZONE_SHELL_2_AAR:GetCoordinate(), 20000, 290, 0, 40}
orbit_mark(Shell_2_1_route, "SHELL 2-1")

MISSION_Shell_2 = AUFTRAG:NewTANKER(Shell_2_1_route[1], Shell_2_1_route[2], Shell_2_1_route[3], Shell_2_1_route[4], Shell_2_1_route[5], 1)
MISSION_Shell_2:AssignSquadrons({ AW_LCLK_AAR_C130 })
MISSION_Shell_2:SetRadio(FREQUENCIES.AAR.shell_2[1])
MISSION_Shell_2:SetName("Shell Two")
AW_LCLK:AddMission(MISSION_Shell_2)

--AW.3 - AW ASSAD

ZONE_RED_AWACS = ZONE:New("RED_AWACS")
ZONE_RED_PATROL = ZONE_POLYGON:NewFromGroupName("RED_PATROL")
ZONE_RED_ENGAGE = ZONE_POLYGON:NewFromGroupName("KILLBOX")

AW_Assad = AIRWING:New("Static Warehouse-4-1", "Assad Air Wing")

AW_Assad:SetMarker(false)
AW_Assad:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Bassel_Al_Assad))
AW_Assad:SetRespawnAfterDestroyed(600)
AW_Assad:__Start(2)

AW_Assad_CAP = SQUADRON:New("Red Su33 BVR", 12, "Red Su33 BVR")
AW_Assad_CAP:AddMissionCapability({ AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.ESCORT, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.PATROLZONE }, 100)
AW_Assad_CAP:SetTakeoffType("Hot")
AW_Assad_CAP:SetFuelLowRefuel(true)
AW_Assad_CAP:SetFuelLowThreshold(0.5)
AW_Assad_CAP:SetTurnoverTime(15, 5)
AW_Assad:AddSquadron(AW_Assad_CAP)
AW_Assad:NewPayload("Red Su33 BVR", -1, { AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.ESCORT, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.PATROLZONE }, 100)

AW_Assad_AAR = SQUADRON:New("Red AAR", 3, "Red AAR Squadron")
AW_Assad_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_Assad_AAR:SetTakeoffType("Hot")
AW_Assad_AAR:SetFuelLowRefuel(false)
AW_Assad_AAR:SetFuelLowThreshold(0.3)
AW_Assad_AAR:SetTurnoverTime(30, 5)
AW_Assad:AddSquadron(AW_Assad_AAR)
AW_Assad:NewPayload("Red AAR", -1, { AUFTRAG.Type.TANKER }, 100)

AW_Assad_AWACS = SQUADRON:New("Red AWACS", 2, "Red AWACS Squadron")
AW_Assad_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_Assad_AWACS:SetTakeoffType("Hot")
AW_Assad_AWACS:SetFuelLowRefuel(true)
AW_Assad_AWACS:SetFuelLowThreshold(0.4)
AW_Assad_AWACS:SetTurnoverTime(30, 5)
AW_Assad_AWACS:SetRadio(251)
AW_Assad:AddSquadron(AW_Assad_AWACS)
AW_Assad:NewPayload("Red AWACS", -1, { AUFTRAG.Type.ORBIT }, 100)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Assad_AWACS_route = {ZONE_RED_AWACS:GetCoordinate(), 30000, 450, 0, 40}

AWACS_IVAN = AWACS:New("RED MAGIC", AW_Assad, "red", AIRBASE.Syria.Bassel_Al_Assad, "RED_AWACS", "KILLBOX", "RED_PATROL", 251, radio.modulation.AM)
AWACS_IVAN:SetBullsEyeAlias("SASHA")
AWACS_IVAN:SetAwacsDetails(CALLSIGN.AWACS.Magic, 1, Assad_AWACS_route[2], Assad_AWACS_route[3], Assad_AWACS_route[4], Assad_AWACS_route[5])
AWACS_IVAN:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_IVAN:SetModernEraAggressive()

AWACS_IVAN.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_IVAN.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_IVAN.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_IVAN.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_IVAN.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_IVAN.maxassigndistance = 150 -- Don't assign targets further out than this, in NM.
AWACS_IVAN.NoMissileCalls = true -- suppress missile callouts
AWACS_IVAN.PlayerCapAssigment = true -- no task assignment for players
AWACS_IVAN.invisible = false -- set AWACS to be invisible to hostiles
AWACS_IVAN.immortal = false -- set AWACS to be immortal
AWACS_IVAN.GoogleTTSPadding = 1 -- seconds
AWACS_IVAN.WindowsTTSPadding = 2.5 -- seconds

AWACS_IVAN:SuppressScreenMessages(true)
AWACS_IVAN:__Start(2)

--CHIEF.1 - CHIEF RED
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yauta.
--- DateTime: 13.10.2022 08:19
---
ZONE_RED_BORDER_1 = ZONE_POLYGON:NewFromGroupName("RED_BORDER_1")
ZONE_RED_BORDER_2 = ZONE_POLYGON:NewFromGroupName("RED_BORDER_2")
ZONE_RED_CONFLICT = ZONE_POLYGON:NewFromGroupName("RED_CONFLICT_1")

ZONE_RED_AAR = ZONE:New("RED_AAR")
ZONE_RED_PATROL = ZONE_POLYGON:NewFromGroupName("RED_PATROL")

ZONE_TARGET_LCRA = ZONE:New("TARGET_LCRA")
-- ###########################################################
-- ###                      RED CHIEF                      ###
-- ###########################################################



RedAgentSet = SET_GROUP:New()

RedBorderZoneSet = SET_ZONE:New()
RedBorderZoneSet:AddZone(ZONE_RED_BORDER_1)
RedBorderZoneSet:AddZone(ZONE_RED_BORDER_2)

ConflictZoneSet = SET_ZONE:New()
ConflictZoneSet:AddZone(ZONE_RED_CONFLICT)

AtackZoneSet = SET_ZONE:New()
AtackZoneSet:AddZone(ZONE_TARGET_LCRA)

RedChief = CHIEF:New("red", RedAgentSet, "Comrade RedChief")
-- ZONES
RedChief:SetBorderZones(RedBorderZoneSet)
RedChief:SetConflictZones(ConflictZoneSet)
RedChief:SetAttackZones(AtackZoneSet)
-- STRATEGY
RedChief:SetStrategy(CHIEF.Strategy.OFFENSIVE)
-- RESOURCES

RedChief:AddAirwing(AW_Assad)
RedChief:AddCapZone(ZONE_RED_PATROL, 30000, 470, 180, 20)
RedChief:AddGciCapZone(ZONE_RED_PATROL, 30000, 470, 180, 30)

local Assad_AAR_route = {ZONE_RED_AAR:GetCoordinate(), 25000, 470, 0, 40}
MISSION_Red_AAR = AUFTRAG:NewTANKER(Assad_AAR_route[1], Assad_AAR_route[2], Assad_AAR_route[3], Assad_AAR_route[4], Assad_AAR_route[5], 1)
MISSION_Red_AAR:SetRadio(251)
MISSION_Red_AAR:SetName("Red AAR")

RedChief:AddMission(MISSION_Red_AAR)

MISSION_Red_CAP = AUFTRAG:NewCAP(ZONE_RED_PATROL)
RedChief:AddMission(MISSION_Red_CAP)

RedChief:SetTacticalOverviewOn()
RedChief:__Start(5)
--MANTIS - Red IADS
red_mantis = MANTIS:New("red_mantis","Red SAM","Red EWR","Red C3i","red",false)
red_mantis:Start()

--5.1 - SCHEDULER
function tanker_platform_updater(airwing)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup = FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission = Mission --Ops.Auftrag#AUFTRAG
        local callsign = "nil"
        local index = 99

        if (mission:GetType() == AUFTRAG.Type.TANKER) then
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive()
            local unit_beacon = unit_alive:GetBeacon()

            if (mission.refuelSystem == 1) then
                -- garden hose
                callsign = CALLSIGN.Tanker.Shell
                if (string.find(mission:GetName(), "One")) then
                    index = 1
                    env.info(string.format("YAUTAY BEACON UPDATE ON %s %s", mission:GetName()))
                    unit_beacon:ActivateTACAN(TACAN.shell_1[1], TACAN.shell_1[2], TACAN.shell_1[3], TACAN.shell_1[5])
                elseif (string.find(mission:GetName(), "Two")) then
                    index = 2
                    env.info(string.format("YAUTAY BEACON UPDATE ON %s %s", mission:GetName()))
                    unit_beacon:ActivateTACAN(TACAN.shell_2[1], TACAN.shell_2[2], TACAN.shell_2[3], TACAN.shell_2[5])
                --elseif (string.find(mission:GetName(), "Three")) then
                --    index = 3
                --    unit_beacon:ActivateTACAN(TACAN.shell_3[1], TACAN.shell_3[2], TACAN.shell_3[3], TACAN.shell_3[5])
                end

            elseif (mission.refuelSystem == 0) then
                -- broom stick
                callsign = CALLSIGN.Tanker.Texaco
                if (string.find(mission:GetName(), "One")) then
                    index = 1
                    env.info(string.format("YAUTAY BEACON UPDATE ON %s %s", mission:GetName()))
                    unit_beacon:ActivateTACAN(TACAN.texaco_1[1], TACAN.texaco_1[2], TACAN.texaco_1[3], TACAN.texaco_1[5])
            --    elseif (string.find(mission:GetName(), "Two")) then
            --        index = 2
            --        unit_beacon:ActivateTACAN(TACAN.texaco_2[1], TACAN.texaco_2[2], TACAN.texaco_2[3], TACAN.texaco_2[5])
                end
            end
            env.info(string.format("YAUTAY TANKER PLATFORM UPDATE %s -> %s-%d", unit_alive:GetName(), callsign, index))
            unit_alive:CommandSetCallsign(callsign, index, 1)
        end
    end
end

tanker_platform_updater(AW_LCRA)
tanker_platform_updater(AW_LCLK)
