
-- ###########################################################
-- ###                  Larnaca Air Wing                   ###
-- ###########################################################
ZONE_NORFOLK_CAP = ZONE:New("NORFOLK")
ZONE_HOUSTON_FEZ = ZONE:New("HOUSTON")
ZONE_WIZZARD_AWACS = ZONE:New("ATLANTA")

AWCVN = AIRWING:New("CVN", "CVN Air Wing")

if (debug_aw_cvn) then
	function AWLarnaca:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWCVN:SetMarker(false)
AWCVN:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Larnaca))
AWCVN:SetRespawnAfterDestroyed(600)
AWCVN:SetAirboss(Airboss)

local CVN_AWACS = SQUADRON:New("ME CV AWACS", 2, "AWACS CVN")
CVN_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT}, 100)
CVN_AWACS:SetTakeoffAir()
CVN_AWACS:SetFuelLowRefuel(false)
CVN_AWACS:SetFuelLowThreshold(0.3)
CVN_AWACS:SetTurnoverTime(30, 180)
CVN_AWACS:SetCallsign(CALLSIGN.Aircraft.Wizard, 1)
CVN_AWACS:SetRadio(FREQUENCIES.AWACS.wizard[1], radio.modulation.AM)

local CVN_HORNET = SQUADRON:New("ME HORNET CV AA LGHT", 12, "AWACS Larnaca Escort")
CVN_HORNET:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
CVN_HORNET:AddMissionCapability({AUFTRAG.Type.CAP}, 50)
CVN_HORNET:SetTakeoffHot()
CVN_HORNET:SetFuelLowRefuel(true)
CVN_HORNET:SetFuelLowThreshold(0.3)
CVN_HORNET:SetTurnoverTime(10, 60)
CVN_HORNET:SetCallsign(CALLSIGN.Aircraft.Ford, 2)
CVN_HORNET:SetTakeoffHot()
CVN_HORNET:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)

AWCVN:AddSquadron(CVN_HORNET)

if (aw_cvn_cap) then
	AWCVN:NewPayload("ME HORNET CV AA LGHT", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 100)
end

if (aw_cvn_escort) then
	AWCVN:NewPayload("ME HORNET CV AA LGHT", -1, {AUFTRAG.Type.ESCORT}, 100)
end

AWCVN:AddSquadron(CVN_AWACS)
AWCVN:NewPayload("ME CV AWACS", -1, {AUFTRAG.Type.ORBIT}, 100)

AWCVN:__Start(2)

if (awacs_moose) then
	-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
	AwacsWizard = AWACS:New("Wizard", AWCVN, "blue", "CVN", "ATLANTA", "HOUSTON", "NORFOLK", FREQUENCIES.AWACS.wizard[1] ,radio.modulation.AM)
	AwacsWizard:SetEscort(1)
	AwacsWizard:SetBullsEyeAlias("HOUSTON")
	AwacsWizard:SetAwacsDetails(CALLSIGN.AWACS.Wizard, 1, 20000, 220, 0, 15)
	AwacsWizard:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
	AwacsWizard:SetRejectionZone(zoneSyria)
	AwacsWizard:SetAICAPDetails(CALLSIGN.Aircraft.Colt, 2, 4, 300)
	AwacsWizard:SetModernEraAgressive()
	AwacsWizard:DrawFEZ()

	AwacsWizard.PlayerGuidance = true -- allow missile warning call-outs.
	AwacsWizard.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
	AwacsWizard.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
	AwacsWizard.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
	AwacsWizard.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
	AwacsWizard.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
	if (debug_awacs) then
		AwacsWizard.debug = true -- set to true to produce more log output.
	else
	 	AwacsWizard.debug = false
	end
	AwacsWizard.NoMissileCalls = false -- suppress missile callouts
	AwacsWizard.PlayerCapAssigment = true -- no task assignment for players
	AwacsWizard.invisible = true -- set AWACS to be invisible to hostiles
	AwacsWizard.immortal = true -- set AWACS to be immortal
	AwacsWizard.GoogleTTSPadding = 1 -- seconds
	AwacsWizard.WindowsTTSPadding = 2.5 -- seconds

	AwacsWizard:__Start(10)
end