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

