
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
FREQUENCIES_MAP = {
    GROUND = {
            atis_ag1651 = {125.000, "ATIS Senaki", "AM"},
            twr_ag1651_1 = {40.600, "TOWER Senaki VHF/LOW", "AM"},
            twr_ag1651_2 = {132.000, "TOWER Senaki VHF", "AM"},
            twr_ag1651_3 = {261.000, "TOWER Senaki UHF", "AM"},
        },
    SPECIAL = {
        guard_hi = {243.00, "Guard UHF", "AM"},
        guard_lo = {121.50, "Guard VHF", "AM"},
        ch_16 = {156.8, "Maritime Ch16 VHF", "FM"},
    },
}
FREQUENCIES = {
    RANGE = {
            CONTROL_KOBULETI = {124.8, "RANGE CONTROL VHF", "AM"},
            INSTRUCTOR_KOBULETI = {251.0, "RANGE INSTRUCTOR VHF", "AM"}
            },
    FLIGHTS = {
        JG52_1 = {45, "JG52 Ch1", "AM"},
        JG52_2 = {40.6, "JG52 Ch2", "AM"},
        JG52_3 = {41, "JG52 Ch3", "AM"},
        JG52_4 = {42, "JG52 Ch4", "AM"},
        COALITION_1 = {132, "COALITION #1", "AM"},
        COALITION_2 = {101, "COALITION #2", "AM"},
        COALITION_3 = {102, "COALITION #3", "AM"},
        COALITION_4 = {103, "COALITION #4", "AM"},
    },
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
RangeKobuleti = RANGE:New("Kobuleti Range")
ZoneKobuletiRange = ZONE_POLYGON:NewFromGroupName("KOBULETI_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
RangeKobuleti:SetRangeZone(ZoneKobuletiRange)

local bombtargets = { "TARGET_BMB" }
local strafe_targets = { "TARGET_STR" }

RangeKobuleti:AddBombingTargets(bombtargets, 50, false)

local boxlength = UTILS.NMToMeters(3)
local boxwidth = UTILS.NMToMeters(1)
local heading = 0
local foulline = 500

--Base:AddStrafePit(targetnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
RangeKobuleti:AddStrafePit(strafe_targets, boxlength, boxwidth, heading, false, 10, foulline)

RangeKobuleti:SetSRS(
        SRS_PATH,
        SRS_PORT,
        coalition.side.BLUE,
        FREQUENCIES.RANGE.CONTROL_KOBULETI[1],
        FREQUENCIES.RANGE.CONTROL_KOBULETI[3],
        1
)

--Base:SetSRSRangeControl(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
RangeKobuleti:SetSRSRangeControl(
        FREQUENCIES.RANGE.CONTROL_KOBULETI[1],
        FREQUENCIES.RANGE.CONTROL_KOBULETI[3],
        nil,
        "en-US",
        "female",
        "RELAY-KOBULETI"
)

--Base:SetSRSRangeInstructor(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
RangeKobuleti:SetSRSRangeInstructor(
        FREQUENCIES.RANGE.INSTRUCTOR_KOBULETI[1],
        FREQUENCIES.RANGE.INSTRUCTOR_KOBULETI[3],
        nil,
        "en-US",
        "male",
        "RELAY-KOBULETI"
)

-- Start range.
RangeKobuleti:SetDefaultPlayerSmokeBomb(false)
RangeKobuleti:SetTargetSheet(SHEET_PATH, "Base-")
RangeKobuleti:SetAutosaveOn()
RangeKobuleti:SetMessageTimeDuration(5)
RangeKobuleti:Start()

function report_target_coordinates(list_targets_names)
    local tmp_msg = {}
    table.insert(tmp_msg, os.date('%Y-%m-%d/%H%ML') .. " NOTICE ")
    table.insert(tmp_msg, "KOBULETI RANGE ACTIVE " .. os.date('%Y-%m-%d') .. "/0400Z/1800Z" .. " ")
    table.insert(tmp_msg, "RANGE CONTROL/" .. FREQUENCIES.RANGE.CONTROL_KOBULETI[1] .. "/AM ")
    table.insert(tmp_msg, "RANGE INSTRUCTOR/" .. FREQUENCIES.RANGE.INSTRUCTOR_KOBULETI[1] .. "/AM ")
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

--SchedulerBluewaterRangeObject = SCHEDULER:New( RangeKobuleti )
--SchedulerBluewaterRange = SchedulerBluewaterRangeObject:Schedule( RangeKobuleti, getRangeData, range_msg, 10)
--9.1 - ATIS
AtisAG1651= ATIS:New(AIRBASE.Caucasus.Senaki_Kolkhi, FREQUENCIES_MAP.GROUND.atis_ag1651[1])
AtisAG1651:SetRadioRelayUnitName("AG1651 Relay")
AtisAG1651:SetTowerFrequencies({FREQUENCIES_MAP.GROUND.twr_ag1651_1[1], FREQUENCIES_MAP.GROUND.twr_ag1651_2[1], FREQUENCIES_MAP.GROUND.twr_ag1651_3[1]})
AtisAG1651:AddILS(108.90, "09")
AtisAG1651:SetTACAN(31)
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

SchedulerLCRAMasterObject = SCHEDULER:New( AtisAG1651 )
SchedulerLCRA = SchedulerLCRAMasterObject:Schedule( AtisAG1651, getAtisData, {AtisAG1651}, 75)
