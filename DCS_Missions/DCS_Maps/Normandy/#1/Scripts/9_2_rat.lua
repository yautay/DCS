rat_c2 = RAT:New(TEMPLATE.rat_c2_greyhound)
rat_c2:SetDeparture({AIRBASE.Kola.Bodo, "Banak"})
rat_c2:SetDestination({"CVN-75"})
rat_c2:Spawn(1)

rat_c5 = RAT:New(TEMPLATE.rat_c5_galaxy)
rat_c5:SetDeparture({AIRBASE.Kola.Bodo})
rat_c5:SetDestination({AIRBASE.Kola.Rovaniemi, "Banak"})
rat_c5:Spawn(1)

rat_bas1 = RAT:New(TEMPLATE.rat_uh_1)
rat_bas1:SetDeparture({AIRBASE.Kola.Rovaniemi})
rat_bas1:SetDestination({"FARP WARSAW"})
rat_bas1:Spawn(1)

rat_bas2 = RAT:New(TEMPLATE.rat_uh_60)
rat_bas2:SetDeparture({"FARP WARSAW"})
rat_bas2:SetDestination({AIRBASE.Kola.Rovaniemi})
rat_bas2:Spawn(1)