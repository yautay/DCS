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
BombTargetsSA3 = { UNIT.FindByName("Red SAM SA-3 TR1"), UNIT.FindByName("Red SAM SA-3 TR2"), UNIT.FindByName("Red SAM SA-3 SR") }
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


