_SETTINGS:SetPlayerMenuOff()

local frequencies = frequencies()

-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- BLUE Aux. flights
Tanker_Shell =
    SPAWN:New("Tanker 70Y Shell"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(shell_11)
        shell_11:CommandSetCallsign(1, 0)
        shell_11:CommandSetFrequency(frequencies.freq_aar)
    end
):InitRepeatOnLanding()
Tanker_Texaco =
    SPAWN:New("Tanker 71Y Texaco"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(texaco_11)
        texaco_11:CommandSetCallsign(1, 0)
        texaco_11:CommandSetFrequency(frequencies.freq_aar)
    end
):InitRepeatOnLanding()
AWACS_Overlord =
    SPAWN:New("EW-AWACS-1"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(overlord_11)
        overlord_11:CommandSetCallsign(1, 0)
        overlord_11:CommandSetFrequency(frequencies.freq_awacs)
    end
):InitRepeatOnLanding()

-- F10 Map Markings
ZONE:New("TKR-1-1"):GetCoordinate(0):LineToAll(ZONE:New("TKR-1-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 2, true, "SHELL")
ZONE:New("TKR-2"):GetCoordinate(0):CircleToAll(7500, -1, {0, 0, 1}, 1, {0, 0, 1}, .3, 2, true, "TEXACO")
ZONE:New("AWACS-1"):GetCoordinate(0):CircleToAll(7500, -1, {0, 0, 1}, 1, {0, 0, 1}, .3, 2, true, "TEXACO")

-- SAMs
--BLUE_SAM_1 = SPAWN:New("BLUE-SAM-01"):InitLimit(20, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_SAM_SUKHUMI = SPAWN:New("Sukhumi-SAM"):InitLimit(13, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_MANTIS = MANTIS:New("BLUE_MANTIS", "BLUE-SAM", "EW-AWACS", nil, coalition.side.BLUE, false):Start()

-- ###########################################################
-- ###                      BLUE CV                        ###
-- ###########################################################

-- F10 Map Markings

ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)
ZONE_POLYGON:New("CV-1-Area", GROUP:FindByName("helper_cv_stennis")):DrawZone(-1, {0, 0, 1}, 1, {0, 0, 1}, 0.4, 2)

-- S-3B Recovery Tanker
tanker = RECOVERYTANKER:New("USS Theodore Roosevelt", "USS Theodore Roosevelt AAR")
tanker:SetTakeoffHot()
tanker:SetRadio(frequencies.freq_aar)
tanker:SetModex(511)
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:SetTACAN(1, "Y", "TKR")
tanker:__Start(1)

-- E-2D AWACS
awacs = RECOVERYTANKER:New("USS Theodore Roosevelt", "USS Theodore Roosevelt AWACS")
awacs:SetAWACS()
awacs:SetRadio(frequencies.freq_awacs)
awacs:SetAltitude(20000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(15, 15)
awacs:SetModex(611)
awacs:__Start(1)

-- Rescue Helo
rescuehelo = RESCUEHELO:New("USS Theodore Roosevelt", "USS Theodore Roosevelt SAR")
rescuehelo:SetModex(42)
rescuehelo:__Start(1)

-- AIRBOSS object.
AirbossStennis = AIRBOSS:New("USS Theodore Roosevelt")
AirbossStennis:SetTACAN(74, "X", "STN"):SetICLS(1, "STN")
AirbossStennis:SetMarshalRadio(freq_marshal, "AM"):SetLSORadio(freq_lso, "AM")

local window1=AirbossStennis:AddRecoveryWindow( "6:00", "20:00", 1, nil, true, 25)
--local window2=AirbossStennis:AddRecoveryWindow("15:00", "16:00", 2,  nil, true, 23)
local window3=AirbossStennis:AddRecoveryWindow("20:00", "23:59", 3,  nil, true, 21)

AirbossStennis:SetMenuSingleCarrier()
AirbossStennis:SetMenuRecovery(30, 25, false)
AirbossStennis:SetDespawnOnEngineShutdown()
AirbossStennis:Load()
AirbossStennis:SetAutoSave()
AirbossStennis:SetTrapSheet()
AirbossStennis:Start()
AirbossStennis:SetHandleAIOFF()

--- Function called when recovery tanker is started.
function tanker:OnAfterStart(From, Event, To)
    AirbossStennis:SetRecoveryTanker(tanker)
    AirbossStennis:SetRadioRelayLSO(self:GetUnitName())
end

--- Function called when AWACS is started.
function awacs:OnAfterStart(From, Event, To)
    AirbossStennis:SetAWACS(awacs)
end

--- Function called when rescue helo is started.
function rescuehelo:OnAfterStart(From, Event, To)
    AirbossStennis:SetRadioRelayMarshal(self:GetUnitName())
end

--- Function called when a player gets graded by the LSO.
function AirbossStennis:OnAfterLSOGrade(From, Event, To, playerData, grade)
    local PlayerData = playerData --Ops.Airboss#AIRBOSS.PlayerData
    local Grade = grade --Ops.Airboss#AIRBOSS.LSOgrade

    ----------------------------------------
    --- Interface your Discord bot here! ---
    ----------------------------------------

    local score = tonumber(Grade.points)
    local gradeLso = tostring(Grade.grade)
    local timeInGrove = tonumber(Grade.Tgroove)
    local wire = tonumber(Grade.wire)
    local name = tostring(PlayerData.name)

    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("Player %s scored %.1f", name, score))
end

-- ###########################################################
-- ###                   RED COALITION                     ###
-- ###########################################################

-- CONVOYS ---------------------------------------------------
ZONE:New("intel-01"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "06:00")
ZONE:New("intel-02"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "07:00")
ZONE:New("intel-03"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "08:30")
ZONE:New("intel-04"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "10:00")

-- ZONES -----------------------------------------------------
ZONE_Al_Assad = ZONE_POLYGON:New("A2A_Al_Assad_ZONE", GROUP:FindByName("Al-Assad-ZONE")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)
CAP_Al_Assad = ZONE_POLYGON:New("Al-Assad-ZONE-CAP", GROUP:FindByName("Al-Assad-ZONE-CAP")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)

ZONE_Zor = ZONE_POLYGON:New("A2A_Zor_ZONE", GROUP:FindByName("red_bvr_zone")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)


-- EWRS ------------------------------------------------------
RED_EW_Assad = SPAWN:New("RED-EW-1-Al-Assad"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
RED_AWACS_Zor = SPAWN:New("RED-AWACS-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )


-- SAMS ------------------------------------------------------
--Krasnodar_SAM = SPAWN:New("Krasnodar-SAM"):InitLimit(14, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Krasnodar_MANTIS = MANTIS:New("Krasnodar-MANTIS", "Krasnodar-SAM", "Krasnodar-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Krasnodar"):GetCoordinate(0):CircleToAll(40000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Mineralnye_SHORAD = SPAWN:New("Mineralnye-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Mineralnye_MANTIS = MANTIS:New("Mineralnye-MANTIS", "Mineralnye-SHORAD", "RED1-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Mineralnye"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Nalchik_SHORAD = SPAWN:New("Nalchik-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Nalchik_MANTIS = MANTIS:New("Nalchik-MANTIS", "Nalchik-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Nalchik"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Beslan_SHORAD = SPAWN:New("Beslan-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Beslan_MANTIS = MANTIS:New("Beslan-IADS", "Beslan-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Beslan"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Mozdok_SHORAD = SPAWN:New("Mozdok-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Mozdok_MANTIS = MANTIS:New("Mozdok-IADS", "Mozdok-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Mozdok"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Sochi_SHORAD = SPAWN:New("Sochi-MERAD"):InitLimit(16, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Sochi_MANTIS = MANTIS:New("Sochi-MANTIS", "Sochi-SHORAD", "RED3-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Sochi"):GetCoordinate(0):CircleToAll(50000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)

-- FLIGHTS ---------------------------------------------------
--BIGBIRD_1 = SPAWN:New("A2A-Target-1"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_2 = SPAWN:New("A2A-Target-2"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_3 = SPAWN:New("A2A-Target-3"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_4 = SPAWN:New("A2A-Target-4"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_5 = SPAWN:New("A2A-Target-5"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_6 = SPAWN:New("A2A-Target-6"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )

--DSIPATCHERS -----------------------------------------------
A2A_Al_Assad = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED-EW-1"}):FilterStart(), 150000))
A2A_Al_Assad:SetBorderZone(ZONE_Al_Assad)
A2A_Al_Assad:SetDefaultTakeoffFromRunway()
A2A_Al_Assad:SetDefaultLandingAtRunway()
A2A_Al_Assad:SetDefaultFuelThreshold(0.20)
A2A_Al_Assad:SetDefaultDamageThreshold(0.90)
A2A_Al_Assad:SetEngageRadius(UTILS.NMToMeters(40))
A2A_Al_Assad:SetDisengageRadius(UTILS.NMToMeters(40))

A2A_Al_Assad:SetSquadron("Reds_29", AIRBASE.Syria.Bassel_Al_Assad, "Bassel_Al_Assad_MiG_29")
A2A_Al_Assad:SetSquadronCap("Reds_29", CAP_Al_Assad, UTILS.FeetToMeters(10000), UTILS.FeetToMeters(30000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Al_Assad:SetSquadronCapInterval("Reds_29", 1, 1800, 2000, 1 )
A2A_Al_Assad:SetSquadronGrouping("Reds_29", 2)
A2A_Al_Assad:SetSquadronOverhead("Reds_29", 1)

--DSIPATCHERS -----------------------------------------------
A2A_Zor = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED-AWACS"}):FilterStart(), 250000))
A2A_Zor:SetBorderZone(ZONE_Zor)
A2A_Zor:SetDefaultTakeoffFromRunway()
A2A_Zor:SetDefaultLandingAtRunway()
A2A_Zor:SetDefaultFuelThreshold(0.20)
A2A_Zor:SetDefaultDamageThreshold(0.90)
A2A_Zor:SetEngageRadius(UTILS.NMToMeters(100))
A2A_Zor:SetDisengageRadius(UTILS.NMToMeters(150))

A2A_Zor:SetSquadron("Reds_31", AIRBASE.Syria.Tabqa, "mig_31")
A2A_Zor:SetSquadronCap("Reds_31", ZONE_Zor, UTILS.FeetToMeters(30000), UTILS.FeetToMeters(50000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(1200), "BARO" )
A2A_Zor:SetSquadronCapInterval("Reds_31", 1, 1800, 2000, 1 )
A2A_Zor:SetSquadronGrouping("Reds_31", 1)
A2A_Zor:SetSquadronOverhead("Reds_31", 1)

A2A_Zor:SetSquadron("Reds_23", AIRBASE.Syria.Tabqa, "mig_23")
A2A_Zor:SetSquadronCap("Reds_23", ZONE_Zor, UTILS.FeetToMeters(25000), UTILS.FeetToMeters(40000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Zor:SetSquadronCapInterval("Reds_23", 1, 1800, 2000, 1 )
A2A_Zor:SetSquadronGrouping("Reds_23", 2)
A2A_Zor:SetSquadronOverhead("Reds_23", 1)

A2A_Zor:SetSquadron("Reds_21", AIRBASE.Syria.Tabqa, "mig_21")
A2A_Zor:SetSquadronCap("Reds_21", ZONE_Zor, UTILS.FeetToMeters(25000), UTILS.FeetToMeters(40000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Zor:SetSquadronCapInterval("Reds_21", 1, 1800, 2000, 1 )
A2A_Zor:SetSquadronGrouping("Reds_21", 2)
A2A_Zor:SetSquadronOverhead("Reds_21", 1)