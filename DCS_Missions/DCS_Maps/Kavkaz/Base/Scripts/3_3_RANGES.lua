RangeObject_IRON = RANGE:New("Kobuleti")
ZoneRange = ZONE_POLYGON:NewFromGroupName("RANGE")
RangeObject_IRON:SetRangeZone(ZoneRange)

BombTargetsGroups = { "G_TARGET_BMB" }
StrafeTargetsGroupMs = { "G_TARGET_STR" }

RangeObject_IRON:AddBombingTargetGroup(GROUP:FindByName(BombTargetsGroups[1]), 30, false)

local boxlength = UTILS.NMToMeters(3)
local boxwidth = UTILS.NMToMeters(1)
local heading = 96
local foulline = 150

--Base:AddStrafePit(targetnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
RangeObject_IRON:AddStrafePitGroup(GROUP:FindByName(StrafeTargetsGroupMs[1]), boxlength, boxwidth, heading, false, 20, foulline)

-- Start range.
RangeObject_IRON:SetDefaultPlayerSmokeBomb(true)
RangeObject_IRON:SetTargetSheet(SHEET_PATH, "Range-")
RangeObject_IRON:SetAutosaveOn()
RangeObject_IRON:SetMessageTimeDuration(5)
RangeObject_IRON:SetFunkManOn(10042, "127.0.0.1")
RangeObject_IRON:Start()

marker_bomb = MARKER:New( GROUP:FindByName("G_TARGET_BMB"):GetCoordinate(), "Iron Bombs Target"):ToCoalition( coalition.side.BLUE )
marker_strafe = MARKER:New( GROUP:FindByName("G_TARGET_STR"):GetCoordinate(), "Strafe Pit - ingress from East!!"):ToCoalition( coalition.side.BLUE )


ZoneRangeSAM = ZONE:New("RANGE-SAM")

Fox_SAM=FOX:New()
Zone_SA3LZ = ZONE:New("SA3 LZ")
Zone_SA2LZ = ZONE:New("SA2 LZ")
Zone_SA6LZ = ZONE:New("SA6 LZ")
Fox_SAM:AddSafeZone(ZoneRangeSA3)
Fox_SAM:AddLaunchZone(Zone_SA3LZ)
Fox_SAM:AddLaunchZone(Zone_SA2LZ)
Fox_SAM:AddLaunchZone(Zone_SA6LZ)
Fox_SAM:Start()

marker_SA3 = MARKER:New( Zone_SA3LZ:GetCoordinate(), "SA-3 Range | S-125 Low Blow | P19 Flat Face"):ToCoalition( coalition.side.BLUE )
marker_SA2 = MARKER:New( Zone_SA2LZ:GetCoordinate(), "SA-2 Range | S-75 Fan Song | P19 Flat Face"):ToCoalition( coalition.side.BLUE )
marker_SA6 = MARKER:New( Zone_SA6LZ:GetCoordinate(), "SA-6 Range | Straight Flush"):ToCoalition( coalition.side.BLUE )

function spawnsa2()
    Spawn_SAMSA2 = SPAWN:New("Red SAM SA-2"):InitLimit( 15, 15 ):Spawn()
end
function spawnsa3()
    Spawn_SAMSA3 = SPAWN:New("Red SAM SA-3"):InitLimit( 13, 13 ):Spawn()
end
function spawnsa6()
    Spawn_SAMSA6 = SPAWN:New("Red SAM SA-6"):InitLimit( 11, 11 ):Spawn()
end

MenuSpawnSA2 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn SAM SA-2", MenuSpawn, spawnsa2 )
MenuSpawnSA3 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn SAM SA-3", MenuSpawn, spawnsa3 )
MenuSpawnSA6 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn SAM SA-6", MenuSpawn, spawnsa6 )