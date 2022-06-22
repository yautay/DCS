if (rat) then
    local rat_y40=RAT:New("RAT Y40"):ExcludedAirports({AIRBASE.Syria.Minakh, AIRBASE.Syria.Aleppo, AIRBASE.Syria.Jirah, AIRBASE.Syria.Eyn_Shemer}):SetCoalition("sameonly"):Spawn(3)
    local rat_a400=RAT:New("RAT A400"):ExcludedAirports({AIRBASE.Syria.Minakh, AIRBASE.Syria.Aleppo, AIRBASE.Syria.Jirah, AIRBASE.Syria.Eyn_Shemer}):SetCoalition("sameonly"):SetTerminalType(AIRBASE.TerminalType.OpenBig):Spawn(2)
    local rat_c130=RAT:New("RAT C130"):ExcludedAirports({AIRBASE.Syria.Minakh, AIRBASE.Syria.Aleppo, AIRBASE.Syria.Jirah, AIRBASE.Syria.Eyn_Shemer}):SetCoalition("sameonly"):SetTerminalType(AIRBASE.TerminalType.OpenBig):Spawn(3)
end
