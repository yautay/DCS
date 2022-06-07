
_SETTINGS:SetPlayerMenuOff()

-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- BLUE Aux. flights
Tanker_Shell_E =
    SPAWN:New("Tanker Shell E"):InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
        function(shell_11)
            shell_11:EnRouteTaskTanker()
            shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1, 1)
            shell_11:CommandSetFrequency(FREQUENCIES.AAR.common[1])
            local beacon = shell_11:GetBeacon()
            beacon:ActivateTACAN(TACAN.shell[1], TACAN.shell[2], TACAN.shell[3], true)
        end
    ):InitRepeatOnLanding()
Tanker_Texaco_E =
    SPAWN:New("Tanker Texaco E"):InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
        function(texaco_11)
            texaco_11:EnRouteTaskTanker()
            texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1, 1)
            texaco_11:CommandSetFrequency(FREQUENCIES.AAR.common[1])
            local beacon = texaco_11:GetBeacon()
            beacon:ActivateTACAN(TACAN.texaco_e[1], TACAN.texaco_e[2], TACAN.texaco_e[3], true)
        end
    ):InitRepeatOnLanding()
Tanker_Texaco_W =
    SPAWN:New("Tanker Texaco W"):InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
        function(texaco_11)
            texaco_11:EnRouteTaskTanker()
            texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 2, 1)
            texaco_11:CommandSetFrequency(FREQUENCIES.AAR.common[1])
            local beacon = texaco_11:GetBeacon()
            beacon:ActivateTACAN(TACAN.texaco_w[1], TACAN.texaco_w[2], TACAN.texaco_w[3], true)
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

ELINT_South = SPAWN:New("Elint West"):Spawn()

CvCap_1 = SPAWN:New("VFA-113"):InitLimit(2, 0):SpawnScheduled(1, .1):InitRepeatOnLanding()

-- ###########################################################
-- ###                      CHROME                         ###
-- ###########################################################
atisVaziani = ATIS:New(AIRBASE.Caucasus.Vaziani, FREQUENCIES.GROUND.atis_vaziani[1])
atisVaziani:SetRadioRelayUnitName("AWACS Darkstar")
atisVaziani:SetTACAN(22)
atisVaziani:SetTowerFrequencies(FREQUENCIES.GROUND.vaziani[1])
atisVaziani:AddILS(108.75, "13")
atisVaziani:SetSRS("C:\\DCS-SimpleRadio-Standalone", "female", "en-US")
atisVaziani:SetMapMarks()
atisVaziani:Start()
