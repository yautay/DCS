Squadron_A50 = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AWACS, 2, "RED_AWACS")
Squadron_A50:SetSkill(AI.Skill.EXCELLENT)
Squadron_A50:SetFuelLowThreshold(0.4)
Squadron_A50:SetFuelLowRefuel(true)
Squadron_A50:SetTurnoverTime(10, 20)
Squadron_A50:SetTakeoffHot()
Squadron_A50:AddMissionCapability({ AUFTRAG.Type.AWACS, AUFTRAG.Type.ALERT5 }, 100)

Squadron_RED_AAR = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AAR, 3, "RED_AAR")
Squadron_RED_AAR:SetSkill(AI.Skill.EXCELLENT)
Squadron_RED_AAR:SetFuelLowThreshold(0.4)
Squadron_RED_AAR:SetFuelLowRefuel(false)
Squadron_RED_AAR:SetTurnoverTime(10, 20)
Squadron_RED_AAR:SetTakeoffHot()
Squadron_RED_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER, AUFTRAG.Type.ALERT5 }, 100)

Squadron_A50_ESCORT = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_ESCORT, 6, "RED_AWACS_ESCORT")
Squadron_A50_ESCORT:SetSkill(AI.Skill.EXCELLENT)
Squadron_A50_ESCORT:AddMissionCapability({ AUFTRAG.Type.ESCORT, AUFTRAG.Type.ALERT5 }, 100)
Squadron_A50_ESCORT:SetFuelLowThreshold(0.4)
Squadron_A50_ESCORT:SetFuelLowRefuel(true)
Squadron_A50_ESCORT:SetTakeoffHot()
Squadron_A50_ESCORT:SetMissionRange(100)

Squadron_RED_CAP = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_CAP, 12, "RED_CAP")
Squadron_RED_CAP:SetSkill(AI.Skill.EXCELLENT)
Squadron_RED_CAP:SetFuelLowThreshold(0.4)
Squadron_RED_CAP:SetFuelLowRefuel(true)
Squadron_RED_CAP:SetGrouping(2)
Squadron_RED_CAP:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ALERT5 }, 100)
Squadron_RED_CAP:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 50)
Squadron_RED_CAP:SetTakeoffHot()
Squadron_RED_CAP:SetMissionRange(120)

Squadron_RED_INTERCEPT = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, 3, "RED_INTERCEPT")
Squadron_RED_INTERCEPT:SetSkill(AI.Skill.EXCELLENT)
Squadron_RED_INTERCEPT:SetFuelLowThreshold(0.4)
Squadron_RED_INTERCEPT:SetFuelLowRefuel(true)
Squadron_RED_INTERCEPT:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ALERT5 }, 50)
Squadron_RED_INTERCEPT:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 100)
Squadron_RED_INTERCEPT:SetTakeoffHot()
Squadron_RED_INTERCEPT:SetMissionRange(120)


VVS=AIRWING:New("WH Olena", "AW Olena") --Ops.AirWing#AIRWING
VVS:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Olenya))

VVS:AddSquadron(Squadron_A50)
VVS:AddSquadron(Squadron_RED_AAR)
VVS:AddSquadron(Squadron_A50_ESCORT)
VVS:AddSquadron(Squadron_RED_CAP)
VVS:AddSquadron(Squadron_RED_INTERCEPT)

VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_AAR, -1, { AUFTRAG.Type.TANKER, AUFTRAG.Type.ALERT5 }, 100)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_AWACS, -1, { AUFTRAG.Type.AWACS, AUFTRAG.Type.ALERT5 }, 100)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ALERT5 }, 100)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_ESCORT, -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ESCORT, AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP }, 80)
VVS:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_CAP, -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ESCORT, AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP }, 100)

-- RedBlue agents.
RedAgents=SET_GROUP:New():FilterCoalitions("Red"):FilterStart()

-- Define CHIEF.
RedChief=CHIEF:New(coalition.side.RED, RedAgents)
RedChief:SetVerbosity(3)
RedChief:SetClusterAnalysis(true, true, true)
RedChief:SetTacticalOverviewOn()

RedChief:AddBorderZone(ZoneRedAccept)
RedChief:AddRejectZone(ZoneRedReject)

RedChief:AddAirwing(VVS)

RedChief:SetStrategy(CHIEF.Strategy.DEFENSIVE)

RedChief:AddCapZone(ZoneRedCAP, 30000, UTILS.KnotsToAltKIAS(400, 33000), 320, 30)
RedChief:AddGciCapZone(ZoneRedCAP, 30000, UTILS.KnotsToAltKIAS(400, 33000), 320, 30)
RedChief:AddAwacsZone(ZoneRedAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 345, 30)
RedChief:AddTankerZone(ZoneRedTankers, 30000, UTILS.KnotsToAltKIAS(363, 33000), 345, 30, Unit.RefuelingSystem.PROBE_AND_DROGUE)

RedChief:SetLimitMission(2, AUFTRAG.Type.INTERCEPT)
RedChief:SetLimitMission(2, AUFTRAG.Type.CAP)
RedChief:SetLimitMission(1, AUFTRAG.Type.TANKER)
RedChief:SetLimitMission(1, AUFTRAG.Type.AWACS)

RedChief:SetResponseOnTarget(1, 2, 6, TARGET.Category.AIRCRAFT, AUFTRAG.Type.INTERCEPT)
RedChief:SetResponseOnTarget(1, 2, 0, nil, AUFTRAG.Type.CAP, nil, CHIEF.DEFCON.GREEN)

local InterceptAlert5=AUFTRAG:NewALERT5(AUFTRAG.Type.INTERCEPT)
InterceptAlert5:SetRequiredAssets(3)

-- Add the mission to the airwing.
-- NOTE: We could also add the mission to the CHIEF. But then we would not know which airwing he choses if he has more than one. Here it does not matter.
VVS:AddMission(InterceptAlert5)

--Set out 2 Groups of Ground-Controlled CAP fighters.
local CAPAlert5s=AUFTRAG:NewALERT5(AUFTRAG.Type.CAP)
CAPAlert5s:SetRequiredAssets(12)

-- Add mission to airwing.
VVS:AddMission(CAPAlert5s)

RedChief:__Start(1)

function RedChief:OnAfterNewContact(From, Event, To, Contact)

  -- Gather info of contact.
  local ContactName=RedChief:GetContactName(Contact)
  local ContactType=RedChief:GetContactTypeName(Contact)
  local ContactThreat=RedChief:GetContactThreatlevel(Contact)

  -- Text message.
  local text=string.format("Detected NEW contact: Name=%s, Type=%s, Threat Level=%d", ContactName, ContactType, ContactThreat)
  MESSAGE:New(text, 120):ToAll()
  -- Show message in log file.
  env.info(text)

end

--- Function called each time the Chief sends an asset group on a mission.
function RedChief:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
  local opsgroup=OpsGroup --Ops.OpsGroup#OPSGROUP
  local mission=Mission   --Ops.Auftrag#AUFTRAG

  -- Info message to log file which group is launched on which mission.
  local text=string.format("Group %s is on mission %s [%s]", opsgroup:GetName(), mission:GetName(), mission:GetType())
  MESSAGE:New(text, 120):ToAll()
  env.info(text)

end
-- VVS:AddPatrolPointTANKER(ZoneRedTankers, 30000, UTILS.KnotsToAltKIAS(363, 33000), 345, 20, Unit.RefuelingSystem.PROBE_AND_DROGUE)
-- VVS:AddPatrolPointAWACS(ZoneRedAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 345, 20)
-- VVS:SetNumberTankerProbe(1)
-- VVS:SetNumberAWACS(1)