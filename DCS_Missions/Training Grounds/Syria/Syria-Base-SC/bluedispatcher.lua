local debug_bluedispatcher = false

-- ZONES -----------------------------------------------------
ZONE_cap_cv = ZONE_POLYGON:New("ZONE-CV-CAP", GROUP:FindByName("ZONE-CV-CAP"))

-- DETECTION -----------------------------------------------------
detection_assets = SET_GROUP:New():FilterCoalitions("blue"):FilterActive():FilterPrefixes("AWACS"):FilterStart()
DetectionSetGroup = SET_GROUP:New()

function addDetectionGroups(template_detection_groups)
    objects = template_detection_groups:GetAliveSet()
    for i, v in pairs(objects) do
        DetectionSetGroup:AddGroupsByName(GROUP:FindByName(v:GetName()))
    end
end

addDetectionGroups(detection_assets)

Detection = DETECTION_AREAS:New(DetectionSetGroup, 30000)

-- DISPATCHER -----------------------------------------------------

A2A_BLUE = AI_A2A_DISPATCHER:New(Detection)
A2A_BLUE:SetEngageRadius(UTILS.NMToMeters(40)) -- 100000 is the default value.
A2A_BLUE:SetDisengageRadius(UTILS.NMToMeters(50))
A2A_BLUE:SetDefaultTakeoffFromRunway()
A2A_BLUE:SetDefaultLandingAtRunway()
A2A_BLUE:Start()

function spawnCAP(sq_name, template_name, base, palnes, grouping, overhead, cap_zone)
    A2A_BLUE:SetSquadron(sq_name, base, template_name, planes)
    A2A_BLUE:SetSquadronCap(
        sq_name,
        cap_zone,
        UTILS.FeetToMeters(35000),
        UTILS.FeetToMeters(30000),
        UTILS.KnotsToKmph(350),
        UTILS.KnotsToKmph(350),
        UTILS.KnotsToKmph(250),
        UTILS.KnotsToKmph(900),
        "BARO"
    )
    A2A_BLUE:SetSquadronGrouping(sq_name, grouping)
    A2A_BLUE:SetSquadronOverhead(sq_name, overhead)
end


-- SQUADRONS sq_name, template_name, base, palnes, grouping, overhead, cap_zone   -------

local squadrons = {
    f18_cv = {"VFA-37", "Hornet-AI", "CVN", 10, 2, 1, ZONE_cap_cv},
}

for k, v in pairs(squadrons) do
    spawnCAP(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
end

if (debug_bluedispatcher == true) then
    A2A_BLUE:SetTacticalDisplay(true)
    env.info(string.format("BLUE DETECTION SET: %s", DetectionSetGroup:GetObjectNames()))
end
