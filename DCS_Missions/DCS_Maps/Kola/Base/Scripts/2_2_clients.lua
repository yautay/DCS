local allPlayers = SET_PLAYER:New():FilterCoalitions("blue"):FilterActive():FilterStart()

allPlayers:ForEachPlayer(function(player)
    player:AddCommand("GPS Position", nil, function()
        local unit = player:GetUnit()
        if unit then
            -- Pobranie pozycji i wysokości
            local pos = unit:GetPointVec3()
            local lat, lon, alt_meters = coord.LOtoLL(pos)
            local alt_feet = alt_meters * 3.28084  -- metry na stopy

            -- Obliczenie prędkości w węzłach
            local velocity = unit:GetVelocity()
            local speed_mps = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
            local speed_knots = speed_mps * 1.94384  -- m/s na węzły

            -- Obliczenie kursu rzeczywistego
            local heading_rad = math.atan2(velocity.x, velocity.z)
            local heading_deg = math.deg(heading_rad)
            if heading_deg < 0 then heading_deg = heading_deg + 360 end  -- normalizacja do 0–360°

            -- Pobranie MGRS w wersji skróconej (100 m dokładności)
            local coordObj = COORDINATE:NewFromUnit(unit)
            local mgrsFull = coordObj:ToStringMGRS()
            local gridZone = string.sub(mgrsFull, 1, 6)
            local easting = string.sub(mgrsFull, 8, 10)
            local northing = string.sub(mgrsFull, 14, 16)
            local mgrsShort = string.format("%s %s %s", gridZone, easting, northing)

            -- Sformatowany komunikat z wyrównaniem kolumn
            local messageText = string.format(
                "%-6s %s\n" ..
                "%-6s %s\n" ..
                "%-6s %.1f ft\n" ..
                "%-6s %.1f knots\n" ..
                "%-6s %.1f°",
                "POS:", string.format("%.5f°N, %.5f°E", lat, lon),
                "MGRS:", mgrsShort,
                "ALT:", alt_feet,
                "SOG:", speed_knots,
                "COG:", heading_deg
            )

            MESSAGE:New(messageText, 15):ToPlayer(player)
        else
            MESSAGE:New("GPS SYSTEM ERROR", 5):ToPlayer(player)
        end
    end)
end)
