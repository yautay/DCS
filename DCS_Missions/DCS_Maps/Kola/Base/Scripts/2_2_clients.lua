ClientSet = SET_CLIENT:New():FilterStart()
ClientSet:HandleEvent(EVENTS.PlayerEnterAircraft)

local function AddGPSCommandToPlayer(unit)
    local function formatLatLon(lat, lon)
        local lat_deg = math.floor(math.abs(lat))
        local lat_min = (math.abs(lat) - lat_deg) * 60
        local lat_dir = lat >= 0 and "N" or "S"

        local lon_deg = math.floor(math.abs(lon))
        local lon_min = (math.abs(lon) - lon_deg) * 60
        local lon_dir = lon >= 0 and "E" or "W"

        return string.format("%02d°%.2f'%s, %03d°%.2f'%s", lat_deg, lat_min, lat_dir, lon_deg, lon_min, lon_dir)
    end

    local speed_knots = 0
    local heading_deg = 0
    if unit then
        local unit_data = unit[1]
        -- Pozycja i wysokość
        local pos = unit_data:GetPointVec3()
        local lat, lon, alt_meters = coord.LOtoLL(pos)
        local alt_feet = alt_meters * 3.28084

        -- Prędkość w węzłach
        speed_knots = unit_data:GetVelocityKNOTS()
        env.info("SOG: " .. speed_knots)
        -- Kurs
        heading_deg = unit_data:GetHeading()
        env.info("COG: " .. heading_deg)
        -- MGRS
        local coordObj = COORDINATE:New(pos)
        local mgrsFull = coordObj:ToStringMGRS()
        -- Usuń prefix „MGRS ” (5 znaków)
        mgrsFull = string.sub(mgrsFull, 6)
        -- Usuń wszystkie spacje
        mgrsFull = string.gsub(mgrsFull, "%s+", "")
        env.info("Raw MGRS: " .. mgrsFull)
        env.info("Length of MGRS: " .. tostring(string.len(mgrsFull)))
        local zoneNumber = string.sub(mgrsFull, 1, 2) -- 35
        local zoneLetter = string.sub(mgrsFull, 3, 3) -- W
        local squareId = string.sub(mgrsFull, 4, 5) -- MP
        local easting = string.sub(mgrsFull, 6, 10) -- 47983
        local northing = string.sub(mgrsFull, 11, 15) -- 83679
        local easting100m = string.sub(easting, 1, 3) -- 479
        local northing100m = string.sub(northing, 1, 3) -- 836
        local mgrsFormatted = string.format("(%s %s) %s %s %s", zoneNumber, zoneLetter, squareId, easting100m, northing100m)
        local mgrsFullFormatted = string.format("(%s %s) %s %s %s", zoneNumber, zoneLetter, squareId, easting, northing)

        -- Wiadomość
        local formattedLatLon = formatLatLon(lat, lon)

        local messageText =
            string.format(
            "%-6s %s\n%-6s %s\n%-6s %s\n%-6s %.1f ft\n%-6s %.1f knots\n%-6s %.1f°",
            "POS      :",
            formattedLatLon,
            "MGRS 100m:",
            mgrsFormatted,
            "MGRS Full:",
            mgrsFullFormatted,
            "ALT      :",
            alt_feet,
            "SOG      :",
            speed_knots,
            "COG      :",
            heading_deg
            )

        env.info(messageText)
        MESSAGE:New(messageText, 30):ToUnit(unit_data)
    else
        MESSAGE:New("GPS SYSTEM ERROR", 5):ToUnit(unit_data)
    end
end

function AddSpawnAdversaryCommandToPlayer(args_dict)
    SpawnAdversary(args_dict[2], args_dict[1], args_dict[3], args_dict[4])
    local messageText = string.format(
        "SPAWNED: %s | Distance: %.1f NM | Skill: %s",
        args_dict[2], args_dict[3], args_dict[4]
    )
    MESSAGE:New(messageText, 5):ToAll()
end

function ClientSet:OnEventPlayerEnterAircraft(event_data)
    local client = CLIENT:FindByPlayerName(event_data.IniPlayerName)
    local unit = UNIT:FindByName(event_data.IniUnitName)

    local tools_menu = CLIENTMENU:NewEntry(client, "TOOLS")
    local spawn_menu = CLIENTMENU:NewEntry(client, "SPAWN ADVERSARY", tools_menu)

    local SKILL_LEVELS = { "Good", "High", "Excellent" }

    function BuildAdversaryMenu(client, unit)

        for _, skill in ipairs(SKILL_LEVELS) do
            local skill_menu = CLIENTMENU:NewEntry(client, skill, spawn_menu)

            for aircraftName, templateName in pairs(TEMPLATE.AIR.ADVERSARY) do
                CLIENTMENU:NewEntry(
                    client,
                    aircraftName,
                    skill_menu,
                    AddSpawnAdversaryCommandToPlayer,
                    { unit, templateName, 50 , skill }
                )
            end
        end
    end

    BuildAdversaryMenu(client, unit)

    local gps_function = CLIENTMENU:NewEntry(client, "GPS", tools_menu, AddGPSCommandToPlayer, {unit})
end
