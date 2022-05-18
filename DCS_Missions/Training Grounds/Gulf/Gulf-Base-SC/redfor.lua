-- ###########################################################
-- ###                   RED COALITION                     ###
-- ###########################################################

-- ZONES -----------------------------------------------------
local ZONE_Assad =
    ZONE_POLYGON:New("ZONE Assad", GROUP:FindByName("ZONE Assad")):DrawZone(
    -1,
    {1, 1, 0},
    1.0,
    {1, 1, 0},
    0.4,
    2
)


-- EWRS ------------------------------------------------------
local RED_EWR_Assad = SPAWN:New("Red EWR Assad"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:30:00"), .25)
local RED_EWR_Assad_1 = SPAWN:New("Red EWR Assad-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:30:00"), .25)
local RED_EWR_Assad_2 = SPAWN:New("Red EWR Assad-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:30:00"), .25)
local RED_EWR_Assad_3 = SPAWN:New("Red EWR Assad-3"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:30:00"), .25)
local RED_EWR_Assad_4 = SPAWN:New("Red EWR Assad-4"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:30:00"), .25)
local RED_EWR_AWACS = SPAWN:New("Red AWACS"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25)

-- LR SAMS ------------------------------------------------------
local Red_SAM_SA5_Assad = SPAWN:New("Red SAM SA-2 HDS Assad"):InitLimit(14, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
local Red_SAM_SA3_Assad = SPAWN:New("Red SAM SA-3 HDS Assad"):InitLimit(14, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )

-- SHORADS ------------------------------------------------------
local Red_SHORAD_SA_15_Assad = SPAWN:New("Red SHORAD SA-15 SA2 Assad"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )

-- CC ------------------------------------------------------
local Red_CC_SA2_Assad = SPAWN:New("Red CC SAM SA2 Assad"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )


--DSIPATCHERS -----------------------------------------------
A2A_Al_Assad =
    AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"Red AWACS", "Red EWR"}):FilterStart(), 100000))
A2A_Al_Assad:SetBorderZone(ZONE_Assad)
A2A_Al_Assad:SetDefaultTakeoffFromRunway()
A2A_Al_Assad:SetDefaultLandingAtRunway()
A2A_Al_Assad:SetDefaultFuelThreshold(0.40)
A2A_Al_Assad:SetDefaultDamageThreshold(0.90)
A2A_Al_Assad:SetEngageRadius(UTILS.NMToMeters(80))
A2A_Al_Assad:SetDisengageRadius(UTILS.NMToMeters(80))

function spawnCAP21()
    A2A_Al_Assad:SetSquadron("Reds_21", AIRBASE.Syria.Bassel_Al_Assad, "mig_21")
    A2A_Al_Assad:SetSquadronCap(
        "Reds_21",
        ZONE_Assad,
        UTILS.FeetToMeters(25000),
        UTILS.FeetToMeters(27000),
        UTILS.KnotsToKmph(200),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    A2A_Al_Assad:SetSquadronCapInterval("Reds_21", 2, 1800, 2000, 1)
    A2A_Al_Assad:SetSquadronGrouping("Reds_21", 4)
    A2A_Al_Assad:SetSquadronOverhead("Reds_21", 1)
end

function spawnCAP31()
    A2A_Al_Assad:SetSquadron("Reds_31", AIRBASE.Syria.Tabqa, "mig_31")
    A2A_Al_Assad:SetSquadronCap(
        "Reds_31",
        ZONE_Assad,
        UTILS.FeetToMeters(40000),
        UTILS.FeetToMeters(42000),
        UTILS.KnotsToKmph(220),
        UTILS.KnotsToKmph(300),
        UTILS.KnotsToKmph(300),
        UTILS.KnotsToKmph(1200),
        "BARO"
    )
    A2A_Al_Assad:SetSquadronCapInterval("Reds_31", 1, 1800, 2000, 1)
    A2A_Al_Assad:SetSquadronGrouping("Reds_31", 2)
    A2A_Al_Assad:SetSquadronOverhead("Reds_31", 1)
end
function spawnCAP23()
    A2A_Al_Assad:SetSquadron("Reds_23", AIRBASE.Syria.Bassel_Al_Assad, "mig_23")
    A2A_Al_Assad:SetSquadronCap(
        "Reds_23",
        ZONE_Assad,
        UTILS.FeetToMeters(25000),
        UTILS.FeetToMeters(40000),
        UTILS.KnotsToKmph(200),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    A2A_Al_Assad:SetSquadronCapInterval("Reds_23", 2, 1800, 2000, 1)
    A2A_Al_Assad:SetSquadronGrouping("Reds_23", 2)
    A2A_Al_Assad:SetSquadronOverhead("Reds_23", 1)
end
function spawnCAP29()
    A2A_Al_Assad:SetSquadron("Reds_29", AIRBASE.Syria.Bassel_Al_Assad, "mig_29")
    A2A_Al_Assad:SetSquadronCap(
        "Reds_29",
        ZONE_Assad,
        UTILS.FeetToMeters(10000),
        UTILS.FeetToMeters(30000),
        UTILS.KnotsToKmph(200),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    A2A_Al_Assad:SetSquadronCapInterval("Reds_29", 2, 1800, 2000, 1)
    A2A_Al_Assad:SetSquadronGrouping("Reds_29", 2)
    A2A_Al_Assad:SetSquadronOverhead("Reds_29", 1)
end

math.randomseed = os.clock()*100000000000


local cap_random = math.random(0, 100)
env.info("SEED RANDOMIZED")
env.info(cap_random)
if cap_random < 25 then
    spawnCAP21() 
    env.info("CAP21")
elseif cap_random >= 25 and cap_random < 50 then
    spawnCAP23()
    env.info("CAP23")
elseif cap_random >= 50 and cap_random < 90 then
    spawnCAP29()
    env.info("CAP29")
else
    spawnCAP31()
    env.info("CAP31")
end



-- MenuSeler = menu_seler()
-- local AIMenu = MENU_MISSION:New("REDFOR", MenuSeler)
-- local Spawn31 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-31", AIMenu, spawnCAP31)
-- local Spawn29 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-23", AIMenu, spawnCAP23)
-- local Spawn23 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-29", AIMenu, spawnCAP29)


