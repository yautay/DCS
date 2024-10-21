ZONE_AWACS = ZONE:New("AWACS")
ZONE_CAP = ZONE:New("PARIS")

marker_SA3 = MARKER:New( ZONE_CAP:GetCoordinate(), "PARIS"):ToCoalition( coalition.side.BLUE )
local awacs_route = {ZONE_AWACS:GetCoordinate(), 35000, 320, 045, 40}

AWACS = AWACS:New("WIZARD", AW_BLUE, "blue", AIRBASE.Caucasus.Kutaisi, "AWACS", "BRAVO", "PARIS", FREQUENCIES.AWACS.wizard[1], radio.modulation.AM)
AWACS:SetBullsEyeAlias("BULLS")
AWACS:SetAwacsDetails(CALLSIGN.AWACS.Wizard, 1, awacs_route[2], awacs_route[3], awacs_route[4], awacs_route[5])
AWACS:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS:SetModernEraAggressive()

AWACS.PlayerGuidance = false -- allow missile warning call-outs.
AWACS.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS.DeclareRadius = 10 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS.maxassigndistance = 200 -- Don't assign targets further out than this, in NM.
AWACS.NoMissileCalls = true -- suppress missile callouts
AWACS.PlayerCapAssigment = true -- no task assignment for players
AWACS.invisible = true -- set AWACS to be invisible to hostiles
AWACS.immortal = true -- set AWACS to be immortal

AWACS:SuppressScreenMessages(false)
AWACS:__Start(2)