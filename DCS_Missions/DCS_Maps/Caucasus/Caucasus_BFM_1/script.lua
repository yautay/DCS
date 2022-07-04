 _          __     ___    ____  ___    _    ____  _     _____ ____  
/ |         \ \   / / \  |  _ \|_ _|  / \  | __ )| |   | ____/ ___| 
| |  _____   \ \ / / _ \ | |_) || |  / _ \ |  _ \| |   |  _| \___ \ 
| | |_____|   \ V / ___ \|  _ < | | / ___ \| |_) | |___| |___ ___) |
|_|            \_/_/   \_\_| \_\___/_/   \_\____/|_____|_____|____/ 
                                                                    

FREQUENCIES = {
    AWACS = {
        darkstar = {242.00, "AWACS Darkstar UHF", "AM"},
        overlord = {242.50, "AWACS Overlord UHF", "AM"},
        wizard = {247.70, "AWACS Wizard UHF", "AM"}
    },
    AAR = {
        common = {251.00, "TANKERS BIG BIRDS UHF", "AM"},
        arco = {243.50, "TANKER Arco UHF", "AM"}
    },
    FLIGHTS = {
		sting_1 = {"MIDS 1", "STING ONE MIDS", ""},
		joker_1 = {"MIDS 2", "JOKER ONE MIDS", ""},
        hawk_1 = {"MIDS 3", "HAWK ONE MIDS", ""},
        devil_1 = {"MIDS 4", "DEVIL ONE MIDS", ""},
		squid_1 = {"MIDS 5", "SQUID ONE MIDS", ""},
		check_1 = {"MIDS 6", "CHECK ONE MIDS", ""},
	    viper_1 = {271.00, "VIPER ONE UHF", "AM"},
		venom_1 = {271.25, "VENOM ONE UHF", "AM"},
		jedi_1 = {271.50, "JEDI ONE UHF", "AM"},
		ninja_1 = {271.75, "NINJA ONE UHF", "AM"},
    },
    CV = {
        lso = {260.00, "CV-75 LSO UHF", "AM"},
        marshal = {260.50, "CV-75 Marshal UHF", "AM"},
        sc = {127.50, "CV-75 Tower VHF", "AM"}
    },
    GROUND = {
        atis_vaziani = {118.75, "ATIS Vaziani VHF", "AM"},
        atis_kutaisi = {118.25, "ATIS Kutaisi VHF", "AM"},
        tower_vaziani = {269.00, "Tower Vaziani UHF", "AM"},
        tower_kutaisi = {263.00, "Tower Kutaisi UHF", "AM"},
    },
    SPECIAL = {
        guard_hi = {243.00, "Guard Freq UHF", "AM"},
        guard_lo = {121.5, "Guard Freq VHF", "AM"},
    }
}
ICLS = {
    sc = {1, "CV", "ICLS CVN-75"},
}
TACAN = {
    sc = {74, "X", "CVN", "CVN-75"},
    arco = {1, "Y", "RCV", "Recovery Tanker CVN-75"},
    shell_e = {51, "Y", "SHE", "Tanker Shell East Probe"},
    shell_w = {53, "Y", "SHW", "Tanker Shell West Probe"},
    texaco_e = {52, "Y", "TEE", "Tanker Texaco East Boom"},
    texaco_w = {54, "Y", "TEW", "Tanker Texaco West Boom"},
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

_SETTINGS:SetPlayerMenuOff()

--AIRWINGS
-- Vaziani
aw_vaziani_cap = false
aw_vaziani_escort = false
debug_aw_vaziani = false

-- Vaziani
aw_kutaisi_cap = false
aw_kutaisi_escort = false
debug_aw_kutaisi = false

-- FEATURES
-- Airboss
debug_airbos = false
-- CSAR
debug_csar = false
-- AWACS
cvn_awacs = true
moose_awacs_rejection_red_zone = false
debug_awacs = false

menu_dump_to_file = true
menu_show_freqs = false
menu_show_presets = false
 ____             ____ ___  __  __ __  __  ___  _   _ 
|___ \           / ___/ _ \|  \/  |  \/  |/ _ \| \ | |
  __) |  _____  | |  | | | | |\/| | |\/| | | | |  \| |
 / __/  |_____| | |__| |_| | |  | | |  | | |_| | |\  |
|_____|          \____\___/|_|  |_|_|  |_|\___/|_| \_|
                                                      
borderRed = ZONE_POLYGON:New("Red Zone", GROUP:FindByName("ZONE-RED-BORDER"))
borderBlue = ZONE_POLYGON:New("Blue Zone", GROUP:FindByName("ZONE-BLUE-BORDER"))

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
end _____           ____      _    ____ ___ ___  
|___ /          |  _ \    / \  |  _ \_ _/ _ \ 
  |_ \   _____  | |_) |  / _ \ | | | | | | | |
 ___) | |_____| |  _ <  / ___ \| |_| | | |_| |
