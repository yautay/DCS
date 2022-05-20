redIADS = SkynetIADS:create('iran_iads')
redIADS:addSAMSitesByPrefix('red-sa5')
redIADS:addEarlyWarningRadarsByPrefix('red-ew')
redIADS:activate()

local iadsDebug = redIADS:getDebugSettings()  

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