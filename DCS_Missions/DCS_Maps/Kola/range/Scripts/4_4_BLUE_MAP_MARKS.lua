local BLUE_COALITION = coalition.side.BLUE

local function draw_orbit(zone, label, heading, leg_nm, width_nm, color)
    if not zone then
        return
    end

    local center = zone:GetCoordinate()
    local half_leg = UTILS.NMToMeters(leg_nm / 2)
    local half_width = UTILS.NMToMeters(width_nm / 2)
    local left_heading = heading - 90
    local right_heading = heading + 90

    local start = center:Translate(half_leg, heading + 180, true):Translate(half_width, left_heading, true)
    local end_point = center:Translate(half_leg, heading, true):Translate(half_width, left_heading, true)
    local end_right = center:Translate(half_leg, heading, true):Translate(half_width, right_heading, true)
    local start_right = center:Translate(half_leg, heading + 180, true):Translate(half_width, right_heading, true)

    start:LineToAll(end_point, BLUE_COALITION, color, 1, 1, true, label)
    end_point:LineToAll(end_right, BLUE_COALITION, color, 1, 1, true)
    end_right:LineToAll(start_right, BLUE_COALITION, color, 1, 1, true)
    start_right:LineToAll(start, BLUE_COALITION, color, 1, 1, true)
    center:MarkToCoalitionBlue(label, true)
end

draw_orbit(ZoneTankers, "BLUE AAR orbit 335/50 NM\nTexaco One 252.300 AM TACAN 52Y TX1\nShell One 252.100 AM TACAN 51Y SH1", 335, 50, 6, CONST.RGB.zone_aar)
draw_orbit(ZoneAwacs, "BLUE AWACS orbit 335/50 NM\nDarkstar 249.000 AM", 335, 50, 6, CONST.RGB.zone_awacs)
