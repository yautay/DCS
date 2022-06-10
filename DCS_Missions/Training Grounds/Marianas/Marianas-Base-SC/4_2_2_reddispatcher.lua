-- DETECTION -----------------------------------------------------
tmp_det_gropus = {"RED-EWR-TINIAN"}

DetectionSetGroup = SET_GROUP:New()

function addDetectionGroups(template_detection_groups)
    for k, v in pairs(template_detection_groups) do
        DetectionSetGroup:AddGroupsByName(GROUP:FindByName(v))
    end
end

addDetectionGroups(tmp_det_gropus)

Detection = DETECTION_AREAS:New(DetectionSetGroup, 30000)

-- DISPATCHER -----------------------------------------------------

A2A_Tinian = AI_A2A_DISPATCHER:New(Detection)
A2A_Tinian:SetEngageRadius(UTILS.NMToMeters(75)) -- 100000 is the default value.
A2A_Tinian:SetDisengageRadius(UTILS.NMToMeters(80))
A2A_Tinian:SetGciRadius(UTILS.NMToMeters(75)) -- 200000 is the default value.
A2A_Tinian:SetBorderZone(zoneRED)
A2A_Tinian:SetDefaultTakeoffFromRunway()
A2A_Tinian:SetDefaultLandingAtRunway()
A2A_Tinian:Start()

-- function spawnCAP(template_name, palnes, grouping, overhead)
--     A2A_Al_Kerman:SetSquadron("IRAN_CAP", AIRBASE.PersianGulf.Lar_Airbase, template_name, planes)
--     A2A_Al_Kerman:SetSquadronCap(
--         "IRAN_CAP",
--         ZONE_cap_1,
--         UTILS.FeetToMeters(35000),
--         UTILS.FeetToMeters(30000),
--         UTILS.KnotsToKmph(350),
--         UTILS.KnotsToKmph(350),
--         UTILS.KnotsToKmph(250),
--         UTILS.KnotsToKmph(900),
--         "BARO"
--     )
--     -- A2A_Al_Kerman:SetSquadronCapInterval("IRAN_CAP", 2, 1800, 2000, 1)
--     A2A_Al_Kerman:SetSquadronGrouping("IRAN_CAP", grouping)
--     A2A_Al_Kerman:SetSquadronOverhead("IRAN_CAP", overhead)
-- end

function spawnCGI(template_name, base, palnes, grouping, overhead)
    A2A_Tinian:SetSquadron("RED_GCI", base, template_name, planes)
    A2A_Tinian:SetSquadronGrouping("RED_GCI", grouping)
    A2A_Tinian:SetSquadronOverhead("RED_GCI", overhead)
    A2A_Tinian:SetSquadronGci("RED_GCI", 900, 1200)
end

-- SQUADRONS /template/planes/grouping/overhead-----------------------------------------------------

local squadrons = {
    -- f14 = {"red-f14", 8, 2, 1},
    -- m2k = {"red-mirage2000", 10, 2, 1},
    m23 = {"RED-MIG-23", AIRBASE.MarianaIslands.Tinian_Intl,  8, 2, 1},
    -- m29 = {"red-mig29", 20, 2, 1},
    -- m21 = {"red-mig21", 35, 2, 1.05},
    -- f5 = {"red-f5", 20, 2, 1}
}

-- math.randomseed = os.clock() * 100000000000

-- local cap_random = math.random(0, 100)
-- local gci_random = math.random(0, 100)
-- env.info(string.format("CAP SEED RANDOMIZED -> %d", cap_random))
-- env.info(string.format("GCI SEED RANDOMIZED -> %d", gci_random))

-- local cap_squadron = {}
-- if (cap_random >= 0) and (cap_random <= 30) then
--     cap_squadron = squadrons.f14
-- elseif (cap_random >= 31) and (cap_random <= 70) then
--     cap_squadron = squadrons.m23
-- else
--     cap_squadron = squadrons.m2k
-- end

-- local gci_squadron = {}
-- if (gci_random >= 0) and (gci_random <= 25) then
--     gci_squadron = squadrons.m29
-- elseif (gci_random >= 26) and (gci_random <= 50) then
--     gci_squadron = squadrons.m21
-- elseif (gci_random >= 51) and (gci_random <= 75) then
--     gci_squadron = squadrons.f5
-- else
--     gci_squadron = squadrons.m23
-- end

-- spawnCAP(cap_squadron[1], cap_squadron[2], cap_squadron[3], cap_squadron[4])
-- spawnCGI(gci_squadron[1], gci_squadron[2], gci_squadron[3], gci_squadron[4])
spawnCGI(squadrons.m23[1], squadrons.m23[2], squadrons.m23[3], squadrons.m23[4], squadrons.m23[5])

if (debug_reddispatcher) then
    A2A_Tinian:SetTacticalDisplay(true)
    env.info(string.format("DETECTION SET: %s", DetectionSetGroup:GetObjectNames()))
end
