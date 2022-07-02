blueIADS = SkynetIADS:create("uae_iads")
blueIADS:addSAMSitesByPrefix("blue-sam")
blueIADS:addEarlyWarningRadarsByPrefix("AWACS Hormuz")
blueIADS:activate()

if (debug_blueiads) then
    local iadsDebug = blueIADS:getDebugSettings()

    iadsDebug.IADSStatus = true
    iadsDebug.contacts = true
    iadsDebug.jammerProbability = true

    iadsDebug.addedEWRadar = true
    iadsDebug.addedSAMSite = true
    iadsDebug.warnings = true
    iadsDebug.radarWentLive = true
    iadsDebug.radarWentDark = true
    iadsDebug.harmDefence = true

    iadsDebug.samSiteStatusEnvOutput = true
    iadsDebug.earlyWarningRadarStatusEnvOutput = true
    iadsDebug.commandCenterStatusEnvOutput = true
end
