function plot_strafe_box(static_name, boxlength, boxwidth, heading, foulline)

    local tgt_coord = STATIC:FindByName(static_name):GetCoordinate()
    local w = boxwidth / 2
    local l = boxlength

    local c1 = tgt_coord:Translate(w, heading + 90)
    local c2 = p[#p]:Translate(l, heading)
    local c3 = p[#p]:Translate(2 * w, heading - 90)
    local c4 = p[#p]:Translate(-l, heading)

    c1:QuadToAll(c2, c3, c4, 2, CONST.RGB.zone_red, .3, CONST.RGB.zone_red, .3, 2, True, "Strafe Box")

    local vec2 = { c1:GetVec2(), c2:GetVec2(), c3:GetVec2(), c4:GetVec2() }

    args[1]:UpdateFromVec2(vec2)

end

range_bluewater = RANGE:New("Bluewater Range")
zone_bluewater = ZONE_POLYGON:NewFromGroupName("BLUEWATER_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
range_bluewater:SetRangeZone(zone_bluewater)

local bombtargets = { "ASuW-1", "ASuW-2", "ASuW-3" }
local strafe_targets = { "ASuW-S-1", "ASuW-S-2", "ASuW-S-3" }

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

info_msg:SendText(report_target_coordinates({ bombtargets[1], bombtargets[2], bombtargets[3], strafe_targets[1], strafe_targets[2], strafe_targets[3] }))