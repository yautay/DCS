-- Instantiate and start a CSAR for the blue side, with template "Downed Pilot" and alias "Luftrettung"
blueCSAR = CSAR:New(coalition.side.BLUE, "Downed Pilot", "MIA")
blueCSAR.immortalcrew = true -- downed pilot spawn is immortal
blueCSAR.invisiblecrew = false -- downed pilot spawn is visible

blueCSAR.allowDownedPilotCAcontrol = true -- Set to false if you don\'t want to allow control by Combined Arms.
blueCSAR.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
blueCSAR.FARPRescueDistance = 1000 -- you need to be this close to a FARP or Airport for the pilot to be rescued.
blueCSAR.autosmoke = true -- automatically smoke a downed pilot\'s location when a heli is near.
blueCSAR.autosmokedistance = 1000 -- distance for autosmoke
blueCSAR.coordtype = 2 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
blueCSAR.csarOncrash = false -- (WIP) If set to true, will generate a downed pilot when a plane crashes as well.
blueCSAR.enableForAI = true -- set to false to disable AI pilots from being rescued.
blueCSAR.pilotRuntoExtractPoint = true -- Downed pilot will run to the rescue helicopter up to blueCSAR.extractDistance in meters.
blueCSAR.extractDistance = 500 -- Distance the downed pilot will start to run to the rescue helicopter.
blueCSAR.immortalcrew = true -- Set to true to make wounded crew immortal.
blueCSAR.invisiblecrew = false -- Set to true to make wounded crew insvisible.
blueCSAR.loadDistance = 75 -- configure distance for pilots to get into helicopter in meters.
blueCSAR.mashprefix = { "MASH" } -- prefixes of #GROUP objects used as MASHes.
blueCSAR.max_units = 6 -- max number of pilots that can be carried if #CSAR.AircraftType is undefined.
blueCSAR.messageTime = 15 -- Time to show messages for in seconds. Doubled for long messages.
blueCSAR.radioSound = "beacon.ogg" -- the name of the sound file to use for the pilots\' radio beacons.
blueCSAR.smokecolor = 3 -- Color of smokemarker, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue.
blueCSAR.useprefix = true  -- Requires CSAR helicopter #GROUP names to have the prefix(es) defined below.
blueCSAR.csarPrefix = { "CSAR", "MEDEVAC" } -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor!
blueCSAR.verbose = 0 -- set to > 1 for stats output for debugging.
-- limit amount of downed pilots spawned by **ejection** events
blueCSAR.limitmaxdownedpilots = true
blueCSAR.maxdownedpilots = 20
-- allow to set far/near distance for approach and optionally pilot must open doors
blueCSAR.approachdist_far = 5000 -- switch do 10 sec interval approach mode, meters
blueCSAR.approachdist_near = 3000 -- switch to 5 sec interval approach mode, meters
blueCSAR.pilotmustopendoors = true -- switch to true to enable check of open doors
blueCSAR.suppressmessages = false -- switch off all messaging if you want to do your own
blueCSAR.rescuehoverheight = 20 -- max height for a hovering rescue in meters
blueCSAR.rescuehoverdistance = 10 -- max distance for a hovering rescue in meters
-- Country codes for spawned pilots
blueCSAR.countryblue = country.id.USA
blueCSAR.countryred = country.id.RUSSIA
blueCSAR.countryneutral = country.id.UN_PEACEKEEPERS
blueCSAR.topmenuname = "CSAR" -- set the menu entry name
blueCSAR.ADFRadioPwr = 100 -- ADF Beacons sending with 1KW as default
blueCSAR.PilotWeight = 80 --  Loaded pilots weigh 80kgs each
blueCSAR.csarUsePara = false -- If set to true, will use the LandingAfterEjection Event instead of Ejection. Requires blueCSAR.enableForAI to be set to true. --shagrat
--blueCSAR.wetfeettemplate = "man in floating thingy" -- if you use a mod to have a pilot in a rescue float, put the template name in here for wet feet spawns. Note: in conjunction with csarUsePara this might create dual ejected pilots in edge cases.
blueCSAR.allowbronco = true  -- set to true to use the Bronco mod as a CSAR plane

blueCSAR:__Start(5)