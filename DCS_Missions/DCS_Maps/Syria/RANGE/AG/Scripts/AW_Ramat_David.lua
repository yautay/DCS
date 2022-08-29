ZONE_DARKSTAR_AWACS = ZONE:New("ZONE_DARKSTAR_AWACS")
ZONE_PATROL = ZONE:New("PATROL")

AW_LLRD = AIRWING:New("WH Ramat David", "Ramat David Air Wing")

AW_LLRD:SetMarker(false)
AW_LLRD:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Ramat_David))
AW_LLRD:SetRespawnAfterDestroyed(600)

AW_LLRD_AWACS = SQUADRON:New("ME AWACS RD", 3, "AWACS")
AW_LLRD_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_LLRD_AWACS:SetTakeoffType("Air")
AW_LLRD_AWACS:SetFuelLowRefuel(false)
AW_LLRD_AWACS:SetFuelLowThreshold(0.25)
AW_LLRD_AWACS:SetTurnoverTime(30, 5)
AW_LLRD_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_LLRD:AddSquadron(AW_LLRD_AWACS)
AW_LLRD:NewPayload("ME AWACS RD", -1, { AUFTRAG.Type.ORBIT }, 100)

AW_LLRD:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AWACS_DARKSTAR = AWACS:New("DARKSTAR", AW_LLRD, "blue", AIRBASE.Syria.Ramat_David, "ZONE_DARKSTAR_AWACS", "ENGAGE", "PATROL", FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)

AWACS_DARKSTAR:SetBullsEyeAlias("MIGHTY WOMBAT")
AWACS_DARKSTAR:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, 35000, 330, 020, 40)
AWACS_DARKSTAR:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_DARKSTAR:SetModernEraAgressive()

AWACS_DARKSTAR.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_DARKSTAR.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_DARKSTAR.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_DARKSTAR.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_DARKSTAR.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_DARKSTAR.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AWACS_DARKSTAR.NoMissileCalls = false -- suppress missile callouts
AWACS_DARKSTAR.PlayerCapAssigment = true -- no task assignment for players
AWACS_DARKSTAR.invisible = true -- set AWACS to be invisible to hostiles
AWACS_DARKSTAR.immortal = true -- set AWACS to be immortal
AWACS_DARKSTAR.GoogleTTSPadding = 1 -- seconds
AWACS_DARKSTAR.WindowsTTSPadding = 2.5 -- seconds

AWACS_DARKSTAR:SuppressScreenMessages(false)
AWACS_DARKSTAR:__Start(5)