|____/          |_| \_\/_/   \_\____/___\___/ 
                                              
 ____  ____  _____ ____  _____ _____ ____  
|  _ \|  _ \| ____/ ___|| ____|_   _/ ___| 
| |_) | |_) |  _| \___ \|  _|   | | \___ \ 
|  __/|  _ <| |___ ___) | |___  | |  ___) |
|_|   |_| \_\_____|____/|_____| |_| |____/ 
                                           
-- 225/399,97
local f16_164 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    -- 19 -> SECTION
    -- 20 -> FLIGHT
}
-- 30/155,97
local f16_222 = {
    -- GROUND
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
-- 30/399,97
local f18_210_1 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- CV
    {"7", FREQUENCIES.CV.marshal},
    {"8", FREQUENCIES.CV.lso},
    {"9", FREQUENCIES.CV.sc},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
-- -- 30/399,97
local f18_210_2 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- CV
    {"7", FREQUENCIES.CV.marshal},
    {"8", FREQUENCIES.CV.lso},
    {"9", FREQUENCIES.CV.sc},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
local presets_data = {
    preset_f16_164 = f16_164,
    preset_f16_222 = f16_222,
    preset_f18_210_1 = f18_210_1,
    preset_f18_210_2 = f18_210_2,
}

local function info_preset(preset_data, radio_name)
    local tmp_table = {}
    local msg = string.format("Radio %s presets: \n", radio_name)
    table.insert(tmp_table, msg)
    for i, v in ipairs(preset_data) do
        local tmp_string = string.format("  Ch %s preset %.2f -> %s \n", v[1], v[2][1], v[2][2])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function info_preset_f16_164()
    return info_preset(presets_data.preset_f16_164, "AN/ARC-164")
end

local function info_preset_f16_222()
    return info_preset(presets_data.preset_f16_222, "AN/ARC-222")
end

local function info_preset_f18_210_1()
    return info_preset(presets_data.preset_f18_210_1, "ARC-210-1")
end

local function info_preset_f18_210_2()
    return info_preset(presets_data.preset_f18_210_2, "ARC-210-2")
end
 _  _             __  __ _____ _   _ _   _ 
| || |           |  \/  | ____| \ | | | | |
| || |_   _____  | |\/| |  _| |  \| | | | |
|__   _| |_____| | |  | | |___| |\  | |_| |
   |_|           |_|  |_|_____|_| \_|\___/ 
                                           
local ordered_flight_freq = {
    FREQUENCIES.AWACS.darkstar,
    FREQUENCIES.AWACS.overlord,
    FREQUENCIES.AWACS.wizard,
    FREQUENCIES.AAR.common,
    FREQUENCIES.AAR.arco,
    FREQUENCIES.FLIGHTS.sting_1,
	FREQUENCIES.FLIGHTS.joker_1,
    FREQUENCIES.FLIGHTS.hawk_1,
    FREQUENCIES.FLIGHTS.devil_1,
	FREQUENCIES.FLIGHTS.squid_1,
    FREQUENCIES.FLIGHTS.check_1,
    FREQUENCIES.FLIGHTS.viper_1,
	FREQUENCIES.FLIGHTS.venom_1,
    FREQUENCIES.FLIGHTS.jedi_1,
	FREQUENCIES.FLIGHTS.ninja_1,
}
local ordered_ground_freq = {
    FREQUENCIES.CV.sc,
    FREQUENCIES.CV.lso,
    FREQUENCIES.CV.marshal,
    FREQUENCIES.GROUND.tower_vaziani,
    FREQUENCIES.GROUND.atis_vaziani,
    FREQUENCIES.GROUND.tower_kutaisi,
    FREQUENCIES.GROUND.atis_kutaisi,
}
local ordered_tacan_data = {
    TACAN.sc,
    TACAN.arco,
    TACAN.shell_e,
    TACAN.shell_w,
    TACAN.texaco_e,
    TACAN.texaco_w,
}
local ordered_yardstick_data = {
    YARDSTICKS.sting_1,
    YARDSTICKS.joker_1,
    YARDSTICKS.hawk_1,
    YARDSTICKS.devil_1,
    YARDSTICKS.squid_1,
    YARDSTICKS.check_1,
    YARDSTICKS.viper_1,
    YARDSTICKS.venom_1,
    YARDSTICKS.jedi_1,
    YARDSTICKS.ninja_1,
}
local ordered_icls_data = {
    ICLS.sc,
}

local info_preset_f16_164 = info_preset_f16_164()
local info_preset_f16_222 = info_preset_f16_222()

local info_preset_f18_210_1 = info_preset_f18_210_1()
local info_preset_f18_210_2 = info_preset_f18_210_2()

local function Msg(arg)
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

local flight_freqs_info = freq_text(ordered_flight_freq)
local ground_freqs_info = freq_text(ordered_ground_freq)
local tacan_info = tacans_text(ordered_tacan_data)
local yardsticks_info = yardsticks_text(ordered_yardstick_data)
local icls_info = icls_text(ordered_icls_data)

local freqs_info = flight_freqs_info .. ground_freqs_info
local presets_f16 = info_preset_f16_164 .. info_preset_f16_222
local presets_f18 = info_preset_f18_210_1 .. info_preset_f18_210_2

MenuSeler = MENU_MISSION:New("Seler Menu")

if (menu_show_freqs) then
    MenuFreq = MENU_MISSION:New("Data", MenuSeler)
    local freqInfo = MENU_MISSION_COMMAND:New("Flights", MenuFreq, Msg, {flight_freqs_info, 10})
    local freqInfo = MENU_MISSION_COMMAND:New("Ground", MenuFreq, Msg, {ground_freqs_info, 10})
    local TacanInfo = MENU_MISSION_COMMAND:New("TACAN", MenuFreq, Msg, {tacan_info, 10})
    local YardstickInfo = MENU_MISSION_COMMAND:New("YARDSTICK", MenuFreq, Msg, {yardsticks_info, 10})
    local IclsInfo = MENU_MISSION_COMMAND:New("ICLS", MenuFreq, Msg, {icls_info, 10})
end

if (menu_show_presets) then
    MenuPresets = MENU_MISSION:New("Presets", MenuSeler)
    local PresetsInfoF16 = MENU_MISSION_COMMAND:New("Presets F-16", MenuPresets, Msg, {presets_f16, 10})
    local PresetsInfoF18 = MENU_MISSION_COMMAND:New("Presets F-18", MenuPresets, Msg, {presets_f18, 10})
end

MenuFeatures = MENU_MISSION:New("Features", MenuSeler)

if (menu_dump_to_file) then
    save_to_file("presets_f16", presets_f16)
    save_to_file("presets_f18", presets_f18)
    save_to_file("freqs_info", freqs_info)
    save_to_file("tacan_info", tacan_info)
    save_to_file("yardstick_info", yardsticks_info)
    save_to_file("icls_info", icls_info)
end
 ____               _  _____ ___ ____  
| ___|             / \|_   _|_ _/ ___| 
|___ \   _____    / _ \ | |  | |\___ \ 
 ___) | |_____|  / ___ \| |  | | ___) |
