a320 = RAT:New("RAT A320")
b737 = RAT:New("RAT B737")
a330 = RAT:New("RAT A330")
c2a = RAT:New("RAT C2A")
a380 = RAT:New("RAT A380")

a320:SetAISkill("excellent")
b737:SetAISkill("excellent")
a330:SetAISkill("excellent")
c2a:SetAISkill("excellent")
a380:SetAISkill("excellent")

a320:ATC_Messages(false)
b737:ATC_Messages(false)
a330:ATC_Messages(false)
a380:ATC_Messages(false)

c2a:EnableATC(false)

a320:SetSpawnInterval(120)
b737:SetSpawnInterval(120)
a330:SetSpawnInterval(360)

a320:Invisible()
b737:Invisible()
a330:Invisible()
a380:Invisible()

a320:RadioOFF()
b737:RadioOFF()
a330:RadioOFF()
a380:RadioOFF()

a330:SetTerminalType(AIRBASE.TerminalType.OpenBig)
b737:SetTerminalType(AIRBASE.TerminalType.OpenBig)
a330:SetTerminalType(AIRBASE.TerminalType.OpenBig)

a380:SetTakeoff("air")

a320:SetDeparture({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
b737:SetDeparture({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
a330:SetDeparture({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
a380:SetDeparture({"RAT A 1", "RAT A 2"})
c2a:SetDeparture({AIRBASE.Syria.Paphos})

a320:SetDestination({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
b737:SetDestination({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
a330:SetDestination({AIRBASE.Syria.Aleppo, AIRBASE.Syria.Beirut_Rafic_Hariri, AIRBASE.Syria.Larnaca, AIRBASE.Syria.Paphos, AIRBASE.Syria.Damascus, AIRBASE.Syria.Rene_Mouawad})
a380:DestinationZone({"RAT B 1", "RAT B 2"})
c2a:SetDestination({"CVN-75"})

a320:ContinueJourney()
b737:ContinueJourney()
a330:ContinueJourney()
c2a:Commute()


a320:Livery({"Turkish Airlines", "WiZZ Budapest", "WiZZ"})
b737:Livery({"AM", "Air Algerie", "Jet2", "kulula"})
a330:Livery({"Aer Lingus", "klm", "Turkish Airlines", "Swiss"})
a380:Livery({"Singapore Airlines", "Lufthansa", "British Airways"})
--c2a:Livery({string})



rat_manager = RATMANAGER:New(7)
rat_manager:Add(a320, 2)
rat_manager:Add(b737, 2)
rat_manager:Add(a330, 1)
rat_manager:Add(a380, 1)
rat_manager:Add(c2a, 1)

rat_manager:Start()