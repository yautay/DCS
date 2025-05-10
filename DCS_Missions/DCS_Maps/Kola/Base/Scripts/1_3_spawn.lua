function SpawnAdversary(template, blue_unit, distance_nm, skill)
    local blue_unit_data = blue_unit
    local blue_pos = blue_unit_data:GetPointVec3()
    local blue_alt = blue_unit_data:GetAltitude()
    local blue_velocity = blue_unit_data:GetVelocityVec3()  -- wektor prędkości (x, y, z)

    local distance_m = distance_nm * 1852

    local heading_rad = math.atan2(blue_velocity.x, blue_velocity.z)
    local heading_deg = math.deg(heading_rad)
    if heading_deg < 0 then
        heading_deg = heading_deg + 360  -- normalizacja do 0–360°
    end

    local delta_x = math.sin(math.rad(heading_deg)) * distance_m
    local delta_z = math.cos(math.rad(heading_deg)) * distance_m

    local red_position = {
        x = blue_pos.x + delta_x,
        y = blue_alt,  -- albo np. blue_alt + 100 dla „z góry”
        z = blue_pos.z + delta_z
    }
    red_position = COORDINATE:NewFromVec3(red_position)
    local blue_position = COORDINATE:NewFromVec3(blue_pos)
    local group = SPAWN:New(template):InitSkill(skill):SpawnFromVec3(red_position)
    group:PatrolRaceTrack(red_position, blue_position)
    group:OptionROEWeaponFree()
    group:OptionROTEvadeFire()
end

