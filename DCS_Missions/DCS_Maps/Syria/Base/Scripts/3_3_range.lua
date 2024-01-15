
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
        coalition.side.BLUE,
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
range_bluewater:Start()

function report_target_coordinates(list_targets_names)
    local tmp_msg = {}
    table.insert(tmp_msg, os.date('%Y-%m-%d/%H%ML') .. " NOTICE ")
    table.insert(tmp_msg, "BLUEWATER RANGE ACTIVE " .. os.date('%Y-%m-%d') .. "/0400Z/1800Z" .. " ")
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
    table.insert(tmp_msg, "BOMBING INGRESS LEG UP TO CMDR DISCRETION STRAFE BOX LEN 3NM/ WID 1NM/ RAD 360/ FOUL 400MTRS ")
    table.insert(tmp_msg, "PROCEED WITH CAUTION FRIENDLY FFG AND LPD IN CLOSE VICINITY REPORT RECIEVED INFORMATION GEORGE UPON CHECKIN ")
    local final_msg = table.concat(tmp_msg)
    env.info("CUSTOM\n" .. final_msg)
    return final_msg
end

function getRangeData(string_report)
    local range_msg={}
    range_msg.command=HELPERS.SOCKET_NOTAM
    range_msg.server_name="Nygus Server"
    range_msg.text=string_report
    socketBot:SendTable(range_msg)
end

range_msg = report_target_coordinates({ bombtargets[1], bombtargets[2], bombtargets[3], strafe_targets[1] })

--SchedulerBluewaterRangeObject = SCHEDULER:New( range_bluewater )
--SchedulerBluewaterRange = SchedulerBluewaterRangeObject:Schedule( range_bluewater, getRangeData, range_msg, 10)