allPlayers = SET_PLAYER:New():FilterCoalitions("blue"):FilterActive():FilterStart()

allPlayers:ForEachPlayer(function(player)
    player:AddCommand("GPS Position", nil, function()
        local unit = player:GetUnit()
        if unit then
        local pos = unit:GetPointVec3()
        local lat, lon, alt_meters = coord.LOtoLL(pos)
        local alt_feet = alt_meters * 3.28084 -- metry na stopy

        local velocity = unit:GetVelocity()
        local speed_mps = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
        local speed_knots = speed_mps * 1.94384 -- m/s na węzły

        local heading_rad = math.atan2(velocity.x, velocity.z)
        local heading_deg = math.deg(heading_rad)
        if heading_deg < 0 then heading_deg = heading_deg + 360 end -- normalize do 0-360

        local messageText = string.format(
            "POS: %.5f°N, %.5f°E\n" ..
            "ALT: %.1f ft\n" ..
            "SOG: %.1f knots\n" ..
            "COG: %.1f°",
            lat, lon, alt_feet, speed_knots, heading_deg
        )

        MESSAGE:New(messageText, 15):ToPlayer(myPlayer)
    else
        MESSAGE:New("GPS SYSTEM ERROR", 5):ToPlayer(myPlayer)
    end
end