|____/          /_/   \_\_| |___|____/ 
                                       
AtisVaziani = ATIS:New(AIRBASE.Caucasus.Vaziani, FREQUENCIES.GROUND.atis_vaziani[1])
AtisVaziani:SetRadioRelayUnitName("RELAY-VAZIANI")
AtisVaziani:SetTACAN(22)
AtisVaziani:SetTowerFrequencies({269.00})
AtisVaziani:AddILS(108.75, "13")
AtisVaziani:AddILS(108.75, "31")
AtisVaziani:AddNDBinner(368.00)
AtisVaziani:SetSRS(SRS_PATH, "female", "en-US")
AtisVaziani:SetMapMarks()
AtisVaziani:Start()

AtisKutaisi = ATIS:New(AIRBASE.Caucasus.Kutaisi, FREQUENCIES.GROUND.atis_kutaisi[1])
AtisKutaisi:SetRadioRelayUnitName("RELAY-VAZIANI")
AtisKutaisi:SetTACAN(44)
AtisKutaisi:SetVOR(113.60)
AtisKutaisi:SetTowerFrequencies({263.00})
AtisKutaisi:AddILS(109.75, "07")
AtisKutaisi:SetSRS(SRS_PATH, "female", "en-US")
AtisKutaisi:SetMapMarks()
AtisKutaisi:__Start(5)
 _____              _    ___ ____  ____   ___  ____ ____  
|___  |            / \  |_ _|  _ \| __ ) / _ \/ ___/ ___| 
   / /   _____    / _ \  | || |_) |  _ \| | | \___ \___ \ 
  / /   |_____|  / ___ \ | ||  _ <| |_) | |_| |___) |__) |
 /_/            /_/   \_\___|_| \_\____/ \___/|____/____/ 
                                                          
-- F10 Map Markings
ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)
-- S-3B Recovery Tanker
tanker = RECOVERYTANKER:New(UNIT:FindByName("CVN"), "ME CVN AAR")
tanker:SetRacetrackDistances(15, 5)
tanker:SetRadio(FREQUENCIES.AAR.arco[1])
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:Start()

function tanker:OnEventTakeoff(EventData)
    tanker:SetTACAN(FREQUENCIES.TACAN.arco[1], FREQUENCIES.TACAN.arco[2], FREQUENCIES.TACAN.arco[3], false)
end

