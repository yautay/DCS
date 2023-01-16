
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
        focus = {249.80, "ELINT @ DCS Focus UHF", "AM"},
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
    },
    RANGE = {
        bluewater_con = {130.10, "Bluewater RANGE CONTROL VHF", "AM"},
        bluewater_inst = {399.00, "Bluewater RANGE INSTRUCTOR VHF", "AM"}
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
    shell_1 = {51, "Y", "SH1", "Tanker Shell One", false},
    shell_2 = {53, "Y", "SH2", "Tanker Shell Two", false},
    texaco_1 = {52, "Y", "TX1", "Tanker Texaco One", false},
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

function has_value (tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
        return false
    end

function calculateCoordinateFromRoute(startCoordObject, course, distance)
	return startCoordObject:Translate(UTILS.NMToMeters(distance), course, false, false)
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
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
    FREQUENCIES.GROUND.app_lcra_u,
    FREQUENCIES.RANGE.bluewater_con,
    FREQUENCIES.RANGE.bluewater_inst,
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

MenuServer = MENU_MISSION:New("Server Menu")
MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, "Coalition Menu" )

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

--2.2 - CLIENT
CLIENTS = {
    "LOBO-1",
    "LOBO-2",
    "FAGOT-1",
    "FAGOT-2",
    "FARMER-1",
    "FARMER-2",
    "FISHBED-1",
    "FISHBED-2",
    "FULCRUM-1",
    "FULCRUM-2",
    "RED-16-S",
    "RED-16-N",
    "RED-27-N",
    "RED-27-S",
    "RED-29-N",
    "RED-29-S",
    "BLUE-16-N",
    "BLUE-16-S",
    "BLUE-27-N",
    "BLUE-27-S",
    "BLUE-29-N",
    "BLUE-29-S",
}
NAVY_CLIENTS = {
    "UZI-1",
    "UZI-2",
    "HORNET-1",
    "HORNET-2",
    "HORNET-212",
    "HORNET-237",
    "DEVIL-1",
    "DEVIL-2",
    "DEVIL-3",
    "DEVIL-4",
    "RED-18-N",
    "RED-18-S",
    "BLUE-18-N",
    "BLUE-18-S",
    "CASE 1 TRAINER A",
    "CASE 1 TRAINER B",
    "CASE 1 TRAINER C",
    "CASE 1 TRAINER D",
}

navy_in_air = {}

ClientSet = SET_CLIENT:New():FilterOnce()

function SetEventHandler()
    ClientBirth = ClientSet:HandleEvent(EVENTS.PlayerEnterAircraft)
end

function ClientSet:OnEventPlayerEnterAircraft(event_data)

    local unit_name = event_data.IniUnitName
    local group = event_data.IniGroup
    local player_name = event_data.IniPlayerName

    if has_value(NAVY_CLIENTS, unit_name) then
        env.info("CUSTOM Aviator Connected " .. unit_name)
        info_msg:SendText("Aviator " .. player_name .. " Connected!")
        env.info("CUSTOM Client " .. unit_name .. " added to book of living")
        table.insert(navy_in_air, unit_name)
    else
        env.info("CUSTOM Pilot Connected " .. unit_name)
        info_msg:SendText("Pilot " .. player_name .. " Connected!")
    end

    MESSAGE:New("Welcome, " .. player_name):ToGroup(group)
    --MESSAGE:New(GUAM_GENERAL_BRIEFING, 20):ToGroup(group)
end

SetEventHandler()

--function hearth_beet_check(list_object)
--    for index, value in ipairs(list_object) do
--        if not CLIENT:FindByName(value):IsAlive() then
--            env.info("CUSTOM Client " .. value .. " removed from book of living")
--            table.remove(value)
--        end
--    end
--end
scheduler_cvn = SCHEDULER:New( cvn_75_airboss, recheck_activation_zone, self, 10, 60 )
--garbage_remover = SCHEDULER:New( navy_in_air, hearth_beet_check, self, 27, 120 )
--3.1 - ATIS
AtisLCRA= ATIS:New(AIRBASE.Syria.Akrotiri, FREQUENCIES.GROUND.atis_lcra[1])
AtisLCRA:SetRadioRelayUnitName("LCRA Relay")
AtisLCRA:SetTowerFrequencies({FREQUENCIES.GROUND.twr_lcra_v[1], FREQUENCIES.GROUND.twr_lcra_u[1]})
AtisLCRA:AddILS(109.70, "29")
AtisLCRA:AddNDBinner(365.00)
AtisLCRA:SetSRS(SRS_PATH, "female", "en-US")
AtisLCRA:SetMapMarks()
AtisLCRA:SetTransmitOnlyWithPlayers(Switch)
AtisLCRA:Start()

--3.2 - AIRBOSS
name_CVN_75 = "CVN-75"
name_CVN_75_SAR = "CVN-SAR"
name_CVN_75_AWACS = "CVN-AWACS"
name_CVN_75_TANKER = "CVN-TANKER"
name_CVN_75_RALAY_MARSHAL = "CVN-RELAY-MARSHAL"
name_CVN_75_RALAY_LSO = "CVN-RELAY-LSO"

-- S-3B Recovery Tanker
cvn_75_tanker = RECOVERYTANKER:New(UNIT:FindByName(name_CVN_75), name_CVN_75_TANKER)
cvn_75_tanker:SetSpeed(274)
cvn_75_tanker:SetAltitude(6000)
cvn_75_tanker:SetRacetrackDistances(6, 8)
cvn_75_tanker:SetRadio(FREQUENCIES.AAR.arco[1])
cvn_75_tanker:SetCallsign(CALLSIGN.Tanker.Arco)
cvn_75_tanker:SetTakeoffHot()
cvn_75_tanker:Start()

-- E-2D AWACS
cvn_75_awacs = RECOVERYTANKER:New(name_CVN_75, name_CVN_75_AWACS)
cvn_75_awacs:SetAWACS()
cvn_75_awacs:SetRadio(FREQUENCIES.AWACS.wizard[1])
cvn_75_awacs:SetAltitude(18000)
cvn_75_awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
cvn_75_awacs:SetRacetrackDistances(20, 10)
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
cvn_75_airboss:SetLSORadio(FREQUENCIES.CV.btn1[1], FREQUENCIES.CV.btn1[3])
cvn_75_airboss:SetRadioRelayLSO(name_CVN_75_RALAY_LSO)
cvn_75_airboss:SetQueueUpdateTime(10)

-- RECOVERIES C1
--local case3_1 = cvn_75_airboss:AddRecoveryWindow("04:30", "05:00", 3, 30, false, 30)
--local case2_1 = cvn_75_airboss:AddRecoveryWindow("05:30", "06:30", 2, 30, false, 30)
--local case1_1 = cvn_75_airboss:AddRecoveryWindow("07:00", "07:20", 1, nil, false, 30)
--local case1_2 = cvn_75_airboss:AddRecoveryWindow("08:00", "08:20", 1, nil, false, 30)
--local case1_3 = cvn_75_airboss:AddRecoveryWindow("09:00", "09:20", 1, nil, false, 30)
--local case1_4 = cvn_75_airboss:AddRecoveryWindow("10:00", "10:20", 1, nil, false, 30)
--local case1_5 = cvn_75_airboss:AddRecoveryWindow("11:00", "11:20", 1, nil, false, 30)
--local case1_6 = cvn_75_airboss:AddRecoveryWindow("12:00", "12:20", 1, nil, false, 30)
-- RECOVERIES C3
-- local case3_1 = cvn_75_airboss:AddRecoveryWindow("10:00", "15:00", 3, 30, false, 30)


-- AIRBOSS SET'UP
cvn_75_airboss:SetDefaultPlayerSkill("Naval Aviator")
cvn_75_airboss:SetMenuRecovery(30, 28, true)
cvn_75_airboss:SetDespawnOnEngineShutdown()
cvn_75_airboss:Load()
cvn_75_airboss:SetAutoSave()
cvn_75_airboss:SetTrapSheet(SHEET_PATH, nil)
cvn_75_airboss:SetHandleAION()
if SERVER then
    cvn_75_airboss:SetMPWireCorrection()
end
cvn_75_airboss:SetSoundfilesFolder("Airboss Soundfiles/")
cvn_75_airboss:SetVoiceOversMarshalByGabriella("Airboss Soundfiles/Airboss Soundpack Marshal Gabriella")
cvn_75_airboss:SetVoiceOversLSOByRaynor("Airboss Soundfiles/Airboss Soundpack LSO Raynor")
cvn_75_airboss:Start()


function cvn_75_airboss:OnAfterStart(From, Event, To)
    env.info(string.format("CUSTOM ARIBOSS EVENT %S from %s to %s", Event, From, To))
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
    env.info(string.format("CUSTOM CVN LSO REPORT! : Player %s scored %.1f - wire %d", name, score, wire))
end

name_LHA_1 = "LHA-1"
name_LHA_1_SAR = "LHA-SAR"
name_LHA_1_RALAY_MARSHAL = "LHA-RELAY-MARSHAL"
name_LHA_1_RALAY_LSO = "LHA-RELAY-LSO"

-- Rescue Helo
lha_1_sar = RESCUEHELO:New(UNIT:FindByName(name_LHA_1), name_LHA_1_SAR)
lha_1_sar:Start()

-- AIRBOSS object.
lha_1_airboss = AIRBOSS:New(name_LHA_1)
lha_1_airboss:SetTACAN(TACAN.lha[1], TACAN.lha[2], TACAN.lha[3])
lha_1_airboss:SetICLS(ICLS.lha[1], ICLS.lha[2])
lha_1_airboss:SetMarshalRadio(FREQUENCIES.LHA.radar[1], FREQUENCIES.LHA.radar[3])
lha_1_airboss:SetRadioRelayMarshal(name_LHA_1_RALAY_MARSHAL)
lha_1_airboss:SetLSORadio(FREQUENCIES.LHA.tower[1], FREQUENCIES.LHA.tower[3])
lha_1_airboss:SetRadioRelayLSO(name_LHA_1_RALAY_LSO)
lha_1_airboss:SetQueueUpdateTime(30)
lha_1_airboss:SetDefaultPlayerSkill("Naval Aviator")
lha_1_airboss:SetMenuRecovery(30, 7, false)
lha_1_airboss:SetDespawnOnEngineShutdown()
lha_1_airboss:SetHandleAION()
lha_1_airboss:SetSoundfilesFolder("Airboss Soundfiles/")
lha_1_airboss:SetVoiceOversMarshalByRaynor("Airboss Soundfiles/Airboss Soundpack Marshal Raynor")
lha_1_airboss:SetVoiceOversLSOByFF("Airboss Soundfiles/Airboss Soundpack LSO FF")
lha_1_airboss:Start()



function lha_1_airboss:OnAfterStart(From, Event, To)
    env.info(string.format("CUSTOM ARIBOSS EVENT %S from %s to %s", Event, From, To))
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

    -- Report LSO grade to dcs.log file.
    env.info(string.format("CUSTOM LHA LSO REPORT! : Player %s scored %.1f - wire %d", name, score, wire))
end








--3.3 - Base

range_bluewater = RANGE:New("Bluewater Range")
zone_bluewater = ZONE_POLYGON:NewFromGroupName("BLUEWATER_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
range_bluewater:SetRangeZone(zone_bluewater)

local bombtargets = { "ASuW-1", "ASuW-2", "ASuW-3" }
local strafe_targets = { "ASuW-S-1" }

range_bluewater:AddBombingTargets(bombtargets, 50, false)

local boxlength = UTILS.NMToMeters(3)
local boxwidth = UTILS.NMToMeters(1)
local heading = 0
local foulline = 400

--Base:AddStrafePit(targetnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
range_bluewater:AddStrafePit(strafe_targets, boxlength, boxwidth, heading, false, 10, foulline)

range_bluewater:SetSRS(
        SRS_PATH,
        SRS_PORT,
        coalition.side.BLU,
        FREQUENCIES.RANGE.bluewater_con[1],
        FREQUENCIES.RANGE.bluewater_con[3],
        1
)

--Base:SetSRSRangeControl(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_bluewater:SetSRSRangeControl(
        FREQUENCIES.RANGE.bluewater_con[1],
        FREQUENCIES.RANGE.bluewater_con[3],
        nil,
        "en-US",
        "female",
        "RELAY-BLUEWATER-CON"
)

--Base:SetSRSRangeInstructor(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_bluewater:SetSRSRangeInstructor(
        FREQUENCIES.RANGE.bluewater_inst[1],
        FREQUENCIES.RANGE.bluewater_inst[3],
        nil,
        "en-US",
        "male",
        "RELAY-BLUEWATER-INS"
)

-- Start range.
range_bluewater:SetDefaultPlayerSmokeBomb(false)
range_bluewater:SetTargetSheet(SHEET_PATH, "Base-")
range_bluewater:SetAutosaveOn()
range_bluewater:SetMessageTimeDuration(10)
range_bluewater:SetFunkManOn()
range_bluewater:Start()

function report_target_coordinates(list_targets_names)
    local msg = {}
    table.insert(msg, os.date('%Y-%m-%d/%H%ML') .. "\nurgent notice\n")
    table.insert(msg, "bluewater range active " .. os.date('%Y-%m-%d') .. "/0400Z/1800Z" .. "\n")
    table.insert(msg, "range control/" .. FREQUENCIES.RANGE.bluewater_con[1] .. "/AM\n")
    table.insert(msg, "range instructor/" .. FREQUENCIES.RANGE.bluewater_inst[1] .. "/AM\n")
    table.insert(msg, "targets positioned VC-bomb targets / WC-strafe targets\n")
    for index, value in ipairs(list_targets_names) do
        local unit = STATIC:FindByName(value)
        local unit_type = unit:GetTypeName()
        local coords = unit:GetCoordinate()
        local mgrs = coords:ToStringMGRS()
        table.insert(msg, mgrs .. "\n")
    end
    table.insert(msg, "bombing ingress leg up to cmdr discretion\nstrafe box len 3Nm/ wid 1Nm/ rad 360/ foul 400mtrs\n")
    table.insert(msg, "proceed with caution friendly ffg and lpd in close vicinity\nreport recieved information george upon checkin\nnnnn\n")
    local final_msg = table.concat(msg)
    env.info("CUSTOM\n" .. final_msg)
    return final_msg
end

info_msg:SendText(report_target_coordinates({ bombtargets[1], bombtargets[2], bombtargets[3], strafe_targets[1] }))
--AW.1 - AW AKROTIRI
ZONE_DARKSTAR_1_AWACS = ZONE:New("DARKSTAR_1_AWACS")
ZONE_DARKSTAR_1_PATROL_CAP = ZONE:New("DARKSTAR_1_PATROL_CAP"):DrawZone(2, CONST.RGB.zone_patrol, 1, CONST.RGB.zone_patrol, .5, 1, true)
ZONE_DARKSTAR_1_ENGAGE = ZONE:New("DARKSTAR_1_ENGAGE")

AW_LCRA = AIRWING:New("WH Akrotiri", "Akrotiri Air Wing")

AW_LCRA:SetMarker(false)
AW_LCRA:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Akrotiri))
AW_LCRA:SetRespawnAfterDestroyed(600)
AW_LCRA:__Start(2)

AW_LCRA_AWACS = SQUADRON:New("ME AWACS E3", 2, "AWACS")
AW_LCRA_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_LCRA_AWACS:SetTakeoffType("Hot")
AW_LCRA_AWACS:SetFuelLowRefuel(true)
AW_LCRA_AWACS:SetFuelLowThreshold(0.4)
AW_LCRA_AWACS:SetTurnoverTime(30, 5)
AW_LCRA_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_LCRA:AddSquadron(AW_LCRA_AWACS)
AW_LCRA:NewPayload("ME AWACS E3", -1, { AUFTRAG.Type.ORBIT }, 100)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Darkstar_1_1_route = {ZONE_DARKSTAR_1_AWACS:GetCoordinate(), 35000, 450, 180, 80}

AWACS_DARKSTAR = AWACS:New("DARKSTAR", AW_LCRA, "blue", AIRBASE.Syria.Akrotiri, "DARKSTAR_1_AWACS", "DARKSTAR_1_ENGAGE", "DARKSTAR_1_PATROL_CAP", FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWACS_DARKSTAR:SetBullsEyeAlias("CRUSADER")
AWACS_DARKSTAR:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, Darkstar_1_1_route[2], Darkstar_1_1_route[3], Darkstar_1_1_route[4], Darkstar_1_1_route[5])
AWACS_DARKSTAR:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_DARKSTAR:SetModernEraAggressive()

AWACS_DARKSTAR.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_DARKSTAR.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
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

--TANKERS BLUE
Spawn_Shell_One= SPAWN:New("SPAWN SH1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (shell_11) shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1) end):InitRepeatOnLanding()
Spawn_Shell_Two = SPAWN:New("SPAWN SH2"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (shell_12) shell_12:CommandSetCallsign(CALLSIGN.Tanker.Shell, 2) end):InitRepeatOnLanding()
Spawn_Texaco_One = SPAWN:New("SPAWN TX1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_11) texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1) end):InitRepeatOnLanding()
Spawn_Focus_One = SPAWN:New("SPAWN FC1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (facus_11) facus_11:CommandSetCallsign(CALLSIGN.AWACS.Focus, 1) end):InitRepeatOnLanding()
--BVR TRAINER
ZONE_SPAWN_1 = ZONE:New("SPAWN-1")
ZONE_SPAWN_2 = ZONE:New("SPAWN-2")
ZONE_SPAWN_3 = ZONE:New("SPAWN-3")
ZONE_SPAWN_4 = ZONE:New("SPAWN-4")
ZONE_SPAWN_5 = ZONE:New("SPAWN-5")
ZONE_SPAWN_6 = ZONE:New("SPAWN-6")
SPAWN_ZONES = {ZONE_SPAWN_1, ZONE_SPAWN_2, ZONE_SPAWN_3, ZONE_SPAWN_4, ZONE_SPAWN_5, ZONE_SPAWN_6}

TEMPLATE_SU27 = "SPAWN-RED-BVR-SU27_"
TEMPLATE_MiG23 = "SPAWN-RED-BVR-M23_"
TEMPLATE_MiG29 = "SPAWN-RED-BVR-M29_"
TEMPLATE_SU30 = "SPAWN-RED-BVR-SU30_"

SUFFIX_ACE = "ACE"
SUFFIX_VET = "VET"
SUFFIX_TRN = "TRN"

SUFFIX_PAIR = "-2"


MenuBvr = MENU_COALITION:New(coalition.side.BLUE, "BVR Trainer", MenuCoalitionBlue)
MenuBvr_Su27 = MENU_COALITION:New(coalition.side.BLUE, "Cy-27", MenuBvr)
MenuBvr_Su30 = MENU_COALITION:New(coalition.side.BLUE, "Су-30", MenuBvr)
MenuBvr_Mig23 = MENU_COALITION:New(coalition.side.BLUE, "МиГ-23", MenuBvr)
MenuBvr_Mig29 = MENU_COALITION:New(coalition.side.BLUE, "МиГ-29", MenuBvr)

MenuBvr_Su27_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Su27)
MenuBvr_Su27_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Su27)
MenuBvr_Su27_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Su27)

MenuBvr_Su30_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Su30)
MenuBvr_Su30_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Su30)
MenuBvr_Su30_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Su30)

