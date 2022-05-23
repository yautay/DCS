-- ZONES -----------------------------------------------------
ZONE_Iran = ZONE_POLYGON:New("ZONE-Iran", GROUP:FindByName("iran")):DrawZone(
    -1,
    {1, 1, 0},
    1.0,
    {1, 1, 0},
    0.4,
    2
)
ZONE_cap = ZONE_POLYGON:New("ZONE-cap", GROUP:FindByName("ZONE-cap"))

awacs = SPAWN:New("red-awacs"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25)  
-- START MOOSE CODE:
-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:AddGroupsByName("red-awacs")

-- Setup the detection and group targets to a 30km range!
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

-- Setup the A2A dispatcher, and initialize it.
A2A_Al_Kerman = AI_A2A_DISPATCHER:New( Detection )
A2A_Al_Kerman:SetEngageRadius(150000) -- 100000 is the default value.
A2A_Al_Kerman:SetGciRadius(200000) -- 200000 is the default value.
A2A_Al_Kerman:SetBorderZone(ZONE_Iran)
A2A_Al_Kerman:SetDefaultTakeoffFromRunway()
A2A_Al_Kerman:SetDefaultLandingAtRunway()
A2A_Al_Kerman:SetSquadronGci( "IRAN29", 900, 1200 )
-- A2A_Al_Kerman:SetTacticalDisplay(true)
A2A_Al_Kerman:Start()

-- A2A_Al_Kerman:SetDisengageRadius(UTILS.NMToMeters(80))

function spawnF14()
    A2A_Al_Kerman:SetSquadron("IRAN14", AIRBASE.PersianGulf.Lar_Airbase, "red-f14")
    A2A_Al_Kerman:SetSquadronCap(
        "IRAN14",
        ZONE_cap,
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


