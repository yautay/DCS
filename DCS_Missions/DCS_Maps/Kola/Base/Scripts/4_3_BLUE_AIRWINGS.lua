AIRWING_EFRO = AIRWING:New("EFRO WH", "EFRO Air Wing")
AIRWING_EFRO:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Rovaniemi))

AIRWING_EFRO:SetReportOff()
AIRWING_EFRO:SetMarker(false)
AIRWING_EFRO:SetRespawnAfterDestroyed(900)
--
AIRWING_EFRO:AddSquadron(Squadron_TANKER_kc135)
AIRWING_EFRO:AddSquadron(Squadron_TANKER_kc135mprs)
AIRWING_EFRO:AddSquadron(Squadron_AWACS_e3a)
AIRWING_EFRO:AddSquadron(Squadron_ESCORTS_F15)

AIRWING_EFRO:NewPayload(TEMPLATE.AIR.AWACS.DARKSTAR, -1, { AUFTRAG.Type.ORBIT }, 100)
AIRWING_EFRO:NewPayload(TEMPLATE.AIR.AI.F15C_ESCORTS, -1, { AUFTRAG.Type.ESCORT }, 100)

-- AIRWING_EFRO:AddSquadron(Squadron_MRA_Viggen_F13)
-- AIRWING_EFRO:AddSquadron(Squadron_MRA_F1_SQ142)
--
-- AIRWING_EFRO:NewPayload(TEMPLATE.viggen_aa_light, 10, { AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 70)
-- AIRWING_EFRO:NewPayload(TEMPLATE.viggen_aa_heavy, 100, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 50)
-- AIRWING_EFRO:NewPayload(TEMPLATE.viggen_ag_bombs, 20, { AUFTRAG.Type.BAI, AUFTRAG.Type.BOMBING, AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 80)
-- AIRWING_EFRO:NewPayload(TEMPLATE.viggen_ag_cluster, 10, { AUFTRAG.Type.SEAD }, 80)
-- AIRWING_EFRO:NewPayload(TEMPLATE.viggen_ag_runway, 10, { AUFTRAG.Type.BOMBRUNWAY }, 60)
--
-- AIRWING_EFRO:NewPayload(TEMPLATE.f1_aa_light, 10, { AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 80)
-- AIRWING_EFRO:NewPayload(TEMPLATE.f1_aa_heavy, 100, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 80)
-- AIRWING_EFRO:NewPayload(TEMPLATE.f1_ag_strike, 20, { AUFTRAG.Type.BAI, AUFTRAG.Type.BOMBING, AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 65)
-- AIRWING_EFRO:NewPayload(TEMPLATE.f1_ag_cas, 10, { AUFTRAG.Type.CAS, AUFTRAG.Type.STRIKE }, 65)
-- AIRWING_EFRO:NewPayload(TEMPLATE.f1_ag_runway, 10, { AUFTRAG.Type.BOMBRUNWAY }, 100)
--
ZoneTankers = ZONE:FindByName("Zone AAR EFRO")
ZoneAwacs = ZONE:FindByName("Zone AWACS EFRO")
ZoneCAP = ZONE:FindByName("Zone CAP EFRO")
ZoneFEZ = ZONE:FindByName("Zone FEZ EFRO")
--
AIRWING_EFRO:AddPatrolPointTANKER(ZoneTankers, 30000, UTILS.KnotsToAltKIAS(363, 30000), 335, 50, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
AIRWING_EFRO:AddPatrolPointTANKER(ZoneTankers, 28000, UTILS.KnotsToAltKIAS(363, 28000), 335, 50, Unit.RefuelingSystem.PROBE_AND_DROGUE)
--AIRWING_EFRO:AddPatrolPointAWACS(ZoneAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 0, 40)
--AIRWING_EFRO:AddPatrolPointCAP(ZoneCAP, 12000, UTILS.KnotsToAltKIAS(300, 25000), 205, 30)
--
AIRWING_EFRO:SetNumberTankerBoom(1)
AIRWING_EFRO:SetNumberTankerProbe(1)
--AIRWING_EFRO:SetNumberAWACS(1)
-- AIRWING_EFRO:SetNumberRescuehelo(1)
-- AIRWING_EFRO:SetNumberCAP(1)
--
-- AIRWING_EFRO:AddPatrolPointCAP(ZoneCAP, 25000, UTILS.KnotsToAltKIAS(300, 25000), 205, 30)
-- AIRWING_EFRO:SetCAPFormation(ENUMS.Formation.FixedWing.EchelonLeft.Close)
--
AIRWING_EFRO:Start()

AWACS_DARKSTAR = AWACS:New("AWACS DARKSTAR", AIRWING_EFRO, "blue", AIRBASE.Kola.Rovaniemi, "Zone AWACS EFRO", ZoneFEZ, "Zone CAP EFRO", VAR_KOLA.FREQUENCIES.AWACS.darkstar[1], VAR_KOLA.FREQUENCIES.AWACS.darkstar[2])
-- set one escort group; this example has two units in the template group, so they can fly a nice formation.
AWACS_DARKSTAR:SetEscort(1, ENUMS.Formation.FixedWing.FingerFour.Group, { x = -500, y = 50, z = 500 }, 45)
-- Callsign will be "Focus". We'll be a Angels 30, doing 300 knots, orbit leg to 88deg with a length of 25nm.
AWACS_DARKSTAR:SetAwacsDetails(CALLSIGN.AWACS.DARKSTAR, 1, 32, 300, 335, 50)
-- Set up SRS on port 5010 - change the below to your path and port
AWACS_DARKSTAR:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
-- Add a "red" border we don't want to cross, set up in the mission editor with a late activated helo named "Red Border#ZONE_POLYGON"
AWACS_DARKSTAR:SetRejectionZone(ZONE:FindByName("ZONE RED"))
-- Our CAP flight will have the callsign "Ford", we want 4 AI planes, Time-On-Station is four hours, doing 300 kn IAS.
--AWACS_DARKSTAR:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 4, 4, 300)
-- We're modern (default), e.g. we have EPLRS and get more fill-in information on detections
AWACS_DARKSTAR:SetModernEra()

AWACS_DARKSTAR.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_DARKSTAR.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_DARKSTAR.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_DARKSTAR.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_DARKSTAR.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_DARKSTAR.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AWACS_DARKSTAR.debug = false -- set to true to produce more log output.
AWACS_DARKSTAR.NoMissileCalls = false -- suppress missile callouts
AWACS_DARKSTAR.PlayerCapAssignment = true -- no intercept task assignments for players
AWACS_DARKSTAR.invisible = true -- set AWACS to be invisible to hostiles
AWACS_DARKSTAR.immortal = true -- set AWACS to be immortal
AWACS_DARKSTAR.PikesSpecialSwitch = true -- if set to true, AWACS will omit the "doing xy knots" on the station assignement callout
AWACS_DARKSTAR.IncludeHelicopters = false -- if set to true, Helicopter pilots will also get the AWACS Menu and options

-- And start
AWACS_DARKSTAR:__Start(5)




-- --- Function called each time a flight group goes on a mission. Can be used to fine tune.
function AIRWING_EFRO:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
    local flightgroup = Flightgroup --Ops.FlightGroup#FLIGHTGROUP
    local mission = Mission --Ops.Auftrag#AUFTRAG
    local group = flightgroup:GetGroup()
    local unit = group:GetUnits()[1]
    local beacon = unit:GetBeacon()
    if mission == AUFTRAG.Type.TANKER then
        if mission.refuelSystem == Unit.RefuelingSystem.BOOM_AND_RECEPTACLE then
            beacon:ActivateTACAN(VAR_KOLA.TACAN.texaco_one[1], VAR_KOLA.TACAN.texaco_one[2], VAR_KOLA.TACAN.texaco_one[3], VAR_KOLA.TACAN.texaco_one[5])
            group:CommandSetFrequency(VAR_KOLA.FREQUENCIES.AAR.texaco_one[1], VAR_KOLA.FREQUENCIES.AAR.texaco_one[3])
            group:CommandSetCallsign(CALLSIGN.Tanker.Texaco)
        elseif mission.refuelSystem == Unit.RefuelingSystem.PROBE_AND_DROGUE then
            beacon:ActivateTACAN(VAR_KOLA.TACAN.shell_one[1], VAR_KOLA.TACAN.shell_one[2], VAR_KOLA.TACAN.shell_one[3], VAR_KOLA.TACAN.shell_one[5])
            group:CommandSetFrequency(VAR_KOLA.FREQUENCIES.AAR.shell_one[1], VAR_KOLA.FREQUENCIES.AAR.shell_one[3])
            group:CommandSetCallsign(CALLSIGN.Tanker.Shell)
        end
    elseif mission == AUFTRAG.Type.AWACS then
        group:CommandSetFrequency(VAR_KOLA.FREQUENCIES.AWACS.darkstar[1], VAR_KOLA.FREQUENCIES.AWACS.darkstar[3])
        group:CommandSetCallsign(CALLSIGN.AWACS.Darkstar)
        group:CommandEPLRS()
    end
end


AIRWING_CVN = AIRWING:New("CVN-75", "CVN-75 Air Wing")
AIRWING_CVN:SetReportOff()
AIRWING_CVN:SetMarker(false)
AIRWING_CVN:AddSquadron(Squadron_RELAY_HELI_CVN)
AIRWING_CVN:NewPayload(TEMPLATE.AIR.AI.RELAY_HELI, -1, { AUFTRAG.Type.ORBIT, AUFTRAG.Type.PATROLZONE }, 100)

MISSION_CVN_MARSHALL_RELAY=AUFTRAG:NewPATROLZONE(ZoneCVN, 50, 500)
MISSION_CVN_MARSHALL_RELAY:SetRequiredAssets(1)
MISSION_CVN_MARSHALL_RELAY.name = "CVN Marshall Relay"
MISSION_CVN_LSO_RELAY=AUFTRAG:NewPATROLZONE(ZoneCVN, 50, 300)
MISSION_CVN_LSO_RELAY:SetRequiredAssets(1)
MISSION_CVN_LSO_RELAY.name = "CVN LSO Relay"

AIRWING_CVN:AddMission(MISSION_CVN_MARSHALL_RELAY)
AIRWING_CVN:AddMission(MISSION_CVN_LSO_RELAY)
AIRWING_CVN:Start()

AIRWING_LHA = AIRWING:New("LHA-1", "LHA-1 Air Wing")
AIRWING_LHA:SetReportOff()
AIRWING_LHA:SetMarker(false)
AIRWING_LHA:AddSquadron(Squadron_RELAY_HELI_LHA)
AIRWING_LHA:NewPayload(TEMPLATE.AIR.AI.RELAY_HELI, -1, { AUFTRAG.Type.ORBIT, AUFTRAG.Type.PATROLZONE }, 100)

AIRWING_LHA_MARSHALL_RELAY=AUFTRAG:NewPATROLZONE(ZoneLHA, 50, 500)
AIRWING_LHA_MARSHALL_RELAY:SetRequiredAssets(1)
AIRWING_LHA_MARSHALL_RELAY.name = "LHA Marshall Relay"
AIRWING_LHA_LSO_RELAY=AUFTRAG:NewPATROLZONE(ZoneLHA, 50, 300)
AIRWING_LHA_LSO_RELAY:SetRequiredAssets(1)
AIRWING_LHA_LSO_RELAY.name = "LHA LSO Relay"

AIRWING_LHA:AddMission(AIRWING_LHA_MARSHALL_RELAY)
AIRWING_LHA:AddMission(AIRWING_LHA_LSO_RELAY)
AIRWING_LHA:Start()

function AIRWING_CVN:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
    local mission = Mission --Ops.Auftrag#AUFTRAG
    local group = flightgroup:GetGroup()
    if not mission.name then
        BASE:W("OnAfterFlightOnMission: mission.name is nil")
        return
    end

    if mission.name == "CVN Marshall Relay" then
        cvn_75_airboss:SetRadioRelayMarshal(group)
    elseif mission.name == "CVN LSO Relay" then
        cvn_75_airboss:SetRadioRelayLSO(group)
    end
    end

function AIRWING_LHA:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
    local mission = Mission --Ops.Auftrag#AUFTRAG
    local group = flightgroup:GetGroup()
    if not mission.name then
        BASE:W("OnAfterFlightOnMission: mission.name is nil")
        return
    end

    if mission.name == "LHA Marshall Relay" then
        lha_1_airboss:SetRadioRelayMarshal(group)
    elseif mission.name == "LHA LSO Relay" then
        lha_1_airboss:SetRadioRelayLSO(group)
    end
    end