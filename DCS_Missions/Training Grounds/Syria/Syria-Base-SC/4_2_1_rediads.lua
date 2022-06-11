if (iads_red) then 
    RedIads = SkynetIADS:create("RedIads")

    add_ewr_sites(Iads, ewr_units)
    add_ewr_sites(Iads, awacs_units)
    add_sam_sites(Iads, sam_groups)

    RedIads:activate()


    if (debug_rediads) then
        local Debug = RedIads:getDebugSettings()
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
end
