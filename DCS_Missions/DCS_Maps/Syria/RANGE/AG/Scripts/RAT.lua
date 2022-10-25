a320 = RAT:New("RAT A320")
a737 = RAT:New("RAT B737")
a330 = RAT:New("RAT A330")
c2a = RAT:New("RAT C2A")

a330:SetTerminalType(AIRBASE.TerminalType.OpenBig)
a737:SetTerminalType(AIRBASE.TerminalType.OpenBig)
a320:SetTerminalType(AIRBASE.TerminalType.OpenBig)

a320:SetDeparture({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
a737:SetDeparture({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
a330:SetDeparture({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})

a320:Commute()
a737:Commute()
a330:Commute()
c2a:Commute()



c2a:SetDeparture({AIRBASE.Syria.Paphos})
c2a:SetDestination({"CVN-75"})

rat_manager = RATMANAGER:New(7)
rat_manager:Add(a320, 2)
rat_manager:Add(a737, 1)
rat_manager:Add(a330, 1)
rat_manager:Add(c2a, 1)

rat_manager:Start()

