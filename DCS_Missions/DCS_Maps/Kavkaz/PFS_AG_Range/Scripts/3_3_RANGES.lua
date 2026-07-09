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
RangeObject_IRON:SetTargetSheet(SHEET_PATH, "\\Range-")
RangeObject_IRON:SetAutosaveOn()
RangeObject_IRON:SetMessageTimeDuration(5)
RangeObject_IRON:SetFunkManOn(10042, "127.0.0.1")

RangeObject_IRON:Start()
marker_bomb = MARKER:New( GROUP:FindByName("G_TARGET_BMB"):GetCoordinate(), "Iron Bombs Target"):ToCoalition( coalition.side.BLUE )
marker_strafe = MARKER:New( GROUP:FindByName("G_TARGET_STR"):GetCoordinate(), "Strafe Pit - ingress from East!!"):ToCoalition( coalition.side.BLUE )
