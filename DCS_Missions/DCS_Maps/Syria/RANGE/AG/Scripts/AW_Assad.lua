
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
AW_Assad:NewPayload("Red Mig23 Intercept", 2, { AUFTRAG.Type.CAP }, 30)

AW_Assad_CAP = SQUADRON:New("Red Su33 BVR", 4, "Red Su33 BVR")
AW_Assad_CAP:SetGrouping(2)
AW_Assad_CAP:SetSkill(AI.Skill.EXCELLENT)
AW_Assad_CAP:SetTakeoffType("Hot")
AW_Assad_CAP:AddMissionCapability({ AUFTRAG.Type.CAP, AUFTRAG.Type.ESCORT, AUFTRAG.Type.PATROLZONE }, 100)
AW_Assad_CAP:SetFuelLowRefuel(true)
AW_Assad_CAP:SetFuelLowThreshold(0.4)
AW_Assad:AddSquadron(AW_Assad_CAP)

AW_Assad:NewPayload("Red Su33 BVR", 2, { AUFTRAG.Type.CAP, AUFTRAG.Type.ESCORT, AUFTRAG.Type.PATROLZONE }, 100)

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

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Assad_AWACS_route = {ZONE_RED_AWACS:GetCoordinate(), 30000, 450, 0, 40}

AWACS_IVAN = AWACS:New("RED MAGIC", AW_Assad, "red", AIRBASE.Syria.Bassel_Al_Assad, "RED_AWACS", "KILLBOX", "RED_PATROL_1", 251, radio.modulation.AM)
AWACS_IVAN:SetBullsEyeAlias("SASHA")
AWACS_IVAN:SetAwacsDetails(CALLSIGN.AWACS.Magic, 1, Assad_AWACS_route[2], Assad_AWACS_route[3], Assad_AWACS_route[4], Assad_AWACS_route[5])
AWACS_IVAN:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_IVAN:SetModernEraAggressive()

AWACS_IVAN.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_IVAN.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_IVAN.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_IVAN.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_IVAN.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_IVAN.maxassigndistance = 150 -- Don't assign targets further out than this, in NM.
AWACS_IVAN.NoMissileCalls = true -- suppress missile callouts
AWACS_IVAN.PlayerCapAssigment = true -- no task assignment for players
AWACS_IVAN.invisible = false -- set AWACS to be invisible to hostiles
AWACS_IVAN.immortal = false -- set AWACS to be immortal
AWACS_IVAN.GoogleTTSPadding = 1 -- seconds
AWACS_IVAN.WindowsTTSPadding = 2.5 -- seconds

AWACS_IVAN:SuppressScreenMessages(true)
AWACS_IVAN:__Start(2)
