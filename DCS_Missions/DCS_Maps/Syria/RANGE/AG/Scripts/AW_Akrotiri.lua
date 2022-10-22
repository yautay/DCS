function orbit_mark(route, text)
    route[1]:LineToAll(calculateCoordinateFromRoute(route[1], route[4], route[5], false, false), 2, CONST.RGB.range, 1, 2, true, text)
end

ZONE_SHELL_1_AAR = ZONE:New("SHELL_1_AAR")
ZONE_TEXACO_1_AAR = ZONE:New("TEXACO_1_AAR")
ZONE_DARKSTAR_1_AWACS = ZONE:New("DARKSTAR_1_AWACS")
ZONE_PATROL = ZONE_POLYGON:NewFromGroupName("LARNACA_PARTOL"):DrawZone(2, CONST.RGB.zone_patrol, 1, CONST.RGB.zone_patrol, .5, 1, true)
ZONE_ENGAGE = ZONE_POLYGON:NewFromGroupName("KILLBOX"):DrawZone(2, CONST.RGB.zone_bvr, 1, CONST.RGB.zone_bvr, .5, 1, true)

AW_LCRA = AIRWING:New("WH Akrotiri", "Akrotiri Air Wing")

AW_LCRA:SetMarker(false)
AW_LCRA:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Akrotiri))
AW_LCRA:SetRespawnAfterDestroyed(600)
AW_LCRA:__Start(2)

AW_LCRA_AAR_MPRS = SQUADRON:New("ME AAR MPRS", 3, "AAR Squadron")
AW_LCRA_AAR_MPRS:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LCRA_AAR_MPRS:SetTakeoffType("Hot")
AW_LCRA_AAR_MPRS:SetFuelLowRefuel(false)
AW_LCRA_AAR_MPRS:SetFuelLowThreshold(0.3)
AW_LCRA_AAR_MPRS:SetTurnoverTime(30, 5)
AW_LCRA:AddSquadron(AW_LCRA_AAR_MPRS)
AW_LCRA:NewPayload("ME AAR MPRS", -1, { AUFTRAG.Type.TANKER }, 100)

AW_LCRA_AAR = SQUADRON:New("ME AAR", 3, "AAR")
AW_LCRA_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LCRA_AAR:SetTakeoffType("Hot")
AW_LCRA_AAR:SetFuelLowRefuel(false)
AW_LCRA_AAR:SetFuelLowThreshold(0.3)
AW_LCRA_AAR:SetTurnoverTime(30, 5)
AW_LCRA:AddSquadron(AW_LCRA_AAR)
AW_LCRA:NewPayload("ME AAR", -1, { AUFTRAG.Type.TANKER }, 100)

local Shell_1_1_route = {ZONE_SHELL_1_AAR:GetCoordinate(), 28000, 480, 135, 40}
orbit_mark(Shell_1_1_route, "SHELL 1-1")

MISSION_Shell_1 = AUFTRAG:NewTANKER(Shell_1_1_route[1], Shell_1_1_route[2], Shell_1_1_route[3], Shell_1_1_route[4], Shell_1_1_route[5], 1)
MISSION_Shell_1:AssignSquadrons({ AW_LCRA_AAR_MPRS })
MISSION_Shell_1:SetRadio(FREQUENCIES.AAR.shell_1[1])
MISSION_Shell_1:SetName("Shell One")
AW_LCRA:AddMission(MISSION_Shell_1)

local Texaco_1_1_route = {ZONE_TEXACO_1_AAR:GetCoordinate(), 30000, 480, 0, 40}
orbit_mark(Texaco_1_1_route, "TEXACO 1-1")

MISSION_Texaco_1 = AUFTRAG:NewTANKER(Texaco_1_1_route[1], Texaco_1_1_route[2], Texaco_1_1_route[3], Texaco_1_1_route[4], Texaco_1_1_route[5], 0)
MISSION_Texaco_1:AssignSquadrons({ AW_LCRA_AAR })
MISSION_Texaco_1:SetRadio(FREQUENCIES.AAR.texaco_1[1])
MISSION_Texaco_1:SetName("Texaco One")
AW_LCRA:AddMission(MISSION_Texaco_1)

AW_LCRA_AWACS = SQUADRON:New("ME AWACS RJ", 2, "AWACS")
AW_LCRA_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_LCRA_AWACS:SetTakeoffType("Hot")
AW_LCRA_AWACS:SetFuelLowRefuel(true)
AW_LCRA_AWACS:SetFuelLowThreshold(0.4)
AW_LCRA_AWACS:SetTurnoverTime(30, 5)
AW_LCRA_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_LCRA:AddSquadron(AW_LCRA_AWACS)
AW_LCRA:NewPayload("ME AWACS RJ", -1, { AUFTRAG.Type.ORBIT }, 100)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Darkstar_1_1_route = {ZONE_DARKSTAR_1_AWACS:GetCoordinate(), 35000, 450, 180, 80}
orbit_mark(Darkstar_1_1_route, "DARKSTAR 1-1")

AWACS_DARKSTAR = AWACS:New("DARKSTAR", AW_LCRA, "blue", AIRBASE.Syria.Akrotiri, "DARKSTAR_1_AWACS", "KILLBOX", "LARNACA_PARTOL", FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWACS_DARKSTAR:SetBullsEyeAlias("CRUSADER")
AWACS_DARKSTAR:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, Darkstar_1_1_route[2], Darkstar_1_1_route[3], Darkstar_1_1_route[4], Darkstar_1_1_route[5])
AWACS_DARKSTAR:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_DARKSTAR:SetModernEraAggressive()

AWACS_DARKSTAR.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_DARKSTAR.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_DARKSTAR.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_DARKSTAR.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_DARKSTAR.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_DARKSTAR.maxassigndistance = 150 -- Don't assign targets further out than this, in NM.
AWACS_DARKSTAR.NoMissileCalls = false -- suppress missile callouts
AWACS_DARKSTAR.PlayerCapAssigment = true -- no task assignment for players
AWACS_DARKSTAR.invisible = true -- set AWACS to be invisible to hostiles
AWACS_DARKSTAR.immortal = true -- set AWACS to be immortal
AWACS_DARKSTAR.GoogleTTSPadding = 1 -- seconds
AWACS_DARKSTAR.WindowsTTSPadding = 2.5 -- seconds

AWACS_DARKSTAR:SuppressScreenMessages(true)
AWACS_DARKSTAR:__Start(2)
