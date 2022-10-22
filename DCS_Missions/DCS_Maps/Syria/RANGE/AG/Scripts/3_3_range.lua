range_bluewater = RANGE:New("Bluewater Range")
zone_bluewater = ZONE_POLYGON:NewFromGroupName("BLUEWATER_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
range_bluewater:SetRangeZone( zone_bluewater )

local bombtargets={"ASuW-1", "ASuW-2", "ASuW-3"}
range_bluewater:AddBombingTargets(bombtargets, 50, false)

range_bluewater:SetSRS(
        SRS_PATH,
        SRS_PORT,
        coalition.side.BLU,
        FREQUENCIES.RANGE.bluewater_con[1],
        FREQUENCIES.RANGE.bluewater_con[3],
        1
)

--RANGE:SetSRSRangeControl(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_bluewater:SetSRSRangeControl(
        FREQUENCIES.RANGE.bluewater_con[1],
        FREQUENCIES.RANGE.bluewater_con[3],
        nil,
        "en-US",
        "female",
        "RELAY-BLUEWATER-CON"
)

--RANGE:SetSRSRangeInstructor(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
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
range_bluewater:SetTargetSheet( SHEET_PATH, "RANGE-" )
range_bluewater:SetAutosaveOn()
range_bluewater:SetMessageTimeDuration(10)
range_bluewater:SetFunkManOn()
range_bluewater:Start()

function report_target_coordinates(list_targets_names)
    local msg = {}
    table.insert(msg, os.date('%Y-%m-%d/%H%ML') .. "\nurgent notice\n")
    table.insert(msg, "bluewater range active " .. os.date('%Y-%m-%d') .. "/0400Z/1800Z" .."\n")
    table.insert(msg, "range control/" .. FREQUENCIES.RANGE.bluewater_con[1] .. "/AM\n")
    table.insert(msg, "range instructor/" .. FREQUENCIES.RANGE.bluewater_inst[1] .. "/AM\n")
    table.insert(msg, "targets positioned\n")
    for index, value in ipairs(list_targets_names) do
        local unit = STATIC:FindByName(value)
        local unit_type = unit:GetTypeName()
        local coords = unit:GetCoordinate()
        local mgrs = coords:ToStringMGRS()
        table.insert(msg, mgrs .. "\n")
    end
    table.insert(msg, "proceed with caution friendly ffg and lpd in close vicinity\nreport recieved information george upon checkin\nnnnn\n")
    local final_msg = table.concat(msg)
    env.info("CUSTOM\n" .. final_msg)
    return final_msg
end

info_msg:SendText(report_target_coordinates(bombtargets))