ZONE_DARKSTAR_1_AWACS = ZONE:New("DARKSTAR_1_AWACS")
ZONE_DARKSTAR_1_PATROL_CAP = ZONE:New("DARKSTAR_1_PATROL_CAP"):DrawZone(2, CONST.RGB.zone_patrol, 1, CONST.RGB.zone_patrol, .5, 1, true)
ZONE_DARKSTAR_1_ENGAGE = ZONE:New("DARKSTAR_1_ENGAGE"):DrawZone(2, CONST.RGB.zone_bvr, 1, CONST.RGB.zone_bvr, .5, 1, true)

AW_SAWG = AIRWING:New("WH Chico", "Chico Air Wing")

AW_SAWG:SetMarker(false)
AW_SAWG:SetAirbase(AIRBASE:FindByName(AIRBASE.SouthAtlantic.Rio_Chico))
AW_SAWG:SetRespawnAfterDestroyed(600)
AW_SAWG:__Start(2)

AW_SAWG_AWACS = SQUADRON:New("ME AWACS E2D", 2, "AWACS")
AW_SAWG_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_SAWG_AWACS:SetTakeoffType("Air")
AW_SAWG_AWACS:SetFuelLowRefuel(true)
AW_SAWG_AWACS:SetFuelLowThreshold(0.4)
AW_SAWG_AWACS:SetTurnoverTime(30, 5)
AW_SAWG_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_SAWG:AddSquadron(AW_SAWG_AWACS)
AW_SAWG:NewPayload("ME AWACS E2D", -1, { AUFTRAG.Type.ORBIT }, 100)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Darkstar_1_1_route = {ZONE_DARKSTAR_1_AWACS:GetCoordinate(), 35000, 450, 180, 80}

AWACS_DARKSTAR = AWACS:New("DARKSTAR", AW_SAWG, "blue", AIRBASE.SouthAtlantic.Rio_Chico, "DARKSTAR_1_AWACS", "DARKSTAR_1_ENGAGE", "DARKSTAR_1_PATROL_CAP", FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWACS_DARKSTAR:SetBullsEyeAlias("BullsEye")
AWACS_DARKSTAR:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, Darkstar_1_1_route[2], Darkstar_1_1_route[3], Darkstar_1_1_route[4], Darkstar_1_1_route[5])
AWACS_DARKSTAR:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_DARKSTAR:SetModernEraAggressive()

AWACS_DARKSTAR.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_DARKSTAR.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_DARKSTAR.callsignshort = false -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_DARKSTAR.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_DARKSTAR.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_DARKSTAR.maxassigndistance = 200 -- Don't assign targets further out than this, in NM.
AWACS_DARKSTAR.NoMissileCalls = false -- suppress missile callouts
AWACS_DARKSTAR.PlayerCapAssigment = false -- no task assignment for players
AWACS_DARKSTAR.invisible = true -- set AWACS to be invisible to hostiles
AWACS_DARKSTAR.immortal = true -- set AWACS to be immortal
AWACS_DARKSTAR.GoogleTTSPadding = 1 -- seconds
AWACS_DARKSTAR.WindowsTTSPadding = 2.5 -- seconds

AWACS_DARKSTAR:SuppressScreenMessages(false)
AWACS_DARKSTAR:__Start(2)
