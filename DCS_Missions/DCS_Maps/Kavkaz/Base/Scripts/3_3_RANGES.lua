RangeObject_IRON = RANGE:New("Kobuleti")
ZoneRange = ZONE_POLYGON:NewFromGroupName("RANGE")
RangeObject_IRON:SetRangeZone(ZoneRange)

BombTargets = { "TARGET_BMB" }
StrafeTargets = { "TARGET_STR" }

RangeObject_IRON:AddBombingTargets(BombTargets, 20, false)

local boxlength = UTILS.NMToMeters(3)
local boxwidth = UTILS.NMToMeters(1)
local heading = 96
local foulline = 150

--Base:AddStrafePit(targetnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
RangeObject_IRON:AddStrafePit(StrafeTargets, boxlength, boxwidth, heading, false, 10, foulline)

-- Start range.
RangeObject_IRON:SetDefaultPlayerSmokeBomb(true)
RangeObject_IRON:SetTargetSheet(SHEET_PATH, "Range-")
RangeObject_IRON:SetAutosaveOn()
RangeObject_IRON:SetMessageTimeDuration(5)
RangeObject_IRON:SetFunkManOn(10042, "127.0.0.1")
RangeObject_IRON:Start()

marker_bomb = MARKER:New( STATIC:FindByName("TARGET_BMB"):GetCoordinate(), "Iron Bombs Target"):ToCoalition( coalition.side.BLUE )
marker_strafe = MARKER:New( STATIC:FindByName("TARGET_STR"):GetCoordinate(), "Strafe Pit - ingress from East!!"):ToCoalition( coalition.side.BLUE )


RangeObject_SA3 = RANGE:New("SA3")
ZoneRangeSA3 = ZONE:New("RANGE-SA3")
RangeObject_SA3:SetRangeZone(ZoneRangeSA3)
BombTargetsSA3 = { "SA3 SR", "SA3 TR1", "SA3 TR2" }
RangeObject_SA3:AddBombingTargets(BombTargetsSA3, 15, false)
RangeObject_SA3:SetDefaultPlayerSmokeBomb(false)
RangeObject_SA3:SetTargetSheet(SHEET_PATH, "Range-")
RangeObject_SA3:SetAutosaveOn()
RangeObject_SA3:SetMessageTimeDuration(3)
RangeObject_SA3:SetFunkManOn(10042, "127.0.0.1")
RangeObject_SA3:Start()

Fox_SA3=FOX:New()
Fox_SA3:AddSafeZone(ZoneRangeSA3)
Fox_SA3:AddLaunchZone(ZONE:New("SA-3 LZ"))
Fox_SA3:Start()

marker_SA3 = MARKER:New( ZoneRangeSA3:GetCoordinate(), "SA-3 Range | S-125 Low Blow | P19 Flat Face"):ToCoalition( coalition.side.BLUE )

RangeObject_SA2 = RANGE:New("SA2")
ZoneRangeSA2 = ZONE:New("RANGE-SA2")
RangeObject_SA2:SetRangeZone(ZoneRangeSA2)
BombTargetsSA2 = { "SA2 SR", "SA2 TR" }
RangeObject_SA2:AddBombingTargets(BombTargetsSA2, 15, false)
RangeObject_SA2:SetDefaultPlayerSmokeBomb(false)
RangeObject_SA2:SetTargetSheet(SHEET_PATH, "Range-")
RangeObject_SA2:SetAutosaveOn()
RangeObject_SA2:SetMessageTimeDuration(3)
RangeObject_SA2:SetFunkManOn(10042, "127.0.0.1")
RangeObject_SA2:Start()

Fox_SA2=FOX:New()
Fox_SA2:AddSafeZone(ZoneRangeSA2)
Fox_SA2:AddLaunchZone(ZONE:New("SA2 LZ"))
Fox_SA2:Start()

marker_SA2 = MARKER:New( ZoneRangeSA2:GetCoordinate(), "SA-2 Range | S-75 Fan Song | P19 Flat Face"):ToCoalition( coalition.side.BLUE )

RangeObject_SA6 = RANGE:New("SA6")
ZoneRangeSA6 = ZONE:New("RANGE-SA6")
RangeObject_SA2:SetRangeZone(ZoneRangeSA6)
BombTargetsSA6 = { "SA6 STR" }
RangeObject_SA6:AddBombingTargets(BombTargetsSA6, 15, false)
RangeObject_SA6:SetDefaultPlayerSmokeBomb(false)
RangeObject_SA6:SetTargetSheet(SHEET_PATH, "Range-")
RangeObject_SA6:SetAutosaveOn()
RangeObject_SA6:SetMessageTimeDuration(3)
RangeObject_SA6:SetFunkManOn(10042, "127.0.0.1")
RangeObject_SA6:Start()

Fox_SA6=FOX:New()
Fox_SA6:AddSafeZone(ZoneRangeSA2)
Fox_SA6:AddLaunchZone(ZONE:New("SA6 LZ"))
Fox_SA6:Start()

marker_SA2 = MARKER:New( ZoneRangeSA2:GetCoordinate(), "SA-6 Range | Straight Flush"):ToCoalition( coalition.side.BLUE )

