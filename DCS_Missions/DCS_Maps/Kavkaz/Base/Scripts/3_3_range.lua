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
RangeKobuleti:SetDefaultPlayerSmokeBomb(true)
RangeKobuleti:SetTargetSheet(SHEET_PATH, "Range-")
RangeKobuleti:SetAutosaveOn()
RangeKobuleti:SetMessageTimeDuration(5)
RangeKobuleti:Start()
inspect = require('inspect')

function targets_coordinates(list_targets_names)
    local tgts_tbl = {}
    for index, value in ipairs(list_targets_names) do
        local unit = STATIC:FindByName(value)
        local unit_type = unit:GetTypeName()
        local coords = unit:GetCoordinate()
        local mgrs = coords:ToStringMGRS()
        local lldm = coords:ToStringLLDDM()
        table.insert(tgts_tbl, lldm .. "----" .. mgrs "\n")
    end
    return tgts_tbl
end

function range_report(range_object, table_bomb_targets, table_strafe_targets)
    local name = range_object.rangename
    local rangecontrolfreq = range_object.rangecontrolfreq
    local instructorfreq = range_object.instructorfreq
    local bomb_tgts = targets_coordinates(table_bomb_targets)
    local strafe_tgts = targets_coordinates(table_strafe_targets)

    local range_report = {}
    table.insert(range_report, os.date('%Y-%m-%d/%H%ML') .. "\n")
    table.insert(range_report, name .. "\n")
    table.insert(range_report, rangecontrolfreq .. "\n")
    table.insert(range_report, instructorfreq .. "\n")
    table.insert(range_report, "BOMB TARGETS\n")
    for index, value in ipairs(bomb_tgts) do
        table.insert(range_report, value .. "\n")
    end
    for index, value in ipairs(strafe_tgts) do
        table.insert(range_report, value .. "\n")
    end
    saveToFile(SHEET_PATH .. "\\NOTAM-RANGE-KOBULETI", table.concat(range_report))
end