-- E-2D AWACS_cv
if (cvn_awacs) then
    awacs_cv = RECOVERYTANKER:New("CVN", "ME CVN AWACS")
    awacs_cv:SetAWACS()
    awacs_cv:SetRadio(FREQUENCIES.AWACS.wizard[1])
    awacs_cv:SetAltitude(22000)
    awacs_cv:SetCallsign(CALLSIGN.AWACS.Wizard)
    awacs_cv:SetRacetrackDistances(20, 10)
    awacs_cv:SetTACANoff()
    awacs_cv:Start()
end

-- Rescue Helo
rescuehelo = RESCUEHELO:New(UNIT:FindByName("CVN"), "ME CVN SAR")
rescuehelo:Start()

-- AIRBOSS object.
Airboss = AIRBOSS:New("CVN")
Airboss:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3])
Airboss:SetICLS(ICLS.sc[1], ICLS.sc[2])
Airboss:SetMarshalRadio(FREQUENCIES.CV.marshal[1], FREQUENCIES.CV.marshal[3])
Airboss:SetLSORadio(FREQUENCIES.CV.lso[1])
Airboss:SetQueueUpdateTime(10)

Airboss:AddRecoveryWindow("00:01", "06:30", 3, -30, true, 25)
Airboss:AddRecoveryWindow("07:00", "20:30", 1, nil, true, 25)
Airboss:AddRecoveryWindow("21:00", "23:59", 3, -30, true, 25)
Airboss:AddRecoveryWindow("00:01+1", "06:30+1", 3, -30, true, 25)

-- Airboss:SetSoundfilesFolder("Airboss Soundfiles")
Airboss:SetMenuSingleCarrier()
Airboss:SetDefaultPlayerSkill(AIRBOSS.Difficulty.Normal)
Airboss:SetDespawnOnEngineShutdown()
Airboss:Load()
Airboss:SetAutoSave()
Airboss:SetTrapSheet()
Airboss:Start()

if (debug_airbos) then
    env.info("CUSTOM Airboss DEBUG ON!")
    BASE:TraceOnOff(true)
    BASE:TraceLevel(3)
    BASE:TraceClass("AIRBOSS")
    Airboss:SetDebugModeON()
end

--- Function called when a player gets graded by the LSO.
function Airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
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

    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("CUSTOM: Player %s scored %.1f", name, score))
end
 ___             ____ ____    _    ____
 ( _ )           / ___/ ___|  / \  |  _ \ 
 / _ \   _____  | |   \___ \ / _ \ | |_) |
| (_) | |_____| | |___ ___) / ___ \|  _ < 
 \___/           \____|____/_/   \_\_| \_\
                                          
-- Instantiate and start a CSAR for the blue side, with template "Downed Pilot" and alias "Luftrettung"
mycsar = CSAR:New(coalition.side.BLUE,"Downed Pilot","MIA")
-- options
mycsar.immortalcrew = true -- downed pilot spawn is immortal
mycsar.invisiblecrew = false -- downed pilot spawn is visible
-- start the FSM
mycsar:__Start(5)
mycsar.allowDownedPilotCAcontrol = false -- Set to false if you don\'t want to allow control by Combined Arms.
mycsar.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
mycsar.FARPRescueDistance = 1000 -- you need to be this close to a FARP or Airport for the pilot to be rescued.
mycsar.autosmoke = false -- automatically smoke a downed pilot\'s location when a heli is near.
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
mycsar.csarPrefix = { "helicargo", "MEDEVAC"} -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor!
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
mycsar.pilotmustopendoors = false -- switch to true to enable check of open doors
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
mycsar.SRSPath = "C:\\DCS-SimpleRadio-Standalone" -- adjust your own path in your SRS installation -- server(!)
mycsar.SRSchannel = 242 -- radio channel
mycsar.SRSModulation = radio.modulation.AM -- modulation
mycsar.SRSport = 5002  -- and SRS Server port
mycsar.SRSCulture = "en-GB" -- SRS voice culture
mycsar.SRSVoice = nil -- SRS voice, relevant for Google TTS
mycsar.SRSGPathToCredentials = nil -- Path to your Google credentials json file, set this if you want to use Google TTS
mycsar.SRSVolume = 1 -- Volume, between 0 and 1
--
mycsar.csarUsePara = false -- If set to true, will use the LandingAfterEjection Event instead of Ejection --shagrat
-- mycsar.wetfeettemplate = "man in floating thingy" -- if you use a mod to have a pilot in a rescue float, put the template name in here for wet feet spawns. Note: in conjunction with csarUsePara this might create dual ejected pilots in edge cases.

  ___            _____ _____  __
 / _ \          |  ___/ _ \ \/ /
| (_) |  _____  | |_ | | | \  / 
 \__, | |_____| |  _|| |_| /  \ 
   /_/          |_|   \___/_/\_\
                                
