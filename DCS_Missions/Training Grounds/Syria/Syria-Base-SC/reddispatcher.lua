-- ZONES -----------------------------------------------------
ZONE_Assad =
    ZONE_POLYGON:New("ZONE Assad", GROUP:FindByName("ZONE Assad")):DrawZone(
    -1,
    {1, 1, 0},
    1.0,
    {1, 1, 0},
    0.4,
    2
)
ZONE_border =ZONE_POLYGON:New("red_border", GROUP:FindByName("red_border"))

-- EWRS ------------------------------------------------------
RED_EWR_AWACS = SPAWN:New("Red AWACS-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25)

DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:AddGroupsByName("Red AWACS-1", "Red EWR Assad-1", "Red EWR Assad-2")

Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

A2A_Al_Assad = AI_A2A_DISPATCHER:New( Detection )
A2A_Al_Assad:SetEngageRadius(150000) -- 100000 is the default value.
A2A_Al_Assad:SetGciRadius(200000) -- 200000 is the default value.
A2A_Al_Assad:SetBorderZone(ZONE_border)
A2A_Al_Assad:SetDefaultTakeoffFromRunway()
A2A_Al_Assad:SetDefaultLandingAtRunway()
A2A_Al_Assad:SetDefaultFuelThreshold( 0.3 )
-- A2A_Al_Assad:SetTacticalDisplay(true)


math.randomseed = os.clock()*100000000000
red_fighters_random = math.random(0, 100)
env.info("SEED RANDOMIZED")
env.info(red_fighters_random)

function spawnGCI21()
    A2A_Al_Assad:SetSquadron("Reds_21", AIRBASE.Syria.Bassel_Al_Assad, "mig_21")
    A2A_Al_Assad:SetSquadronGrouping("Reds_21", 2)
    A2A_Al_Assad:SetSquadronOverhead("Reds_21", 1.2)
end
function spawnGCI31()
    A2A_Al_Assad:SetSquadron("Reds_31", AIRBASE.Syria.Tabqa, "mig_31")
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
    A2A_Al_Assad:SetSquadronCapInterval("Reds_23", 2, 600, 1200, 1)
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
    A2A_Al_Assad:SetSquadronCapInterval("Reds_29", 2, 600, 1200, 1)
    A2A_Al_Assad:SetSquadronGrouping("Reds_29", 2)
    A2A_Al_Assad:SetSquadronOverhead("Reds_29", 1)
end

if red_fighters_random < 60 then
    spawnCAP23() 
    env.info("CAP23")
else 
    spawnCAP29()
    env.info("CAP29")
end

if red_fighters_random < 80 then
    spawnGCI21() 
    env.info("GCI21")
    A2A_Al_Assad:SetSquadronGci( "Reds_21", 600, 2500 )
else 
    spawnGCI31() 
    env.info("GCI31")
    A2A_Al_Assad:SetSquadronGci( "Reds_31", 600, 2500 )
end

-- MenuSeler = menu_seler()
-- local AIMenu = MENU_MISSION:New("REDFOR", MenuSeler)
-- local Spawn31 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-31", AIMenu, spawnCAP31)
-- local Spawn29 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-23", AIMenu, spawnCAP23)
-- local Spawn23 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-29", AIMenu, spawnCAP29)

A2A_Al_Assad:Start()