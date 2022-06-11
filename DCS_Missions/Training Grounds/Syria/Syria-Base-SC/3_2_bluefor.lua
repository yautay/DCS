-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

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


-- ###########################################################
-- ###                      CHROME                         ###
-- ###########################################################
if (atis) then
    AtisRamatDavid = ATIS:New(AIRBASE.Syria.Ramat_David, FREQUENCIES.GROUND.atis_ramat_david[1])
    AtisRamatDavid:SetRadioRelayUnitName("ELINT-Beirut")
    AtisRamatDavid:SetTACAN(84)
    AtisRamatDavid:SetVOR(113.70)
    AtisRamatDavid:SetTowerFrequencies({251.05, 118.6})
    AtisRamatDavid:AddILS(110.10, "33")
    AtisRamatDavid:AddNDBinner(368.00)
    AtisRamatDavid:SetSRS("C:\\DCS-SimpleRadio-Standalone", "female", "en-US")
    AtisRamatDavid:SetMapMarks()
    AtisRamatDavid:Start()
end