alpha_1 = ZONE_POLYGON:New("ALPHA ONE", GROUP:FindByName("zone-10")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Squid-1
alpha_2 = ZONE_POLYGON:New("ALPHA TWO", GROUP:FindByName("zone-8")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Devil-1
alpha_3 = ZONE_POLYGON:New("ALPHA THREE", GROUP:FindByName("zone-2")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Hawk-1
alpha_4 = ZONE_POLYGON:New("ALPHA FOUR", GROUP:FindByName("zone-1")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Joker-1
bravo_1 = ZONE_POLYGON:New("BRAVO ONE", GROUP:FindByName("zone-11")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Check-1
bravo_2 = ZONE_POLYGON:New("BRAVO TWO", GROUP:FindByName("zone-9")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)

bravo_3 = ZONE_POLYGON:New("BRAVO THREE", GROUP:FindByName("zone-4")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Ninja-1
bravo_4 = ZONE_POLYGON:New("BRAVO FOUR", GROUP:FindByName("zone-3")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Sting-1
charlie_1 = ZONE_POLYGON:New("CHARLIE ONE", GROUP:FindByName("zone-7")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Jedi-1
delta_1 = ZONE_POLYGON:New("DELTA ONE", GROUP:FindByName("zone-6")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Venom-1
delta_2 = ZONE_POLYGON:New("DELTA0 TWO", GROUP:FindByName("zone-5")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Viper-1

squid_1 = GROUP:FindByName("Squid-1")
devil_1 = GROUP:FindByName("Devil-1")
hawk_1 = GROUP:FindByName("Hawk-1")
joker_1 = GROUP:FindByName("Joker-1")
check_1 = GROUP:FindByName("Check-1")
ninja_1 = GROUP:FindByName("Ninja-1")
sting_1 = GROUP:FindByName("Sting-1")
jedi_1 = GROUP:FindByName("Jedi-1")
venom_1 = GROUP:FindByName("Venom-1")
viper_1 = GROUP:FindByName("Viper-1")

local zones_data = {
	{alpha_1, squid_1},
	{alpha_2, devil_1},
	{alpha_3, hawk_1},
	{alpha_4, joker_1},
	{bravo_1, check_1},
	{bravo_3, ninja_1},
	{bravo_4, sting_1},
	{charlie_1, jedi_1},
	{delta_1, venom_1},
	{delta_2, viper_1},
}

fox=FOX:New()

fox:AddSafeZone(alpha_1)
fox:AddSafeZone(alpha_2)
fox:AddSafeZone(alpha_3)
fox:AddSafeZone(alpha_4)
fox:AddSafeZone(bravo_1)
fox:AddSafeZone(bravo_2)
fox:AddSafeZone(bravo_3)
fox:AddSafeZone(bravo_4)
fox:AddSafeZone(delta_1)
fox:AddSafeZone(delta_2)
fox:Start()

FOX:SetDisableF10Menu(true)
FOX:SetDefaultLaunchAlerts(false)
FOX:SetDefaultLaunchMarks(false)

function get_coords(data)
	local zone_info = {}
	local msg = string.format("BFM ZONES's in use: \n")
	table.insert(zone_info, msg)
	for i, v in pairs(data) do
		local zone = v[1]
		local group = v[2]
		local coordinate = zone:GetCoordinate(0):ToStringLLDMS()
		local tmp_msg = string.format("%s / %s -> %s\n", zone:GetName(), group:GetName(), coordinate)
		table.insert(tmp_msg)
		zone:MarkToGroup("BFM ZONE", group, true)
	end
	local final_msg = table.concat(zone_info)
	return final_msg .. "\n"
end

local zones = get_coords(zones_data)

save_to_file("bfm_zones_data", zones)
 _ _   _              ___        __ __     ___     _____
/ / | / |            / \ \      / / \ \   / / \   |__  /
| | | | |  _____    / _ \ \ /\ / /   \ \ / / _ \    / / 
| | |_| | |_____|  / ___ \ V  V /     \ V / ___ \  / /_ 
|_|_(_)_|         /_/   \_\_/\_/       \_/_/   \_\/____|
                                                        
ZONE_VAZIANI_CAP = ZONE:New("CORN FLAKES")
ZONE_VAZIANI_FEZ = ZONE:New("GUADALCANAL")
ZONE_VAZIANI_AWACS = ZONE:New("DARKSTAR")
ZONE_SHELL_EAST_AAR = ZONE:New("SHELL EAST")
ZONE_TEXACO_EAST_AAR = ZONE:New("TEXACO EAST")

AWVaziani = AIRWING:New("WH VAZIANI", "Vaziani Air Wing")

if (debug_aw_vaziani) then
	function AWVaziani:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWVaziani:SetMarker(false)
AWVaziani:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Vaziani))
AWVaziani:SetRespawnAfterDestroyed(600)


Vaziani_AWACS = SQUADRON:New("ME AWACS E3",2,"AWACS Vaziani")
Vaziani_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Vaziani_AWACS:SetTakeoffAir()
Vaziani_AWACS:SetFuelLowRefuel(false)
Vaziani_AWACS:SetFuelLowThreshold(0.25)
Vaziani_AWACS:SetTurnoverTime(30,180)
Vaziani_AWACS:SetCallsign(CALLSIGN.Aircraft.Darkstar, 1)
Vaziani_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_AWACS)
AWVaziani:NewPayload("ME AWACS E3" ,-1,{AUFTRAG.Type.ORBIT},100)

Vaziani_MPRS = SQUADRON:New("ME TANKER KC135MPRS",2,"AAR MPRS Vaziani")
Vaziani_MPRS:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Vaziani_MPRS:SetTakeoffAir()
Vaziani_MPRS:SetFuelLowRefuel(false)
Vaziani_MPRS:SetFuelLowThreshold(0.25)
Vaziani_MPRS:SetTurnoverTime(15,60)
Vaziani_MPRS:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_MPRS)
AWVaziani:NewPayload("ME TANKER KC135MPRS", -1, {AUFTRAG.Type.TANKER},100)

Vaziani_135 = SQUADRON:New("ME AAR KC135",2,"AAR 135 Vaziani")
Vaziani_135:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Vaziani_135:SetTakeoffAir()
Vaziani_135:SetFuelLowRefuel(false)
Vaziani_135:SetFuelLowThreshold(0.25)
Vaziani_135:SetTurnoverTime(15,60)
Vaziani_135:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_135)
AWVaziani:NewPayload("ME AAR KC135", -1, {AUFTRAG.Type.TANKER},100)

TankerShellEast = AUFTRAG:NewTANKER(ZONE_SHELL_EAST_AAR:GetCoordinate(), 25000, 320, 80, 20, 0)
TankerShellEast:AssignSquadrons({Vaziani_135})
-- TankerShellEast:SetTACAN(TACAN.shell_e[1], TACAN.shell_e[3], TACAN.shell_e[2])
TankerShellEast:SetRadio(FREQUENCIES.AAR.common[1])
TankerShellEast:SetName("Shell East")
AWVaziani:AddMission(TankerShellEast)

TankerTexacoEast = AUFTRAG:NewTANKER(ZONE_TEXACO_EAST_AAR:GetCoordinate(), 22000, 310, 80, 20, 1)
TankerTexacoEast:AssignSquadrons({Vaziani_MPRS})
-- TankerTexacoEast:SetTACAN(TACAN.texaco_e[1], TACAN.texaco_e[3], TACAN.texaco_e[2])
TankerTexacoEast:SetRadio(FREQUENCIES.AAR.common[1])
TankerTexacoEast:SetName("Texaco East")
AWVaziani:AddMission(TankerTexacoEast)


if (aw_vaziani_cap or aw_vaziani_escort) then
	Vaziani_F5 = SQUADRON:New("ME F5",12,"F5 Vaziani")
	Vaziani_F5:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
	Vaziani_F5:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 50)
	Vaziani_F5:SetTakeoffHot()
	Vaziani_F5:SetFuelLowRefuel(true)
	Vaziani_F5:SetFuelLowThreshold(0.3)
	Vaziani_F5:SetTurnoverTime(10,60)
	Vaziani_F5:SetCallsign(CALLSIGN.Aircraft.Ford, 1)
	Vaziani_F5:SetTakeoffHot()
	Vaziani_F5:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
	AWVaziani:AddSquadron(Vaziani_F5)
	if (aw_vaziani_cap) then
		AWVaziani:NewPayload("ME F5", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
	end
	if (aw_vaziani_escort) then
		AWVaziani:NewPayload("ME F5", -1, {AUFTRAG.Type.ESCORT},100)
	end
end

AWVaziani:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AwacsDarkstar = AWACS:New("Darkstar", AWVaziani, "blue", AIRBASE.Caucasus.Vaziani, "DARKSTAR", "GUADALCANAL", "CORN FLAKES", FREQUENCIES.AWACS.darkstar[1] ,radio.modulation.AM)
if (aw_vaziani_escort) then
	AwacsDarkstar:SetEscort(1)
end
AwacsDarkstar:SetBullsEyeAlias("TEXAS")
AwacsDarkstar:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, 30000, 220, 120, 20)
AwacsDarkstar:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
if (moose_awacs_rejection_red_zone) then
	AwacsDarkstar:SetRejectionZone(borderRed)
end
AwacsDarkstar:SetAdditionalZone(borderBlue, true)
AwacsDarkstar:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 2, 300)
AwacsDarkstar:SetModernEraAgressive()

AwacsDarkstar.PlayerGuidance = true -- allow missile warning call-outs.
AwacsDarkstar.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AwacsDarkstar.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AwacsDarkstar.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AwacsDarkstar.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AwacsDarkstar.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AwacsDarkstar.NoMissileCalls = false -- suppress missile callouts
AwacsDarkstar.PlayerCapAssigment = true -- no task assignment for players
AwacsDarkstar.invisible = true -- set AWACS to be invisible to hostiles
AwacsDarkstar.immortal = true -- set AWACS to be immortal
AwacsDarkstar.GoogleTTSPadding = 1 -- seconds
AwacsDarkstar.WindowsTTSPadding = 2.5 -- seconds

AwacsDarkstar:SuppressScreenMessages(true)

AwacsDarkstar:__Start(5)

if (debug_awacs) then
	AwacsDarkstar.debug = true -- set to true to produce more log output.
else
  	AwacsDarkstar.debug = false
end _ _   ____               ___        __  _  ___   _ _____ 
/ / | |___ \             / \ \      / / | |/ / | | |_   _|
| | |   __) |  _____    / _ \ \ /\ / /  | ' /| | | | | |  
| | |_ / __/  |_____|  / ___ \ V  V /   | . \| |_| | | |  
|_|_(_)_____|         /_/   \_\_/\_/    |_|\_\\___/  |_|  
                                                          
ZONE_KUTAISI_CAP = ZONE:New("PANCAKE")
ZONE_KUTAISI_FEZ = ZONE:New("MIDWAY")
ZONE_KUTAISI_AWACS = ZONE:New("OVERLORD")
ZONE_SHELL_WEST_AAR = ZONE:New("SHELL WEST")
ZONE_TEXACO_WEST_AAR = ZONE:New("TEXACO WEST")

AWKutaisi = AIRWING:New("WH KUTAISI", "Kutaisi Air Wing")

if (debug_aw_kutaisi) then
	function AWKutaisi:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWKutaisi:SetMarker(false)
AWKutaisi:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
AWKutaisi:SetRespawnAfterDestroyed(600)


Kutaisi_AWACS = SQUADRON:New("ME AWACS E3",2,"AWACS Kutaisi")
Kutaisi_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Kutaisi_AWACS:SetTakeoffAir()
Kutaisi_AWACS:SetFuelLowRefuel(false)
Kutaisi_AWACS:SetFuelLowThreshold(0.25)
Kutaisi_AWACS:SetTurnoverTime(30,180)
Kutaisi_AWACS:SetCallsign(CALLSIGN.Aircraft.Overlord, 1)
Kutaisi_AWACS:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_AWACS)
AWKutaisi:NewPayload("ME AWACS E3" ,-1,{AUFTRAG.Type.ORBIT},100)

Kutaisi_MPRS = SQUADRON:New("ME TANKER KC135MPRS",2,"AAR MPRS Kutaisi")
Kutaisi_MPRS:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Kutaisi_MPRS:SetTakeoffAir()
Kutaisi_MPRS:SetFuelLowRefuel(false)
Kutaisi_MPRS:SetFuelLowThreshold(0.25)
Kutaisi_MPRS:SetTurnoverTime(15,60)
Kutaisi_MPRS:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_MPRS)
AWKutaisi:NewPayload("ME TANKER KC135MPRS", -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

Kutaisi_135 = SQUADRON:New("ME AAR KC135",2,"AAR 135 Kutaisi")
Kutaisi_135:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Kutaisi_135:SetTakeoffAir()
Kutaisi_135:SetFuelLowRefuel(false)
Kutaisi_135:SetFuelLowThreshold(0.25)
Kutaisi_135:SetTurnoverTime(15,60)
Kutaisi_135:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_135)
AWKutaisi:NewPayload("ME AAR KC135", -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

TankerShellWest = AUFTRAG:NewTANKER(ZONE_SHELL_WEST_AAR:GetCoordinate(), 25000, 320, 80, 20, 0)
TankerShellWest:AssignSquadrons({Kutaisi_135})
-- TankerShellWest:SetTACAN(TACAN.shell_w[1], TACAN.shell_w[3], TACAN.shell_w[2])
TankerShellWest:SetRadio(FREQUENCIES.AAR.common[1])
TankerShellWest:SetName("Shell West")
AWKutaisi:AddMission(TankerShellWest)

TankerTexacoWest = AUFTRAG:NewTANKER(ZONE_TEXACO_WEST_AAR:GetCoordinate(), 22000, 310, 135, 20, 1)
TankerTexacoWest:AssignSquadrons({Kutaisi_MPRS})
-- TankerTexacoWest:SetTACAN(TACAN.texaco_w[1], TACAN.texaco_w[3], TACAN.texaco_w[2])
TankerTexacoWest:SetRadio(FREQUENCIES.AAR.common[1])
TankerTexacoWest:SetName("Texaco West")
AWKutaisi:AddMission(TankerTexacoWest)


if (aw_kutaisi_cap or aw_kutaisi_escort) then
	Kutaisi_SU27 = SQUADRON:New("ME SU27",12,"SU27 Vaziani")
	Kutaisi_SU27:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
	Kutaisi_SU27:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 50)
	Kutaisi_SU27:SetTakeoffHot()
	Kutaisi_SU27:SetFuelLowRefuel(true)
	Kutaisi_SU27:SetFuelLowThreshold(0.3)
	Kutaisi_SU27:SetTurnoverTime(10,60)
	Kutaisi_SU27:SetCallsign(CALLSIGN.Aircraft.Ford, 2)
	Kutaisi_SU27:SetTakeoffHot()
	Kutaisi_SU27:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)
	AWKutaisi:AddSquadron(Kutaisi_SU27)
	if (aw_kutaisi_cap) then
		AWKutaisi:NewPayload("ME SU27", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
	end
	if (aw_kutaisi_escort) then
		AWKutaisi:NewPayload("ME SU27", -1, {AUFTRAG.Type.ESCORT},100)
	end
end

AWKutaisi:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AwacsOverlord = AWACS:New("Overlord", AWKutaisi, "blue", AIRBASE.Caucasus.Kutaisi, "OVERLORD", "MIDWAY", "PANCAKE", FREQUENCIES.AWACS.overlord[1] ,radio.modulation.AM)
if (aw_kutaisi_escort) then
	AwacsOverlord:SetEscort(1)
end
AwacsOverlord:SetBullsEyeAlias("TEXAS")
AwacsOverlord:SetAwacsDetails(CALLSIGN.AWACS.Overlord, 1, 30000, 220, 120, 20)
AwacsOverlord:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
if (moose_awacs_rejection_red_zone) then
	AwacsOverlord:SetRejectionZone(borderRed)
end
AwacsOverlord:SetAdditionalZone(borderBlue, true)
AwacsOverlord:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 2, 300)
AwacsOverlord:SetModernEraAgressive()

