local rat = true

_SETTINGS:SetPlayerMenuOff()

-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- BLUE Aux. flights
Tanker_Shell =
    SPAWN:New("Tanker Shell"):InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
    function(shell_11)
        shell_11:EnRouteTaskTanker()
        shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1, 1)
        shell_11:CommandSetFrequency(FREQUENCIES.AAR.common[1])
        local beacon = shell_11:GetBeacon()
        beacon:ActivateTACAN(TACAN.shell[1], TACAN.shell[2], TACAN.shell[3], true)
    end
):InitRepeatOnLanding()
Tanker_Texaco =
    SPAWN:New("Tanker Texaco"):InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
    function(texaco_11)
        texaco_11:EnRouteTaskTanker()
        texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1, 1)
        texaco_11:CommandSetFrequency(FREQUENCIES.AAR.common[1])
        local beacon = texaco_11:GetBeacon()
        beacon:ActivateTACAN(TACAN.texaco[1], TACAN.texaco[2], TACAN.texaco[3], true)
    end
):InitRepeatOnLanding()
AWACS_Darkstar =
    SPAWN:New("AWACS Darkstar"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(darkstar_11)
        darkstar_11:EnRouteTaskAWACS()
        darkstar_11:CommandSetCallsign(CALLSIGN.AWACS.Darkstar, 1, 1)
        darkstar_11:CommandSetFrequency(FREQUENCIES.AWACS.darkstar[1])
    end
):InitRepeatOnLanding()
AWACS_Overlord =
    SPAWN:New("AWACS Overlord"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(overlord_11)
        overlord_11:EnRouteTaskAWACS()
        overlord_11:CommandSetCallsign(CALLSIGN.AWACS.Overlord, 1, 1)
        overlord_11:CommandSetFrequency(FREQUENCIES.AWACS.overlord[1])
    end
):InitRepeatOnLanding()

ZONEWarbirds = ZONE_POLYGON:New("Warbirds Sector", GROUP:FindByName("ZONE-Piston")):DrawZone(2, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.6, 0, true)
-- ###########################################################
-- ###                      CHROME                         ###
-- ###########################################################
AtisRamatDavid=ATIS:New(AIRBASE.Syria.Ramat_David, FREQUENCIES.GROUND.atis_ramat_david[1])
AtisRamatDavid:SetRadioRelayUnitName("ELINT-Beirut")
AtisRamatDavid:SetTACAN(84)
AtisRamatDavid:SetVOR(113.70)
AtisRamatDavid:SetTowerFrequencies({251.05, 118.6})
AtisRamatDavid:AddILS(110.10, "33")
AtisRamatDavid:AddNDBinner(368.00)
AtisRamatDavid:SetSRS("C:\\DCS-SimpleRadio-Standalone", "female", "en-US")
AtisRamatDavid:SetMapMarks()
AtisRamatDavid:Start()

if (rat) then
    local rat_y40=RAT:New("RAT Y40"):ExcludedAirports({AIRBASE.Syria.Minakh, AIRBASE.Syria.Aleppo, AIRBASE.Syria.Jirah, AIRBASE.Syria.Eyn_Shemer}):SetCoalition("sameonly"):Spawn(3)
    local rat_a400=RAT:New("RAT A400"):ExcludedAirports({AIRBASE.Syria.Minakh, AIRBASE.Syria.Aleppo, AIRBASE.Syria.Jirah, AIRBASE.Syria.Eyn_Shemer}):SetCoalition("sameonly"):SetTerminalType(AIRBASE.TerminalType.OpenBig):Spawn(2)
    local rat_c130=RAT:New("RAT C130"):ExcludedAirports({AIRBASE.Syria.Minakh, AIRBASE.Syria.Aleppo, AIRBASE.Syria.Jirah, AIRBASE.Syria.Eyn_Shemer}):SetCoalition("sameonly"):SetTerminalType(AIRBASE.TerminalType.OpenBig):Spawn(3)
end
