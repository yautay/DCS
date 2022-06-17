
-- ###########################################################
-- ###              Ramat David Air Wing                   ###
-- ###########################################################
ZONE_ISSAC_CAP = ZONE:New("ISSAC")
ZONE_DAVID_FEZ = ZONE:New("DAVID")
ZONE_DARKSTAR_AWACS = ZONE:New("DARKSTAR")
ZONE_SHELL_AAR = ZONE:New("SHELL")

AWRamatDavid = AIRWING:New("WH Ramat David", "Ramat David Air Wing")

if (debug_aw_ramat) then
	function AWRamatDavid:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWRamatDavid:SetMarker(false)
AWRamatDavid:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Ramat_David))
AWRamatDavid:SetRespawnAfterDestroyed(600)


local Ramat_AWACS = SQUADRON:New("ME AWACS S", 2, "AWACS Ramat")
Ramat_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Ramat_AWACS:SetTakeoffAir()
Ramat_AWACS:SetFuelLowRefuel(true)
Ramat_AWACS:SetFuelLowThreshold(0.3)
Ramat_AWACS:SetTurnoverTime(30,180)
Ramat_AWACS:SetCallsign(CALLSIGN.Aircraft.Darkstar, 1)
Ramat_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)

local Ramat_VIPER = SQUADRON:New("ME VIPER IDF",8,"Fighters Ramat")
Ramat_VIPER:AddMissionCapability({AUFTRAG.Type.ESCORT}, 100)
Ramat_VIPER:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 100)
Ramat_VIPER:SetTakeoffHot()
Ramat_VIPER:SetFuelLowRefuel(true)
Ramat_VIPER:SetFuelLowThreshold(0.3)
Ramat_VIPER:SetTurnoverTime(10,60)
Ramat_VIPER:SetCallsign(CALLSIGN.Aircraft.Uzi, 1)
Ramat_VIPER:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)

local Ramat_KC130 = SQUADRON:New("ME TANKER KC130", 2, "Ramat AAR")
Ramat_KC130:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Ramat_KC130:SetTakeoffAir()
Ramat_KC130:SetFuelLowRefuel(false)
Ramat_KC130:SetFuelLowThreshold(0.3)
Ramat_KC130:SetTurnoverTime(15,60)
Ramat_KC130:SetCallsign(CALLSIGN.Aircraft.Shell, 1)
Ramat_KC130:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)

AWRamatDavid:AddSquadron(Ramat_VIPER)

if (aw_ramat_cap) then
	AWRamatDavid:NewPayload("ME VIPER IDF", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
end

if (aw_ramat_escort) then
	AWRamatDavid:NewPayload("ME VIPER IDF", -1, {AUFTRAG.Type.ESCORT},100)
end

AWRamatDavid:AddSquadron(Ramat_AWACS)
AWRamatDavid:NewPayload("ME AWACS S" ,-1,{AUFTRAG.Type.ORBIT},100)

AWRamatDavid:AddSquadron(Ramat_KC130)
AWRamatDavid:NewPayload("ME TANKER KC130", -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

TankerShell = AUFTRAG:NewTANKER(ZONE_SHELL_AAR:GetCoordinate(), 25000, 270, 105, 40, 1)
TankerShell:SetTACAN(TACAN.shell[1], TACAN.shell[3], TACAN.shell[2])
TankerShell:SetRadio(FREQUENCIES.AAR.common[1])

AWRamatDavid:__Start(2)

AWRamatDavid:AddMission(TankerShell)

if (awacs_moose) then
	-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
	AwacsDarkstar = AWACS:New("Darkstar", AWRamatDavid, "blue", AIRBASE.Syria.Ramat_David, "DARKSTAR", "DAVID", "ISSAC", FREQUENCIES.AWACS.darkstar[1] ,radio.modulation.AM)
	AwacsDarkstar:SetEscort(1)
	AwacsDarkstar:SetBullsEyeAlias("REBECCA")
	AwacsDarkstar:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, 22000, 275, 90, 20)
	AwacsDarkstar:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
	AwacsDarkstar:SetRejectionZone(zoneSyria)
	AwacsDarkstar:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 4, 300)
	AwacsDarkstar:SetModernEraDefensive()
	AwacsDarkstar:DrawFEZ()

	AwacsDarkstar.PlayerGuidance = true -- allow missile warning call-outs.
	AwacsDarkstar.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
	AwacsDarkstar.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
	AwacsDarkstar.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
	AwacsDarkstar.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
	AwacsDarkstar.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
	if (debug_awacs) then
		AwacsDarkstar.debug = true -- set to true to produce more log output.
	else
	  	AwacsDarkstar.debug = false
	end
	AwacsDarkstar.NoMissileCalls = false -- suppress missile callouts
	AwacsDarkstar.PlayerCapAssigment = true -- no task assignment for players
	AwacsDarkstar.invisible = true -- set AWACS to be invisible to hostiles
	AwacsDarkstar.immortal = true -- set AWACS to be immortal
	AwacsDarkstar.GoogleTTSPadding = 1 -- seconds
	AwacsDarkstar.WindowsTTSPadding = 2.5 -- seconds

	AwacsDarkstar:__Start(5)
end