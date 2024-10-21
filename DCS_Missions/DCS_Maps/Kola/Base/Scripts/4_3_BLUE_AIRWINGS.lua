AIRWING_EFRO = AIRWING:New("EFRO WH", "EFRO Air Wing")
AIRWING_EFRO:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Rovaniemi))

AIRWING_EFRO:SetReportOff()
AIRWING_EFRO:SetMarker(true)

AIRWING_EFRO:AddSquadron(Squadron_TANKER_kc135)
AIRWING_EFRO:AddSquadron(Squadron_TANKER_kc135mprs)
AIRWING_EFRO:AddSquadron(Squadron_TANKER_kc10)
AIRWING_EFRO:AddSquadron(Squadron_AWACS_e3a)
AIRWING_EFRO:AddSquadron(Squadron_MRA_Viggen_F13)
AIRWING_EFRO:AddSquadron(Squadron_MRA_F1_SQ142)

AIRWING_EFRO:NewPayload(TEMPLATE.viggen_aa_light, 10, { AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 70)
AIRWING_EFRO:NewPayload(TEMPLATE.viggen_aa_heavy, 100, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 50)
AIRWING_EFRO:NewPayload(TEMPLATE.viggen_ag_bombs, 20, { AUFTRAG.Type.BAI, AUFTRAG.Type.BOMBING, AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 80)
AIRWING_EFRO:NewPayload(TEMPLATE.viggen_ag_cluster, 10, { AUFTRAG.Type.SEAD }, 80)
AIRWING_EFRO:NewPayload(TEMPLATE.viggen_ag_runway, 10, { AUFTRAG.Type.BOMBRUNWAY }, 60)

AIRWING_EFRO:NewPayload(TEMPLATE.f1_aa_light, 10, { AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 80)
AIRWING_EFRO:NewPayload(TEMPLATE.f1_aa_heavy, 100, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ALERT5 }, 80)
AIRWING_EFRO:NewPayload(TEMPLATE.f1_ag_strike, 20, { AUFTRAG.Type.BAI, AUFTRAG.Type.BOMBING, AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 65)
AIRWING_EFRO:NewPayload(TEMPLATE.f1_ag_cas, 10, { AUFTRAG.Type.CAS, AUFTRAG.Type.STRIKE }, 65)
AIRWING_EFRO:NewPayload(TEMPLATE.f1_ag_runway, 10, { AUFTRAG.Type.BOMBRUNWAY }, 100)

ZoneTankers = ZONE:FindByName("Zone AAR EFRO")
ZoneAwacs = ZONE:FindByName("Zone AWACS EFRO")
ZoneCAP = ZONE:FindByName("Zone CAP EFRO")

AIRWING_EFRO:AddPatrolPointTANKER(ZoneTankers, 25000, UTILS.KnotsToAltKIAS(363, 27000), 335, 30, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
AIRWING_EFRO:AddPatrolPointTANKER(ZoneTankers, 20000, UTILS.KnotsToAltKIAS(363, 25000), 135, 30, Unit.RefuelingSystem.PROBE_AND_DROGUE)
AIRWING_EFRO:AddPatrolPointAWACS(ZoneAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 0, 40)
AIRWING_EFRO:AddPatrolPointCAP(ZoneCAP, 12000, UTILS.KnotsToAltKIAS(300, 25000), 205, 30)

AIRWING_EFRO:SetNumberTankerBoom(1)
AIRWING_EFRO:SetNumberTankerProbe(1)
AIRWING_EFRO:SetNumberAWACS(1)
AIRWING_EFRO:SetNumberRescuehelo(1)
AIRWING_EFRO:SetNumberCAP(1)

AIRWING_EFRO:AddPatrolPointCAP(ZoneCAP, 25000, UTILS.KnotsToAltKIAS(300, 25000), 205, 30)
AIRWING_EFRO:SetCAPFormation(ENUMS.Formation.FixedWing.EchelonLeft.Close)

AIRWING_EFRO:Start()

--- Function called each time a flight group goes on a mission. Can be used to fine tune.
--function AIRWING_EFRO:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
    --local flightgroup = Flightgroup --Ops.FlightGroup#FLIGHTGROUP
    --local mission = Mission --Ops.Auftrag#AUFTRAG
    --local group = flightgroup:GetGroup()
    --local unit = group:GetUnits()[1]
    --local beacon = unit:GetBeacon()
    --
    --if mission == AUFTRAG.Type.TANKER then
    --    if mission.refuelSystem == Unit.RefuelingSystem.BOOM_AND_RECEPTACLE then
    --        beacon:ActivateTACAN(VAR_KOLA.TACAN.texaco_one[1], VAR_KOLA.TACAN.texaco_one[2], VAR_KOLA.TACAN.texaco_one[3], VAR_KOLA.TACAN.texaco_one[5])
    --        group:CommandSetFrequency(VAR_KOLA.FREQUENCIES.AAR.texaco_one[1], VAR_KOLA.FREQUENCIES.AAR.texaco_one[3])
    --        group:CommandSetCallsign(CALLSIGN.Tanker.Texaco)
    --    elseif mission.refuelSystem == Unit.RefuelingSystem.PROBE_AND_DROGUE then
    --        beacon:ActivateTACAN(VAR_KOLA.TACAN.shell_one[1], VAR_KOLA.TACAN.shell_one[2], VAR_KOLA.TACAN.shell_one[3], VAR_KOLA.TACAN.shell_one[5])
    --        group:CommandSetFrequency(VAR_KOLA.FREQUENCIES.AAR.shell_one[1], VAR_KOLA.FREQUENCIES.AAR.shell_one[3])
    --        group:CommandSetCallsign(CALLSIGN.Tanker.Shell)
    --    end
    --elseif mission == AUFTRAG.Type.AWACS then
    --    group:CommandSetFrequency(VAR_KOLA.FREQUENCIES.AWACS.darkstar[1], VAR_KOLA.FREQUENCIES.AWACS.darkstar[3])
    --    group:CommandSetCallsign(CALLSIGN.AWACS.Darkstar)
    --    group:CommandEPLRS()
    --end
--end

--- Display mission status on screen.
local function MissionStatus()
    local text = "Missions:"
    for _, _mission in pairs(AIRWING_EFRO.missionqueue) do
        local m = _mission --Ops.Auftrag#AUFTRAG
        text = text .. string.format("\n- %s %s %s*%d/%d [%d %%]  (%s*%d/%d)",
                m:GetName(), m:GetState():upper(), m:GetTargetName(), m:CountMissionTargets(), m:GetTargetInitialNumber(), m:GetTargetDamage(), m:GetType(), m:CountOpsGroups(), m:GetNumberOfRequiredAssets())
    end
    -- Payloads
    text = text .. "\n\nPayloads:"
    for _, aname in pairs(AUFTRAG.Type) do
        local n = AIRWING_EFRO:CountPayloadsInStock({ aname })
        if n > 0 then
            text = text .. string.format("\n%s %d", aname, n)
        end
    end
    -- Info message to all.
    MESSAGE:New(text, 25):ToAll()
end

-- Display primary and secondary mission status every 60 seconds.
--TIMER:New(MissionStatus):Start(5, 30)

