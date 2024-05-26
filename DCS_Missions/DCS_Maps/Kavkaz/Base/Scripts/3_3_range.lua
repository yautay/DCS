NO_RangeKobuleti = RANGE:New("Kobuleti")
ZoneKobuletiRange = ZONE_POLYGON:NewFromGroupName("KOBULETI_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
NO_RangeKobuleti:SetRangeZone(ZoneKobuletiRange)

BombTargetsRangeKobuleti = { "TARGET_BMB" }
StrafeTargetsRangeKobuleti = { "TARGET_STR" }

NO_RangeKobuleti:AddBombingTargets(BombTargetsRangeKobuleti, 20, false)

local boxlength = UTILS.NMToMeters(3)
local boxwidth = UTILS.NMToMeters(1)
local heading = 0
local foulline = 150

--Base:AddStrafePit(targetnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
NO_RangeKobuleti:AddStrafePit(StrafeTargetsRangeKobuleti, boxlength, boxwidth, heading, false, 10, foulline)

-- Start range.
NO_RangeKobuleti:SetDefaultPlayerSmokeBomb(true)
NO_RangeKobuleti:SetTargetSheet(SHEET_PATH, "Range-")
NO_RangeKobuleti:SetAutosaveOn()
NO_RangeKobuleti:SetMessageTimeDuration(5)
NO_RangeKobuleti:Start()

function targets_coordinates(list_targets_names)
    local tgts_tbl = {}
    for index, value in ipairs(list_targets_names) do
        local unit = STATIC:FindByName(value)
        local unit_type = unit:GetTypeName()
        local coords = unit:GetCoordinate()
        local mgrs = coords:ToStringMGRS()
        local lldm = coords:ToStringLLDDM()
        table.insert(tgts_tbl, lldm .. "   " .. mgrs .. "\n")
    end
    return tgts_tbl
end

function range_report(range_object, table_bomb_targets, table_strafe_targets)
    local name = range_object.rangename
    local bomb_tgts = targets_coordinates(table_bomb_targets)
    local strafe_tgts = targets_coordinates(table_strafe_targets)

    local range_report = {}
    table.insert(range_report, os.date('%Y-%m-%d/%H%ML') .. "\n")
    table.insert(range_report, name .. "\n")
    table.insert(range_report, "BOMB TARGETS\n")
    for index, value in ipairs(bomb_tgts) do
        table.insert(range_report, value)
    end
    table.insert(range_report, "STRAFE TARGETS\n")
    for index, value in ipairs(strafe_tgts) do
        table.insert(range_report, value)
    end
    saveToFile(SHEET_PATH .. "\\NOTAM-RANGE-" .. string.upper(name), table.concat(range_report))
end

range_report(NO_RangeKobuleti, BombTargetsRangeKobuleti, StrafeTargetsRangeKobuleti)