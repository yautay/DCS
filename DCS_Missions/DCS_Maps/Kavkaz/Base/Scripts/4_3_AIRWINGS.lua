ZoneTankers = ZONE:FindByName("Zone AAR")
ZoneAwacs = ZONE:FindByName("Zone AWACS")

AIRWING_KUTAISI = AIRWING:New("WH Kutaisi ", "Kutaisi Air Wing")
AIRWING_KUTAISI:SetAirbase(AIRBASE:FindByName(BASES.Kutaisi))
AIRWING_KUTAISI:SetReportOff()
AIRWING_KUTAISI:SetMarker(false)
AIRWING_KUTAISI:AddSquadron(Squadron_AWACS)
AIRWING_KUTAISI:AddSquadron(Squadron_AAR)
AIRWING_KUTAISI:AddPatrolPointTANKER(ZoneTankers, 25000, UTILS.KnotsToAltKIAS(270, 25000), 270, 30, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
AIRWING_KUTAISI:AddPatrolPointAWACS(ZoneAwacs, 20000, UTILS.KnotsToAltKIAS(270, 20000), 225, 10)
AIRWING_KUTAISI:SetNumberTankerBoom(1)
AIRWING_KUTAISI:SetNumberAWACS(1)
AIRWING_KUTAISI:SetTakeoffType("hot")
AIRWING_KUTAISI:Start()

AIRWING_SENAKI = AIRWING:New("WH Senaki", "Senaki Air Wing")
AIRWING_SENAKI:SetAirbase(AIRBASE:FindByName(BASES.Senaki_Kolkhi))
AIRWING_SENAKI:SetReportOff()
AIRWING_SENAKI:SetMarker(false)
AIRWING_SENAKI:AddSquadron(Squadron_Yaks)
AIRWING_SENAKI:AddSquadron(Squadron_Bell)
AIRWING_SENAKI:AddSquadron(Squadron_Mosie)
AIRWING_SENAKI:NewPayload("Yaks", 99, { AUFTRAG.Type.ORBIT }, 100)
AIRWING_SENAKI:NewPayload("Bell", 99, { AUFTRAG.Type.ORBIT }, 100)
AIRWING_SENAKI:NewPayload("Mosquito", 99, { AUFTRAG.Type.ORBIT }, 100)

ZoneORBIT = ZONE:FindByName("ORBIT")
ZoneORBIT2 = ZONE:FindByName("ORBIT-2")

AIRWING_SENAKI:SetTakeoffType("cold")
AIRWING_SENAKI:Start()

a3_orbit_mission = AUFTRAG:NewORBIT(ZoneORBIT:GetCoordinate(), 3000, 150, 270, 2)
a3_orbit_mission:SetRequiredAssets(1)
a1_orbit_mission = AUFTRAG:NewORBIT(ZoneORBIT2:GetCoordinate(), 1500, 300, 090, 5)
a1_orbit_mission:SetRequiredAssets(1)
a2_orbit_mission = AUFTRAG:NewORBIT(ZoneORBIT:GetCoordinate(), 1500, 300, 0, 5)
a2_orbit_mission:SetRequiredAssets(1)
AIRWING_SENAKI:AddMission(a3_orbit_mission)
AIRWING_SENAKI:AddMission(a1_orbit_mission)
AIRWING_SENAKI:AddMission(a2_orbit_mission)

ZoneRedCAP = ZONE:FindByName("Red CAP")

AIRWING_RED = AIRWING:New("WH Red ", "Red Air Wing")
AIRWING_RED:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Sukhumi_Babushara))
AIRWING_RED:SetReportOff()
AIRWING_RED:NewPayload("M19", 99, { AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 70)
AIRWING_RED:NewPayload("P51", 99, { AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 70)
AIRWING_RED:SetMarker(true)


MenuPVE = MENU_COALITION:New(coalition.side.BLUE, "PVE Trainer")
MenuPVE_WW2 = MENU_COALITION:New(coalition.side.BLUE, "Warbirds", MenuPVE)
MenuPVE_Cold = MENU_COALITION:New(coalition.side.BLUE, "Cold War", MenuPVE)

local function StartCAP(squadron)
    AIRWING_RED:AddSquadron(squadron)
    AIRWING_RED:SetNumberCAP(1)
    AIRWING_RED:AddPatrolPointCAP(ZoneRedCAP, 6000, UTILS.KnotsToAltKIAS(400, 6000), 225, 5)
    AIRWING_RED:SetCAPFormation(ENUMS.Formation.FixedWing.EchelonLeft.Close)
    AIRWING_RED:Start()
    command_cap_cold_war:Remove()
    command_cap_ww2:Remove()
end

local function StopCAP()
    AIRWING_RED:Stop()
    command_cap_ww2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Start", MenuPVE_WW2, StartCAP, RedP51)
    command_cap_cold_war = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Start", MenuPVE_Cold, StartCAP, RedM19)
end

command_cap_ww2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Start", MenuPVE_WW2, StartCAP, RedP51)
command_cap_cold_war = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Start", MenuPVE_Cold, StartCAP, RedM19)
command_cap_stop = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Stop", MenuPVE, StopCAP)