AwacsOverlord.PlayerGuidance = true -- allow missile warning call-outs.
AwacsOverlord.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AwacsOverlord.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AwacsOverlord.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AwacsOverlord.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AwacsOverlord.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AwacsOverlord.NoMissileCalls = false -- suppress missile callouts
AwacsOverlord.PlayerCapAssigment = true -- no task assignment for players
AwacsOverlord.invisible = true -- set AWACS to be invisible to hostiles
AwacsOverlord.immortal = true -- set AWACS to be immortal
AwacsOverlord.GoogleTTSPadding = 1 -- seconds
AwacsOverlord.WindowsTTSPadding = 2.5 -- seconds

AwacsOverlord:SuppressScreenMessages(true)

AwacsOverlord:__Start(5)

if (debug_awacs) then
	AwacsOverlord.debug = true -- set to true to produce more log output.
else
  	AwacsOverlord.debug = false
end _ _____           ____   ____ _   _ _____ ____  _   _ _     _____ ____  
/ |___ /          / ___| / ___| | | | ____|  _ \| | | | |   | ____|  _ \ 
| | |_ \   _____  \___ \| |   | |_| |  _| | | | | | | | |   |  _| | |_) |
| |___) | |_____|  ___) | |___|  _  | |___| |_| | |_| | |___| |___|  _ < 
|_|____/          |____/ \____|_| |_|_____|____/ \___/|_____|_____|_| \_\
                                                                         
