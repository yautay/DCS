local debug_rediads = false

function add_sam_sites(iads, sam_units)
    for k, v in pairs(sam_units) do
        iads:addSAMSite(v)
    end
end

function add_ewr_sites(iads, template)
    for k, v in pairs(template) do
        iads:addEarlyWarningRadar(v)
    end
end        

-- local con_cc = StaticObject.getByName("con-cc")
-- local red_cc = StaticObject.getByName("red-cc")

Iads = SkynetIADS:create("MERAD_iads")

add_ewr_sites(Iads, ewr_units)
add_ewr_sites(Iads, awacs_units)
add_sam_sites(Iads, sam_groups)

Iads:activate()


if (debug_rediads) then
    local Debug = Iads:getDebugSettings()
    Debug.IADSStatus = true
    Debug.contacts = false
    Debug.jammerProbability = true
    Debug.addedEWRadar = true
    Debug.addedSAMSite = true
    Debug.warnings = true
    Debug.radarWentLive = true
    Debug.radarWentDark = true
    Debug.harmDefence = true
    Debug.samSiteStatusEnvOutput = true
    Debug.earlyWarningRadarStatusEnvOutput = true
    Debug.commandCenterStatusEnvOutput = true
end
