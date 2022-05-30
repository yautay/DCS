local con_bandar = StaticObject.getByName("con-bandar") 
local con_siri = StaticObject.getByName("con-bandar") 
local con_kish = StaticObject.getByName("con-bandar") 
local con_cc = StaticObject.getByName("con-cc") 
local red_cc = StaticObject.getByName("red-cc")

redIADS = SkynetIADS:create('iran_iads')
redIADS:addSAMSitesByPrefix('red-sa')

redIADS:addCommandCenter(red_cc):addConnectionNode(con_cc)
redIADS:getSAMSitesByPrefix('red-sa20-1')
-- :addConnectionNode(con_bandar)
redIADS:getSAMSitesByPrefix('red-sa5-1')
-- :addConnectionNode(con_kish)
redIADS:getSAMSitesByPrefix('red-sa2-1')

redIADS:addEarlyWarningRadarsByPrefix('red-ew')
redIADS:activate()

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