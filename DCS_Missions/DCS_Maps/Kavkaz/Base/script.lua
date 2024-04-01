
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
HELPERS = {
    SOCKET_NOTAM = "custom_notam"
}
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
        atis_ag1651 = {125.000, "ATIS Senaki", "AM"},
        twr_ag1651_1 = {40.600, "TOWER Senaki VHF/LOW", "AM"},
        twr_ag1651_2 = {132.000, "TOWER Senaki VHF", "AM"},
        twr_ag1651_3 = {261.000, "TOWER Senaki UHF", "AM"},
    },
    SPECIAL = {
        guard_hi = {243.00, "Guard UHF", "AM"},
        guard_lo = {121.50, "Guard VHF", "AM"},
        ch_16 = {156.8, "Maritime Ch16 VHF", "FM"}
    },
    RANGE = {
        kobuleti_con = {132, "Bluewater RANGE CONTROL VHF", "AM"},
        kobuleti_inst = {40.6, "Bluewater RANGE INSTRUCTOR VHF", "AM"}
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
-- YARDSTICKS = {
--     sting_1 = {"STING ONE", 37, 100, "Y"},
--     joker_1 = {"JOKER TWO", 38, 101, "Y"},
--     hawk_1 = {"HAWK ONE", 39, 102, "Y"},
--     devil_1 = {"DEVIL TWO", 40, 103, "Y"},
--     squid_1 = {"SQUID ONE", 41, 104, "Y"},
--     check_1 = {"CHECK TWO", 42, 105, "Y"},
--     viper_1 = {"VIPER ONE", 43, 106, "Y"},
--     venom_1 = {"VENOM TWO", 44, 107, "Y"},
--     jedi_1 = {"JEDI ONE", 45, 108, "Y"},
--     ninja_1 = {"NINJA TWO", 46, 109, "Y"},
-- }


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

function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function msgToAll(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end
--2.2 - CLIENT
ClientSet = SET_CLIENT:New():FilterOnce()

function SetEventHandler()
    ClientBirth = ClientSet:HandleEvent(EVENTS.PlayerEnterAircraft)
end

function ClientSet:OnEventPlayerEnterAircraft(event_data)
    local unit_name = event_data.IniUnitName
    local group = event_data.IniGroup
    local player_name = event_data.IniPlayerName
    local client = "Pilot " .. player_name .. " to " .. unit_name .. " Connected!"
    env.info(client)
end

SetEventHandler()

--3.3 - Base
range_kobuleti = RANGE:New("Kobuleti Range")
zone_kobuleti = ZONE_POLYGON:NewFromGroupName("KOBULETI_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
range_kobuleti:SetRangeZone(zone_kobuleti)

local bombtargets = { "TARGETS" }
local strafe_targets = { "STRAFER" }

range_kobuleti:AddBombingTargets(bombtargets, 50, false)

local boxlength = UTILS.NMToMeters(3)
local boxwidth = UTILS.NMToMeters(1)
local heading = 180
local foulline = 500

--Base:AddStrafePit(targetnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
range_kobuleti:AddStrafePit(strafe_targets, boxlength, boxwidth, heading, false, 10, foulline)

range_kobuleti:SetSRS(
        SRS_PATH,
        SRS_PORT,
        coalition.side.BLUE,
        FREQUENCIES.RANGE.kobuleti_con[1],
        FREQUENCIES.RANGE.kobuleti_con[3],
        1
)

--Base:SetSRSRangeControl(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_kobuleti:SetSRSRangeControl(
        FREQUENCIES.RANGE.kobuleti_con[1],
        FREQUENCIES.RANGE.kobuleti_con[3],
        nil,
        "en-US",
        "female",
        "RELAY-KOBULETI"
)

--Base:SetSRSRangeInstructor(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_kobuleti:SetSRSRangeInstructor(
        FREQUENCIES.RANGE.bluewater_inst[1],
        FREQUENCIES.RANGE.bluewater_inst[3],
        nil,
        "en-US",
        "male",
        "RELAY-KOBULETI"
)

-- Start range.
range_kobuleti:SetDefaultPlayerSmokeBomb(false)
range_kobuleti:SetTargetSheet(SHEET_PATH, "Base-")
range_kobuleti:SetAutosaveOn()
range_kobuleti:SetMessageTimeDuration(3)
range_kobuleti:Start()

function report_target_coordinates(list_targets_names)
    local tmp_msg = {}
    table.insert(tmp_msg, os.date('%Y-%m-%d/%H%ML') .. " NOTICE ")
    table.insert(tmp_msg, "KOBULETI RANGE ACTIVE " .. os.date('%Y-%m-%d') .. "/0400Z/1800Z" .. " ")
    table.insert(tmp_msg, "RANGE CONTROL/" .. FREQUENCIES.RANGE.bluewater_con[1] .. "/AM ")
    table.insert(tmp_msg, "RANGE INSTRUCTOR/" .. FREQUENCIES.RANGE.bluewater_inst[1] .. "/AM ")
    table.insert(tmp_msg, "TARGETS POSITIONED VC-BOMB TARGETS / WC-STRAFE TARGETS ")
    for index, value in ipairs(list_targets_names) do
        local unit = STATIC:FindByName(value)
        local unit_type = unit:GetTypeName()
        local coords = unit:GetCoordinate()
        local mgrs = coords:ToStringMGRS()
        table.insert(tmp_msg, mgrs .. "\n")
    end
    table.insert(tmp_msg, "BOMBING INGRESS LEG UP TO CMDR DISCRETION STRAFE BOX LEN 3NM/ WID 1NM/ RAD 180/ FOUL 500MTRS ")
    table.insert(tmp_msg, "PROCEED WITH CAUTION REPORT RECIEVED INFORMATION KILO UPON CHECKIN ")
    local final_msg = table.concat(tmp_msg)
    env.info("CUSTOM\n" .. final_msg)
    return final_msg
end

function getRangeData(string_report)
    local range_msg={}
    range_msg.command=HELPERS.SOCKET_NOTAM
    range_msg.server_name="Nygus Server"
    range_msg.text=string_report
--     socketBot:SendTable(range_msg)
end

range_msg = report_target_coordinates({ bombtargets[1], strafe_targets[1] })

--SchedulerBluewaterRangeObject = SCHEDULER:New( range_bluewater )
--SchedulerBluewaterRange = SchedulerBluewaterRangeObject:Schedule( range_bluewater, getRangeData, range_msg, 10)
--9.1 - ATIS
AtisAG1651= ATIS:New(AIRBASE.Caucasus.Senaki_Kolkhi, FREQUENCIES.GROUND.atis_ag1651[1])
AtisAG1651:SetRadioRelayUnitName("AG1651 Relay")
AtisAG1651:SetTowerFrequencies({FREQUENCIES.GROUND.twr_ag1651_1[1], FREQUENCIES.GROUND.twr_ag1651_2[1], , FREQUENCIES.GROUND.twr_ag1651_3[1]})
AtisAG1651:AddILS(108.90, "09")
AtisAG1651:ATIS.SetTACAN(31)
AtisAG1651:SetSRS(SRS_PATH, "female", "en-US")
AtisAG1651:SetMapMarks()
AtisAG1651:SetTransmitOnlyWithPlayers(true)
AtisAG1651:ReportZuluTimeOnly()
AtisAG1651:Start()

function getAtisData(atisObject)
    local atis_msg={}
    atis_msg.command=HELPERS.SOCKET_NOTAM
    atis_msg.server_name="Nygus Server"
    atis_msg.text="\n\n" .. string.upper(atisObject:GetSRSText()) .. "\n\n"
--     if (atis_msg.text) then
--         socketBot:SendTable(atis_msg)
--     end
end

SchedulerLCRAMasterObject = SCHEDULER:New( AtisLCRA )
SchedulerLCRA = SchedulerLCRAMasterObject:Schedule( AtisLCRA, getAtisData, {AtisLCRA}, 75)
