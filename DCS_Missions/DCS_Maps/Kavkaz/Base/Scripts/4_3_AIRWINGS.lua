--AIRWING_KUTAISI = AIRWING:New("WH Kutaisi ", "Kutaisi Air Wing")
--AIRWING_KUTAISI:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
--AIRWING_KUTAISI:SetReportOff()
--AIRWING_KUTAISI:SetMarker(false)
--
--AIRWING_KUTAISI:AddSquadron(Squadron_WZ1)
--AIRWING_KUTAISI:AddSquadron(Squadron_TX1)
--AIRWING_KUTAISI:AddSquadron(Squadron_TX2)
--
--AIRWING_KUTAISI:AddPatrolPointTANKER(ZoneTEXACO1, 25000, UTILS.KnotsToAltKIAS(230, 25000), 30, 10, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
--AIRWING_KUTAISI:AddPatrolPointTANKER(ZoneTEXACO2, 25000, UTILS.KnotsToAltKIAS(230, 25000), 150, 10, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
--AIRWING_KUTAISI:AddPatrolPointAWACS(ZoneWIZARD1, 20000, UTILS.KnotsToAltKIAS(170, 20000), 45, 10)
--
--AIRWING_KUTAISI:SetNumberTankerBoom(2)
--AIRWING_KUTAISI:SetNumberAWACS(1)
--AIRWING_KUTAISI:SetTakeoffType("hot")
--AIRWING_KUTAISI:Start()

--AIRWING_SENAKI = AIRWING:New("WH Senaki", "Senaki Air Wing")
--AIRWING_SENAKI:SetAirbase(AIRBASE:FindByName(BASES.Senaki_Kolkhi))
--AIRWING_SENAKI:SetReportOff()
--AIRWING_SENAKI:SetMarker(false)
--
--AIRWING_SENAKI:SetTakeoffType("cold")
--AIRWING_SENAKI:Start()


--MenuPVE = MENU_COALITION:New(coalition.side.BLUE, "PVE Trainer")
--MenuPVE_WW2 = MENU_COALITION:New(coalition.side.BLUE, "Warbirds", MenuPVE)
--MenuPVE_Cold = MENU_COALITION:New(coalition.side.BLUE, "Cold War", MenuPVE)
