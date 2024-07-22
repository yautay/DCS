AW_BLUE = AIRWING:New("WH Kutaisi", "Blue Air Wing")
AW_BLUE:SetMarker(false)
AW_BLUE:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
AW_BLUE:Start()

AW_BLUE:AddSquadron(BLUE_AWACS)
AW_BLUE:NewPayload("WIZARD", -1, { AUFTRAG.Type.ORBIT }, 100)

AICSAR_BLUE=AICSAR:New("AI CSAR",coalition.side.BLUE,"Downed Pilot","CSAR",AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi,ZONE:New("MASH")))

AW_RED = AIRWING:New("WH Sochi", "Red Air Wing")
AW_RED:SetMarker(false)
AW_RED:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Sochi_Adler))
AW_RED:__Start(2)



--AW_RED:AddSquadron(RED_F1DDA)
--AW_RED:NewPayload("F1DDA ANTIRUNWAY", 99, {AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.CAP, AUFTRAG.Type.ESCORT}, 100)
--AW_RED:NewPayload("F1DDA AIR", 99, {AUFTRAG.Type.BOMBRUNWAY}, 100)


--AW_RED:Start()


--targetSenaki=TARGET:New(AIRBASE:FindByName(AIRBASE.Caucasus.Senaki_Kolkhi))

--alert5=AUFTRAG:NewALERT5(AUFTRAG.Type.NewBOMBRUNWAY)
--alert5:SetRequiredAssets(10)
--AW_RED:AddMission(alert5)

--missionRunway=AUFTRAG:NewBOMBRUNWAY(targetSenaki, 5000)
--missionRunway:SetPriority(90)
--missionRunway:SetRequiredAssets(2)
--missionRunway:SetMissionWaypointCoord(ZONE:New("RED IP"))
--missionRunway:SetMissionAltitude(5000)
--missionRunway:SetMissionEgressCoord(ZoneSouth:GetCoordinate(), 15000)
--missionRunway:SetTime("8:05")
--missionRunway:SetPushTime("9:00")
--missionRunway:AssignSquadrons({RED_F1DDA})
--missionRunway:SetRequiredEscorts(0, 1)




--AW_RED:AddMission(missionRunway)

