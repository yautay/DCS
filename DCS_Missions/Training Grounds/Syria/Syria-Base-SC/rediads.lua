redIADS = SkynetIADS:create('assad_iads')
redIADS:addSAMSitesByPrefix('Red SAM')

redIADS:addEarlyWarningRadarsByPrefix('Red EWR')
redIADS:activate()

sa15 = redIADS:getSAMSiteByGroupName('Red SAM SA15 Latika')
sam1 = redIADS:getSAMSiteByGroupName('Red SAM SA2 Latika')

-- local iadsDebug = redIADS:getDebugSettings()  

-- iadsDebug.IADSStatus = true
-- iadsDebug.contacts = true
-- iadsDebug.jammerProbability = true

-- iadsDebug.addedEWRadar = true
-- iadsDebug.addedSAMSite = true
-- iadsDebug.warnings = true
-- iadsDebug.radarWentLive = true
-- iadsDebug.radarWentDark = true
-- iadsDebug.harmDefence = true

-- iadsDebug.samSiteStatusEnvOutput = true
-- iadsDebug.earlyWarningRadarStatusEnvOutput = true
-- iadsDebug.commandCenterStatusEnvOutput = true