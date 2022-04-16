-- ###########################################################
-- ###                   RED COALITION                     ###
-- ###########################################################

-- CONVOYS ---------------------------------------------------
ZONE:New("intel-01"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "06:00")
ZONE:New("intel-02"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "07:00")
ZONE:New("intel-03"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "08:30")
ZONE:New("intel-04"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "10:00")

-- ZONES -----------------------------------------------------
ZONE_Al_Assad =
    ZONE_POLYGON:New("A2A_Al_Assad_ZONE", GROUP:FindByName("Al-Assad-ZONE")):DrawZone(
    -1,
    {1, 1, 0},
    1.0,
    {1, 1, 0},
    0.4,
    2
)
CAP_Al_Assad =
    ZONE_POLYGON:New("Al-Assad-ZONE-CAP", GROUP:FindByName("Al-Assad-ZONE-CAP")):DrawZone(
    -1,
    {0, 0, 0},
    1.0,
    {0, 0, 0},
    0.2,
    3
)

ZONE_Zor =
    ZONE_POLYGON:New("A2A_Zor_ZONE", GROUP:FindByName("red_bvr_zone")):DrawZone(-1, {1, 1, 0}, 1.0, {1, 1, 0}, 0.4, 2)

-- EWRS ------------------------------------------------------
RED_EW_Assad = SPAWN:New("RED-EW-1-Al-Assad"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25)
RED_AWACS_Zor = SPAWN:New("RED-AWACS-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25)

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
A2A_Al_Assad =
    AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED-EW-1"}):FilterStart(), 150000))
A2A_Al_Assad:SetBorderZone(ZONE_Al_Assad)
A2A_Al_Assad:SetDefaultTakeoffFromRunway()
A2A_Al_Assad:SetDefaultLandingAtRunway()
A2A_Al_Assad:SetDefaultFuelThreshold(0.20)
A2A_Al_Assad:SetDefaultDamageThreshold(0.90)
A2A_Al_Assad:SetEngageRadius(UTILS.NMToMeters(40))
A2A_Al_Assad:SetDisengageRadius(UTILS.NMToMeters(40))

--DSIPATCHERS -----------------------------------------------
A2A_Zor =
    AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED-AWACS"}):FilterStart(), 250000))
A2A_Zor:SetBorderZone(ZONE_Zor)
A2A_Zor:SetDefaultTakeoffFromRunway()
A2A_Zor:SetDefaultLandingAtRunway()
A2A_Zor:SetDefaultFuelThreshold(0.40)
A2A_Zor:SetDefaultDamageThreshold(0.90)
A2A_Zor:SetEngageRadius(UTILS.NMToMeters(100))
A2A_Zor:SetDisengageRadius(UTILS.NMToMeters(150))

function spawnCAP21()
    A2A_Zor:SetSquadron("Reds_21", AIRBASE.Syria.Tabqa, "mig_21")
    A2A_Zor:SetSquadronCap(
        "Reds_21",
        ZONE_Zor,
        UTILS.FeetToMeters(25000),
        UTILS.FeetToMeters(27000),
        UTILS.KnotsToKmph(200),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    A2A_Zor:SetSquadronCapInterval("Reds_21", 2, 1800, 2000, 1)
    A2A_Zor:SetSquadronGrouping("Reds_21", 2)
    A2A_Zor:SetSquadronOverhead("Reds_21", 1)
end

function spawnCAP31()
    A2A_Zor:SetSquadron("Reds_31", AIRBASE.Syria.Tabqa, "mig_31")
    A2A_Zor:SetSquadronCap(
        "Reds_31",
        ZONE_Zor,
        UTILS.FeetToMeters(40000),
        UTILS.FeetToMeters(42000),
        UTILS.KnotsToKmph(220),
        UTILS.KnotsToKmph(300),
        UTILS.KnotsToKmph(300),
        UTILS.KnotsToKmph(1200),
        "BARO"
    )
    A2A_Zor:SetSquadronCapInterval("Reds_31", 1, 1800, 2000, 1)
    A2A_Zor:SetSquadronGrouping("Reds_31", 1)
    A2A_Zor:SetSquadronOverhead("Reds_31", 1)
    MESSAGE:New("CAP MiG-31 SPAWNED!!!", 5):ToAll()
end
function spawnCAP23()
    A2A_Zor:SetSquadron("Reds_23", AIRBASE.Syria.Tabqa, "mig_23")
    A2A_Zor:SetSquadronCap(
        "Reds_23",
        ZONE_Zor,
        UTILS.FeetToMeters(25000),
        UTILS.FeetToMeters(40000),
        UTILS.KnotsToKmph(200),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    A2A_Zor:SetSquadronCapInterval("Reds_23", 1, 1800, 2000, 1)
    A2A_Zor:SetSquadronGrouping("Reds_23", 2)
    A2A_Zor:SetSquadronOverhead("Reds_23", 1)
    MESSAGE:New("CAP MiG-23 SPAWNED!!!", 5):ToAll()
end
function spawnCAP29()
    A2A_Al_Assad:SetSquadron("Reds_29", AIRBASE.Syria.Bassel_Al_Assad, "Bassel_Al_Assad_MiG_29")
    A2A_Al_Assad:SetSquadronCap(
        "Reds_29",
        CAP_Al_Assad,
        UTILS.FeetToMeters(10000),
        UTILS.FeetToMeters(30000),
        UTILS.KnotsToKmph(200),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    A2A_Al_Assad:SetSquadronCapInterval("Reds_29", 1, 1800, 2000, 1)
    A2A_Al_Assad:SetSquadronGrouping("Reds_29", 2)
    A2A_Al_Assad:SetSquadronOverhead("Reds_29", 1)
    MESSAGE:New("CAP MiG-29 SPAWNED!!!", 5):ToAll()
end

-- MenuSeler = menu_seler()
local AIMenu = MENU_MISSION:New("REDFOR", MenuSeler)
local Spawn31 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-31", AIMenu, spawnCAP31)
local Spawn29 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-23", AIMenu, spawnCAP23)
local Spawn23 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-29", AIMenu, spawnCAP29)

spawnCAP21()