function tanker_platform_updater(airwing)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission=Mission --Ops.Auftrag#AUFTRAG
        local callsign = "nil"
        local index = 99
        if (mission:GetType() == AUFTRAG.Type.TANKER) then
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive()
            
            if (mission.refuelSystem == 1) then --probe
                callsign = CALLSIGN.Tanker.Shell
            elseif (mission.refuelSystem == 0) then --boom
                callsign = CALLSIGN.Tanker.Texaco
            end
            if (string.find(mission:GetName(), "East")) then
                index = 1
            elseif (string.find(mission:GetName(), "West")) then
                index = 2
            end
            env.info(string.format("TANKER PLATFORM UPDATE %s -> %s-%d", unit_alive:GetName(), callsign, index))
            unit_alive:CommandSetCallsign(callsign, index, 1)
            
            unit_beacon = unit_alive:GetBeacon()
            if (mission.refuelSystem == 1) then --probe
                if (string.find(mission:GetName(), "East")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_e[1], FREQUENCIES.TACAN.shell_e[2], FREQUENCIES.TACAN.shell_e[3], false)
                elseif (string.find(mission:GetName(), "West")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_w[1], FREQUENCIES.TACAN.shell_w[2], FREQUENCIES.TACAN.shell_w[3], false)
                end
            elseif (mission.refuelSystem == 0) then --boom
                if (string.find(mission:GetName(), "East")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.texaco_e[1], FREQUENCIES.TACAN.texaco_e[2], FREQUENCIES.TACAN.texaco_e[3], false)
                elseif (string.find(mission:GetName(), "West")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.texaco_w[1], FREQUENCIES.TACAN.texaco_w[2], FREQUENCIES.TACAN.texaco_w[3], false)
                end
            end 
            

        end
    end
end

if (aw_vaziani) then
    tanker_platform_updater(AWVaziani)
end
if (aw_kutaisi) then
    tanker_platform_updater(AWKutaisi)
end
