RedAgentSet = SET_GROUP:New()

RedBorderZoneSet = SET_ZONE:New()
RedBorderZoneSet:AddZone(borderRed)

ConflictZoneSet = SET_ZONE:New()
ConflictZoneSet:AddZone(zoneConflict1)
ConflictZoneSet:AddZone(zoneConflict2)

BASE:E(ConflictZoneSet)

AtackZoneSet = SET_ZONE:New()
AtackZoneSet:AddZone(zoneVaziani)

RedChief = CHIEF:New("red", RedAgentSet, "PUTIN")
-- ZONES
RedChief:SetBorderZones(RedBorderZoneSet)
-- RedChief:AddConflictZone(ConflictZoneSet)
RedChief:SetAttackZones(AtackZoneSet)
-- STRATEGY
RedChief:SetStrategy(CHIEF.Strategy.DEFENSIVE)
-- RESOURCES
if (aw_mozdok) then
    RedChief:AddAirwing(AWMozdok)
    RedChief:AddAwacsZone(ZONE:New("URAL"), 25000, 320, 225, 20)
    RedChief:AddCapZone(ZONE:New("MOSCOW"), 30000, 350, 180, 20)
    RedChief:AddGciCapZone(ZONE:New("GORKI"), 30000, 350, 180, 30)    
end

RedChief:SetTacticalOverviewOn()
RedChief:__Start(5)
