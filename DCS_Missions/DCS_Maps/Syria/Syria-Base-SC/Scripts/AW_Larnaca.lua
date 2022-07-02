
-- ###########################################################
-- ###                  Larnaca Air Wing                   ###
-- ###########################################################
ZONE_ZEUS_CAP = ZONE:New("ZEUS")
ZONE_NEPTUNE_FEZ = ZONE:New("NEPTUNE")
ZONE_OVERLORD_AWACS = ZONE:New("OVERLORD")
ZONE_TEXACO_AAR = ZONE:New("TEXACO")

AWLarnaca = AIRWING:New("WH Larnaca", "Larnaca Air Wing")

if (debug_aw_larnaca) then
	function AWLarnaca:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWLarnaca:SetMarker(false)
AWLarnaca:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Larnaca))
AWLarnaca:SetRespawnAfterDestroyed(600)


local Larnaca_AWACS = SQUADRON:New("ME AWACS L",2,"AWACS Larnaca")
Larnaca_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Larnaca_AWACS:SetTakeoffAir()
Larnaca_AWACS:SetFuelLowRefuel(true)
Larnaca_AWACS:SetFuelLowThreshold(0.3)
Larnaca_AWACS:SetTurnoverTime(30,180)
Larnaca_AWACS:SetCallsign(CALLSIGN.Aircraft.Overlord, 1)
Larnaca_AWACS:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)

local Larnaca_HORNET = SQUADRON:New("ME HORNET HELLENIC",2,"AWACS Larnaca Escort")
Larnaca_HORNET:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
Larnaca_HORNET:AddMissionCapability({AUFTRAG.Type.CAP}, 50)
Larnaca_HORNET:SetTakeoffHot()
Larnaca_HORNET:SetFuelLowRefuel(true)
Larnaca_HORNET:SetFuelLowThreshold(0.3)
Larnaca_HORNET:SetTurnoverTime(10,60)
Larnaca_AWACS:SetCallsign(CALLSIGN.Aircraft.Ford, 2)
Larnaca_HORNET:SetTakeoffHot()
Larnaca_HORNET:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)

local Larnaca_EAGLE = SQUADRON:New("ME EAGLE HELLENIC",3,"Larnaca CAP")
Larnaca_EAGLE:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.ESCORT, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
Larnaca_EAGLE:SetTakeoffHot()
Larnaca_EAGLE:SetFuelLowRefuel(true)
Larnaca_EAGLE:SetFuelLowThreshold(0.3)
Larnaca_EAGLE:SetTurnoverTime(15,60)
Larnaca_AWACS:SetCallsign(CALLSIGN.Aircraft.Ford, 1)
Larnaca_EAGLE:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)

local Larnaca_MPRS = SQUADRON:New("ME TANKER KC125MPRS",2,"Larnaca AAR")
Larnaca_MPRS:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Larnaca_MPRS:SetTakeoffAir()
Larnaca_MPRS:SetFuelLowRefuel(false)
Larnaca_MPRS:SetFuelLowThreshold(0.3)
Larnaca_MPRS:SetTurnoverTime(15,60)
Larnaca_MPRS:SetCallsign(CALLSIGN.Aircraft.Texaco, 1)
Larnaca_MPRS:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)

if (aw_larnaca_cap) then
	AWLarnaca:AddSquadron(Larnaca_EAGLE)
	AWLarnaca:NewPayload(GROUP:FindByName("ME EAGLE HELLENIC"), -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
end
if (aw_larnaca_escort) then
	AWLarnaca:AddSquadron(Larnaca_HORNET)
	AWLarnaca:NewPayload(GROUP:FindByName("ME EAGLE HELLENIC"), -1, {AUFTRAG.Type.ESCORT},100)
	AWLarnaca:NewPayload(GROUP:FindByName("ME HORNET HELLENIC"), -1, {AUFTRAG.Type.ESCORT}, 80)
	AWLarnaca:NewPayload(GROUP:FindByName("ME HORNET HELLENIC AA LGHT"), -1, {AUFTRAG.Type.ESCORT}, 90)
end

AWLarnaca:AddSquadron(Larnaca_AWACS)
AWLarnaca:NewPayload(GROUP:FindByName("ME AWACS L") ,-1,{AUFTRAG.Type.ORBIT},100)

AWLarnaca:AddSquadron(Larnaca_MPRS)
AWLarnaca:NewPayload(GROUP:FindByName("ME TANKER KC125MPRS"), -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

TankerTexaco = AUFTRAG:NewTANKER(ZONE_TEXACO_AAR:GetCoordinate(), 25000, 270, 0, 20, 1)
TankerTexaco:SetTACAN(TACAN.texaco[1], TACAN.texaco[3], TACAN.texaco[2])
TankerTexaco:SetRadio(FREQUENCIES.AAR.common[1])

AWLarnaca:__Start(2)

AWLarnaca:AddMission(TankerTexaco)

if (awacs_moose) then
	-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
	AwacsOverlord = AWACS:New("Overlord", AWLarnaca, "blue", AIRBASE.Syria.Larnaca, "OVERLORD", "NEPTUNE", "ZEUS", FREQUENCIES.AWACS.overlord[1] ,radio.modulation.AM)
	AwacsOverlord:SetEscort(1)
	AwacsOverlord:SetBullsEyeAlias("APHRODITE")
	AwacsOverlord:SetAwacsDetails(CALLSIGN.AWACS.Overlord, 1, 30000, 275, 0, 20)
	AwacsOverlord:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
	AwacsOverlord:SetRejectionZone(zoneSyria)
	AwacsOverlord:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 4, 300)
	AwacsOverlord:SetModernEraAgressive()
	AwacsOverlord:DrawFEZ()

	AwacsOverlord.PlayerGuidance = true -- allow missile warning call-outs.
	AwacsOverlord.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
	AwacsOverlord.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
	AwacsOverlord.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
	AwacsOverlord.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
	AwacsOverlord.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
	if (debug_awacs) then
		AwacsOverlord.debug = true -- set to true to produce more log output.
	else
	  AwacsOverlord.debug = false
	end
	AwacsOverlord.NoMissileCalls = false -- suppress missile callouts
	AwacsOverlord.PlayerCapAssigment = true -- no task assignment for players
	AwacsOverlord.invisible = true -- set AWACS to be invisible to hostiles
	AwacsOverlord.immortal = true -- set AWACS to be immortal
	AwacsOverlord.GoogleTTSPadding = 1 -- seconds
	AwacsOverlord.WindowsTTSPadding = 2.5 -- seconds

	AwacsOverlord:__Start(5)
end