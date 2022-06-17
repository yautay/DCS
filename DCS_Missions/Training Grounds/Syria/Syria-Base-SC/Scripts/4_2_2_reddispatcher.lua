if (dispatcher_red) then
    -- ZONES -----------------------------------------------------
    ZONE_border_1 = ZONE_POLYGON:New("red_border_1", GROUP:FindByName("red_border_1"))
    ZONE_cap_1 = ZONE_POLYGON:New("red_cap_1", GROUP:FindByName("red_cap_1"))

    -- DETECTION -----------------------------------------------------

    DetectionSetGroup = SET_GROUP:New()

    local function addDetectionGroups(template_detection_groups)
        for k, v in pairs(template_detection_groups) do
            DetectionSetGroup:AddGroupsByName(GROUP:FindByName(v))
        end
    end

    addDetectionGroups(ewr_groups)
    addDetectionGroups(awacs_groups)

    Detection = DETECTION_AREAS:New(DetectionSetGroup, 30000)

    -- DISPATCHER -----------------------------------------------------

    A2A_Al_Kerman = AI_A2A_DISPATCHER:New(Detection)
    A2A_Al_Kerman:SetEngageRadius(UTILS.NMToMeters(75)) -- 100000 is the default value.
    -- A2A_Al_Kerman:SetDisengageRadius(UTILS.NMToMeters(80))
    A2A_Al_Kerman:SetGciRadius(UTILS.NMToMeters(120)) -- 200000 is the default value.
    A2A_Al_Kerman:SetBorderZone(ZONE_border_1)
    A2A_Al_Kerman:SetDefaultTakeoffFromRunway()
    A2A_Al_Kerman:SetDefaultLandingAtRunway()
    A2A_Al_Kerman:Start()

    local function spawnCAP(template_name, palnes, grouping, overhead)
        A2A_Al_Kerman:SetSquadron("IRAN_CAP", AIRBASE.PersianGulf.Lar_Airbase, template_name, planes)
        A2A_Al_Kerman:SetSquadronCap(
            "IRAN_CAP",
            ZONE_cap_1,
            UTILS.FeetToMeters(35000),
            UTILS.FeetToMeters(30000),
            UTILS.KnotsToKmph(350),
            UTILS.KnotsToKmph(350),
            UTILS.KnotsToKmph(250),
            UTILS.KnotsToKmph(900),
            "BARO"
        )
        -- A2A_Al_Kerman:SetSquadronCapInterval("IRAN_CAP", 2, 1800, 2000, 1)
        A2A_Al_Kerman:SetSquadronGrouping("IRAN_CAP", grouping)
        A2A_Al_Kerman:SetSquadronOverhead("IRAN_CAP", overhead)
    end

    local function spawnCGI(template_name, palnes, grouping, overhead)
        A2A_Al_Kerman:SetSquadron("IRAN_CGI", AIRBASE.PersianGulf.Lar_Airbase, template_name, planes)
        A2A_Al_Kerman:SetSquadronGrouping("IRAN_CGI", grouping)
        A2A_Al_Kerman:SetSquadronOverhead("IRAN_CGI", overhead)
        A2A_Al_Kerman:SetSquadronGci("IRAN_CGI", 900, 1200)
    end

    -- SQUADRONS /template/planes/grouping/overhead-----------------------------------------------------

    local squadrons = {
        f14 = {"red-f14", 8, 2, 1},
        m2k = {"red-mirage2000", 10, 2, 1},
        m23 = {"red-mig23", 25, 2, 1},
        m29 = {"red-mig29", 20, 2, 1},
        m21 = {"red-mig21", 35, 2, 1.05},
        f5 = {"red-f5", 20, 2, 1}
    }

    math.randomseed = os.clock() * 100000000000

    local cap_random = math.random(0, 100)
    local gci_random = math.random(0, 100)
    env.info(string.format("CAP SEED RANDOMIZED -> %d", cap_random))
    env.info(string.format("GCI SEED RANDOMIZED -> %d", gci_random))

    local cap_squadron = {}
    if (cap_random >= 0) and (cap_random <= 30) then
        cap_squadron = squadrons.f14
    elseif (cap_random >= 31) and (cap_random <= 70) then
        cap_squadron = squadrons.m23
    else
        cap_squadron = squadrons.m2k
    end

    local gci_squadron = {}
    if (gci_random >= 0) and (gci_random <= 25) then
        gci_squadron = squadrons.m29
    elseif (gci_random >= 26) and (gci_random <= 50) then
        gci_squadron = squadrons.m21
    elseif (gci_random >= 51) and (gci_random <= 75) then
        gci_squadron = squadrons.f5
    else
        gci_squadron = squadrons.m23
    end

    spawnCAP(cap_squadron[1], cap_squadron[2], cap_squadron[3], cap_squadron[4])
    spawnCGI(gci_squadron[1], gci_squadron[2], gci_squadron[3], gci_squadron[4])

    if (debug_reddispatcher == true) then
        A2A_Al_Kerman:SetTacticalDisplay(true)
        env.info(string.format("DETECTION SET: %s", DetectionSetGroup:GetObjectNames()))
    end
end