
ZONE_RED_AWACS = ZONE:New("RED_AWACS")
ZONE_RED_ENGAGE = ZONE_POLYGON:NewFromGroupName("KILLBOX")

AW_Assad = AIRWING:New("Static Warehouse-4-1", "Assad Air Wing")

AW_Assad:SetMarker(false)
AW_Assad:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Bassel_Al_Assad))
AW_Assad:SetRespawnAfterDestroyed(600)
AW_Assad:__Start(2)

AW_Assad_INT = SQUADRON:New("Red Mig23 Intercept", 8, "Red Mig23 Intercept")
AW_Assad_INT:SetGrouping(1)
AW_Assad_INT:SetSkill(AI.Skill.EXCELLENT)
AW_Assad_INT:SetTakeoffType("Hot")
AW_Assad_INT:AddMissionCapability({ AUFTRAG.Type.CAP, AUFTRAG.Type.INTERCEPT }, 100)
AW_Assad_INT:AddMissionCapability({AUFTRAG.Type.ALERT5})
AW_Assad_INT:SetFuelLowRefuel(false)
AW_Assad_INT:SetFuelLowThreshold(0.4)
AW_Assad:AddSquadron(AW_Assad_INT)

AW_Assad:NewPayload("Red Mig23 Intercept", 2, { AUFTRAG.Type.INTERCEPT }, 100)
--AW_Assad:NewPayload("Red Mig23 Intercept", 2, { AUFTRAG.Type.CAP }, 30)

AW_Assad_CAP = SQUADRON:New("Red Su33 BVR", 4, "Red Su33 BVR")
AW_Assad_CAP:SetGrouping(2)
AW_Assad_CAP:SetSkill(AI.Skill.EXCELLENT)
AW_Assad_CAP:SetTakeoffType("Hot")
AW_Assad_CAP:AddMissionCapability({ AUFTRAG.Type.CAP, AUFTRAG.Type.ESCORT, AUFTRAG.Type.PATROLZONE }, 100)
AW_Assad_CAP:SetFuelLowRefuel(true)
AW_Assad_CAP:SetFuelLowThreshold(0.4)
AW_Assad:AddSquadron(AW_Assad_CAP)

AW_Assad:NewPayload("Red Su33 BVR", 4, { AUFTRAG.Type.CAP, AUFTRAG.Type.ESCORT, AUFTRAG.Type.PATROLZONE }, 100)

AW_Assad_AAR = SQUADRON:New("Red AAR", 3, "Red AAR Squadron")
AW_Assad_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_Assad_AAR:SetSkill(AI.Skill.EXCELLENT)
AW_Assad_AAR:SetTakeoffType("Hot")
AW_Assad_AAR:SetFuelLowRefuel(false)
AW_Assad_AAR:SetFuelLowThreshold(0.3)
AW_Assad_AAR:SetTurnoverTime(30, 5)
AW_Assad:AddSquadron(AW_Assad_AAR)
AW_Assad:NewPayload("Red AAR", -1, { AUFTRAG.Type.TANKER }, 100)

AW_Assad_AWACS = SQUADRON:New("Red AWACS", 2, "Red AWACS Squadron")
AW_Assad_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_Assad_AWACS:SetTakeoffType("Hot")
AW_Assad_AWACS:SetFuelLowRefuel(true)
AW_Assad_AWACS:SetFuelLowThreshold(0.4)
AW_Assad_AWACS:SetTurnoverTime(30, 5)
AW_Assad_AWACS:SetRadio(251)
AW_Assad:AddSquadron(AW_Assad_AWACS)
AW_Assad:NewPayload("Red AWACS", -1, { AUFTRAG.Type.ORBIT }, 100)

function AW_Assad:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)  --We'll use this to expand functionality later.  Not strictly necessary now, but helpful.
  local flightgroup = Flightgroup -- Ops.FlightGroup#FLIGHTGROUP
  local mission = Mission -- Ops.Auftrag#AUFTRAG

  -- Info message.
  local text=string.format("AIRWING Group %s on mission %s [%s]", flightgroup:GetName(), mission:GetName(), mission:GetType())
  env.info(text)

end
