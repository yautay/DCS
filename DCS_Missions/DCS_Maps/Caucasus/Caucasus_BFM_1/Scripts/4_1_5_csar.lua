-- Instantiate and start a CSAR for the blue side, with template "Downed Pilot" and alias "Luftrettung"
mycsar = CSAR:New(coalition.side.BLUE,"Downed Pilot","MIA")
-- options
mycsar.immortalcrew = true -- downed pilot spawn is immortal
mycsar.invisiblecrew = false -- downed pilot spawn is visible
-- start the FSM
mycsar:__Start(5)
mycsar.allowDownedPilotCAcontrol = false -- Set to false if you don\'t want to allow control by Combined Arms.
mycsar.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
mycsar.FARPRescueDistance = 1000 -- you need to be this close to a FARP or Airport for the pilot to be rescued.
mycsar.autosmoke = false -- automatically smoke a downed pilot\'s location when a heli is near.
mycsar.autosmokedistance = 1000 -- distance for autosmoke
mycsar.coordtype = 2 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
mycsar.csarOncrash = true -- (WIP) If set to true, will generate a downed pilot when a plane crashes as well.
mycsar.enableForAI = true -- set to false to disable AI pilots from being rescued.
mycsar.pilotRuntoExtractPoint = true -- Downed pilot will run to the rescue helicopter up to mycsar.extractDistance in meters.
mycsar.extractDistance = 500 -- Distance the downed pilot will start to run to the rescue helicopter.
mycsar.immortalcrew = true -- Set to true to make wounded crew immortal.
mycsar.invisiblecrew = false -- Set to true to make wounded crew insvisible.
mycsar.loadDistance = 75 -- configure distance for pilots to get into helicopter in meters.
mycsar.mashprefix = {"MASH"} -- prefixes of #GROUP objects used as MASHes.
mycsar.max_units = 6 -- max number of pilots that can be carried if #CSAR.AircraftType is undefined.
mycsar.messageTime = 30 -- Time to show messages for in seconds. Doubled for long messages.
mycsar.radioSound = "beacon.ogg" -- the name of the sound file to use for the pilots\' radio beacons.
mycsar.smokecolor = 4 -- Color of smokemarker, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue.
mycsar.useprefix = true  -- Requires CSAR helicopter #GROUP names to have the prefix(es) defined below.
mycsar.csarPrefix = { "helicargo", "MEDEVAC"} -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor!
if (debug_csar) then
	mycsar.verbose = 2 -- set to > 1 for stats output for debugging.
	-- (added 0.1.4) limit amount of downed pilots spawned by **ejection** events
else
	mycsar.verbose = 0
end
mycsar.limitmaxdownedpilots = true
mycsar.maxdownedpilots = 10
-- (added 0.1.8) - allow to set far/near distance for approach and optionally pilot must open doors
mycsar.approachdist_far = 5000 -- switch do 10 sec interval approach mode, meters
mycsar.approachdist_near = 3000 -- switch to 5 sec interval approach mode, meters
mycsar.pilotmustopendoors = false -- switch to true to enable check of open doors
-- (added 0.1.9)
mycsar.suppressmessages = false -- switch off all messaging if you want to do your own
-- (added 0.1.11)
mycsar.rescuehoverheight = 20 -- max height for a hovering rescue in meters
mycsar.rescuehoverdistance = 10 -- max distance for a hovering rescue in meters
-- (added 0.1.12)
-- Country codes for spawned pilots
mycsar.countryblue= country.id.USA
mycsar.countryred = country.id.RUSSIA
mycsar.countryneutral = country.id.UN_PEACEKEEPERS


mycsar.useSRS = true -- Set true to use FF\'s SRS integration
mycsar.SRSPath = "C:\\DCS-SimpleRadio-Standalone" -- adjust your own path in your SRS installation -- server(!)
mycsar.SRSchannel = 242 -- radio channel
mycsar.SRSModulation = radio.modulation.AM -- modulation
mycsar.SRSport = 5002  -- and SRS Server port
mycsar.SRSCulture = "en-GB" -- SRS voice culture
mycsar.SRSVoice = nil -- SRS voice, relevant for Google TTS
mycsar.SRSGPathToCredentials = nil -- Path to your Google credentials json file, set this if you want to use Google TTS
mycsar.SRSVolume = 1 -- Volume, between 0 and 1
--
mycsar.csarUsePara = false -- If set to true, will use the LandingAfterEjection Event instead of Ejection --shagrat
-- mycsar.wetfeettemplate = "man in floating thingy" -- if you use a mod to have a pilot in a rescue float, put the template name in here for wet feet spawns. Note: in conjunction with csarUsePara this might create dual ejected pilots in edge cases.

