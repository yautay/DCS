local VazianiZone = ZONE:New("TARGET VAZIANI")

local RedAgentSet = SET_GROUP:New()

local RedBorderZoneSet = SET_ZONE:New()
RedBorderZoneSet:AddZone(borderRed)

local ConflictZoneSet = SET_ZONE:New()
-- ConflictZoneSet:AddZone(zoneConflict1)
-- ConflictZoneSet:AddZone(zoneConflict2)

local AtackZoneSet = SET_ZONE:New()
AtackZoneSet:AddZone(VazianiZone)

RedChief = CHIEF:New("red", RedAgentSet, "Comrade RedChief")
-- ZONES
RedChief:SetBorderZones(RedBorderZoneSet)
-- RedChief:AddConflictZone(ConflictZoneSet)
RedChief:SetAttackZones(AtackZoneSet)
-- STRATEGY
RedChief:SetStrategy(CHIEF.Strategy.DEFENSIVE)
-- RESOURCES
if (aw_mozdok) then
    RedChief:AddAirwing(AWMozdok)
    RedChief:AddAwacsZone(ZONE:New("RED AWACS"), 35000, 320, 225, 20)
    RedChief:AddCapZone(ZONE:New("RED CAP"), 30000, 350, 180, 20)
    RedChief:AddGciCapZone(ZONE:New("RED GCICAP"), 30000, 350, 180, 30)    
end

RedChief:SetTacticalOverviewOn()
RedChief:__Start(5)
