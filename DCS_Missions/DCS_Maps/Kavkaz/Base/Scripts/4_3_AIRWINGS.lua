AIRWING_SENAKI = AIRWING:New("WH Senaki", "Senaki Air Wing")
AIRWING_SENAKI:SetAirbase(AIRBASE:FindByName(BASES.Senaki_Kolkhi))

AIRWING_SENAKI:SetReportOff()
AIRWING_SENAKI:SetMarker(false)

AIRWING_SENAKI:AddSquadron(Squadron_Yaks)
AIRWING_SENAKI:NewPayload("Yaks", 99, { AUFTRAG.Type.ORBIT }, 100)

ZoneORBIT = ZONE:FindByName("ORBIT")

AIRWING_SENAKI:AddPatrolPointCAP(ZoneCAP, 12000, UTILS.KnotsToAltKIAS(300, 25000), 205, 30)
AIRWING_SENAKI:SetTakeoffType("cold")
AIRWING_SENAKI:Start()

yak_orbit_mission = AUFTRAG:NewORBIT(ZoneORBIT:GetCoordinate(), 3000, 100, 270, 2)
yak_orbit_mission:SetRequiredAssets(1)

AIRWING_SENAKI:AddMission(yak_orbit_mission)

