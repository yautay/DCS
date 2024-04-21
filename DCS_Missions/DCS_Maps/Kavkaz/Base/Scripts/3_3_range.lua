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
    env.info(final_msg)
    return final_msg
end

function getRangeData(string_report)
    local range_msg={}
    range_msg.command=HELPERS.SOCKET_NOTAM
    range_msg.server_name="Nygus Server"
    range_msg.text=string_report
--     socketBot:SendTable(range_msg)
    env.info("RANGE KOBULETI\n" .. range_msg.text)
end

range_msg = report_target_coordinates({ bombtargets[1], strafe_targets[1] })

SchedulerBluewaterRangeObject = SCHEDULER:New( RangeKobuleti )
SchedulerBluewaterRange = SchedulerBluewaterRangeObject:Schedule( RangeKobuleti, getRangeData, {range_msg}, 7)