-- ZONES -----------------------------------------------------

ZONE_border_1 =
    ZONE_POLYGON:New("red_border_1", GROUP:FindByName("red_border_1")):DrawZone(
    -1,
    {.8, 0, 0},
    1.0,
    {.8, 0, 0},
    .4,
    2
)
ZONE_cap_1 =ZONE_POLYGON:New("red_cap_1", GROUP:FindByName("red_cap_1"))

awacs_1 = SPAWN:New("red-awacs-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25)
awacs_2 = SPAWN:New("red-awacs-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25)  

DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:AddGroupsByName("red-awacs-1", "red-awacs-2")
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

A2A_Al_Kerman = AI_A2A_DISPATCHER:New( Detection )
A2A_Al_Kerman:SetEngageRadius(UTILS.NMToMeters(75)) -- 100000 is the default value.
-- A2A_Al_Kerman:SetDisengageRadius(UTILS.NMToMeters(80))
A2A_Al_Kerman:SetGciRadius(UTILS.NMToMeters(120)) -- 200000 is the default value.
A2A_Al_Kerman:SetBorderZone(ZONE_border_1)
A2A_Al_Kerman:SetDefaultTakeoffFromRunway()
A2A_Al_Kerman:SetDefaultLandingAtRunway()
A2A_Al_Kerman:SetSquadronGci( "IRAN29", 900, 1200 )
-- A2A_Al_Kerman:SetTacticalDisplay(true)
A2A_Al_Kerman:Start()



function spawnF14()
    A2A_Al_Kerman:SetSquadron("IRAN14", AIRBASE.PersianGulf.Lar_Airbase, "red-f14")
    A2A_Al_Kerman:SetSquadronCap(
        "IRAN14",
        ZONE_cap_1,
        UTILS.FeetToMeters(40000),
        UTILS.FeetToMeters(35000),
        UTILS.KnotsToKmph(350),
        UTILS.KnotsToKmph(350),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    
    -- A2A_Al_Kerman:SetSquadronCapInterval("IRAN14", 2, 1800, 2000, 1)
    A2A_Al_Kerman:SetSquadronGrouping("IRAN14", 2)
    A2A_Al_Kerman:SetSquadronOverhead("IRAN14", 1)
end
function spawnM29()
    A2A_Al_Kerman:SetSquadron("IRAN29", AIRBASE.PersianGulf.Lar_Airbase, "red-mig29")  
    A2A_Al_Kerman:SetSquadronGrouping("IRAN29", 2)
    A2A_Al_Kerman:SetSquadronOverhead("IRAN29", 1.2)
end

spawnF14()
spawnM29()

math.randomseed = os.clock()*100000000000


local cap_random = math.random(0, 100)
env.info("SEED RANDOMIZED")
env.info(cap_random)

-- MenuSeler = menu_seler()
-- local AIMenu = MENU_MISSION:New("REDFOR", MenuSeler)
-- local Spawn31 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-31", AIMenu, spawnCAP31)
-- local Spawn29 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-23", AIMenu, spawnCAP23)
-- local Spawn23 = MENU_MISSION_COMMAND:New("Spawn CAP MiG-29", AIMenu, spawnCAP29)
