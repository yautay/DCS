Squadron_A50 = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AWACS, 1, "RED_AWACS")
Squadron_A50:SetSkill(AI.Skill.EXCELLENT)
Squadron_A50:SetFuelLowThreshold(0.3)
Squadron_A50:SetFuelLowRefuel(true)
Squadron_A50:SetTurnoverTime(10, 20)
Squadron_A50:AddMissionCapability({ AUFTRAG.Type.ORBIT, AUFTRAG.Type.AWACS }, 100)

Squadron_A50_ESCORT = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.MIG21_PAIR, 6, "RED_AWACS_ESCORT") -- taking a template with 2 planes here, will result in a group of 2 escorts which can fly in formation escorting the AWACS.
Squadron_A50_ESCORT:AddMissionCapability({ AUFTRAG.Type.ESCORT }, 100)
Squadron_A50_ESCORT:AddMissionCapability({ AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 50)
Squadron_A50_ESCORT:SetFuelLowRefuel(false)
Squadron_A50_ESCORT:SetFuelLowThreshold(0.3)
Squadron_A50_ESCORT:SetMissionRange(100)

Squadron_RED_CAP = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_CAP, 8, "RED_CAP")
Squadron_RED_CAP:SetSkill(AI.Skill.EXCELLENT)
Squadron_RED_CAP:SetFuelLowThreshold(0.3)
Squadron_RED_CAP:SetFuelLowRefuel(true)
Squadron_RED_CAP:SetGrouping(2)
Squadron_RED_CAP:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 100)
Squadron_RED_CAP:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 50)
Squadron_RED_CAP:SetMissionRange(200)

Squadron_RED_INTERCEPT = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, 3, "RED_INTERCEPT")
Squadron_RED_INTERCEPT:SetSkill(AI.Skill.EXCELLENT)
Squadron_RED_INTERCEPT:SetFuelLowThreshold(0.3)
Squadron_RED_INTERCEPT:SetFuelLowRefuel(true)
Squadron_RED_INTERCEPT:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 50)
Squadron_RED_INTERCEPT:AddMissionCapability({ AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 100)
Squadron_RED_INTERCEPT:SetMissionRange(200)

Squadron_RED_AAR = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AAR, 2, "RED_AAR")
Squadron_RED_AAR:SetSkill(AI.Skill.EXCELLENT)
Squadron_RED_AAR:SetFuelLowThreshold(0.3)
Squadron_RED_AAR:SetFuelLowRefuel(false)
Squadron_RED_AAR:AddMissionCapability({ AUFTRAG.Type.ORBIT, AUFTRAG.Type.TANKER } 100)

VVS=AIRWING:New("WH Olena", "AW Olena") --Ops.AirWing#AIRWING
VVS:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Olenya))

VVS:AddSquadron(Squadron_A50)
VVS:AddSquadron(Squadron_RED_CAP)
VVS:AddSquadron(Squadron_RED_INTERCEPT)
VVS:AddSquadron(Squadron_RED_AAR)

VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 100)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, -1, { AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 60)

VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.MIG21_PAIR, -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 30)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.MIG21_PAIR, -1, { AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 20)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.MIG21_PAIR, -1, { AUFTRAG.Type.ESCORT }, 50)

VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_CAP, -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 50)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_CAP, -1, { AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 100)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_CAP, -1, { AUFTRAG.Type.ESCORT }, 60)

VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_AAR, -1, { AUFTRAG.Type.ORBIT, AUFTRAG.Type.TANKER }, 100)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_AWACS, -1, { AUFTRAG.Type.ORBIT, AUFTRAG.Type.AWACS }, 100)

---
-- CHIEF OF STAFF
---
ZoneRedTankers = ZONE:FindByName("Zone RED AAR")
ZoneRedAwacs = ZONE:FindByName("Zone RED AWACS")
ZoneRedCAP = ZONE:FindByName("Zone RED CAP")
-- Zone defining the border of the blue territory.
local ZoneRedBorder=ZONE_POLYGON:NewFromGroupName("Red Accept Zone")

-- RedBlue agents.
local RedAgents=SET_GROUP:New():FilterCoalitions("Red"):FilterStart()

-- Define CHIEF.
local RedChief=CHIEF:New(coalition.side.RED, RedAgents)
RedChief:SetVerbosity(3)
RedChief:SetClusterAnalysis(true, true, true)
RedChief:SetTacticalOverviewOn()

RedChief:AddBorderZone(ZoneRedBorder)
RedChief:AddAirwing(VVS)

RedChief:SetStrategy(CHIEF.Strategy.DEFENSIVE)

RedChief:AddCapZone(ZoneRedCAP, 30000, UTILS.KnotsToAltKIAS(400, 33000), 320, 20)
RedChief:AddGciCapZone(ZoneRedCAP, 30000, UTILS.KnotsToAltKIAS(400, 33000), 320, 20)
RedChief:AddAwacsZone(ZoneRedAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 345, 20)
RedChief:AddTankerZone(ZoneRedTankers, 30000, UTILS.KnotsToAltKIAS(363, 33000), 345, 20, Unit.RefuelingSystem.PROBE_AND_DROGUE)

RedChief:SetLimitMission(1, AUFTRAG.Type.INTERCEPT)
RedChief:SetLimitMission(1, AUFTRAG.Type.CAP)
RedChief:SetLimitMission(1, AUFTRAG.Type.GCICAP)
RedChief:SetLimitMission(1, AUFTRAG.Type.TANKER)
RedChief:SetLimitMission(1, AUFTRAG.Type.AWACS)

RedChief:__Start(1)

-- VVS:AddPatrolPointTANKER(ZoneRedTankers, 30000, UTILS.KnotsToAltKIAS(363, 33000), 345, 20, Unit.RefuelingSystem.PROBE_AND_DROGUE)
-- VVS:AddPatrolPointAWACS(ZoneRedAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 345, 20)
-- VVS:SetNumberTankerProbe(1)
-- VVS:SetNumberAWACS(1)