MenuBvr_Mig23_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Mig23)
MenuBvr_Mig23_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Mig23)
MenuBvr_Mig23_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Mig23)

MenuBvr_Mig29_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Mig29)
MenuBvr_Mig29_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Mig29)
MenuBvr_Mig29_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Mig29)



local function Spawn_Group(template_name)
    local spawned_group = SPAWN
           :New(template_name)
           :InitRandomizeZones( SPAWN_ZONES )
           :Spawn()
    local dest = ZONE_DARKSTAR_1_ENGAGE:GetVec2()
    local coord_dest = COORDINATE:NewFromVec2(dest, UTILS.FeetToMeters(30000))
    spawned_group:RouteAirTo(coord_dest, COORDINATE.WaypointAltType.BARO, COORDINATE.WaypointType.TurningPoint, COORDINATE.WaypointAction.FlyoverPoint, UTILS.KnotsToKmph(750))
    spawned_group:EnRouteTaskEngageTargetsInZone(dest, UTILS.NMToMeters(60))
    local msg = template_name .. " SPAWNED!"
    Msg({msg, 3})
end

-- SU-27
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su27_ace, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su27_ace, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su27_vet, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su27_vet, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su27_trn, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su27_trn, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_TRN .. SUFFIX_PAIR)
-- SU-30
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su30_ace, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su30_ace, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su30_vet, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su30_vet, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su30_trn, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su30_trn, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_TRN .. SUFFIX_PAIR)
-- MiG-23
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig23_ace, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig23_ace, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig23_vet, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig23_vet, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig23_trn, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig23_trn, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_TRN .. SUFFIX_PAIR)
-- MiG-29
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig29_ace, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig29_ace, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig29_vet, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig29_vet, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig29_trn, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig29_trn, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_TRN .. SUFFIX_PAIR)

