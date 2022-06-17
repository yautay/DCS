
-- ###########################################################
-- ###                  Vaziani Air Wing                   ###
-- ###########################################################
ZONE_CHICAGO_CAP = ZONE:New("CHICAGO")
ZONE_HOUSTON_FEZ = ZONE:New("HOUSTON")
ZONE_ATLANTA_AWACS = ZONE:New("ATLANTA")
ZONE_SHELL_EAST_AAR = ZONE:New("SHELL EAST")
ZONE_TEXACO_EAST_AAR = ZONE:New("TEXACO EAST")

AWVaziani = AIRWING:New("WH VAZIANI", "Vaziani Air Wing")

if (debug_aw_vaziani) then
	function AWVaziani:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWVaziani:SetMarker(false)
AWVaziani:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Vaziani))
AWVaziani:SetRespawnAfterDestroyed(600)


Vaziani_AWACS = SQUADRON:New("ME AWACS E3",2,"AWACS Vaziani")
Vaziani_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Vaziani_AWACS:SetTakeoffAir()
Vaziani_AWACS:SetFuelLowRefuel(false)
Vaziani_AWACS:SetFuelLowThreshold(0.25)
Vaziani_AWACS:SetTurnoverTime(30,180)
Vaziani_AWACS:SetCallsign(CALLSIGN.Aircraft.Darkstar, 1)
Vaziani_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_AWACS)
AWVaziani:NewPayload("ME AWACS E3" ,-1,{AUFTRAG.Type.ORBIT},100)

Vaziani_MPRS = SQUADRON:New("ME TANKER KC135MPRS",2,"AAR MPRS Vaziani")
Vaziani_MPRS:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Vaziani_MPRS:SetTakeoffAir()
Vaziani_MPRS:SetFuelLowRefuel(false)
Vaziani_MPRS:SetFuelLowThreshold(0.25)
Vaziani_MPRS:SetTurnoverTime(15,60)
Vaziani_MPRS:SetCallsign(CALLSIGN.Aircraft.Shell, 1)
Vaziani_MPRS:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_MPRS)
AWVaziani:NewPayload("ME TANKER KC135MPRS", -1, {AUFTRAG.Type.TANKER},100)

Vaziani_135 = SQUADRON:New("ME AAR KC135",2,"AAR 135 Vaziani")
Vaziani_135:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Vaziani_135:SetTakeoffAir()
Vaziani_135:SetFuelLowRefuel(false)
Vaziani_135:SetFuelLowThreshold(0.25)
Vaziani_135:SetTurnoverTime(15,60)
Vaziani_135:SetCallsign(CALLSIGN.Aircraft.Texaco, 1)
Vaziani_135:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_135)
AWVaziani:NewPayload("ME AAR KC135", -1, {AUFTRAG.Type.TANKER},100)

TankerShellEast = AUFTRAG:NewTANKER(ZONE_SHELL_EAST_AAR:GetCoordinate(), 25000, 320, 100, 40, 0)
TankerShellEast:AssignSquadrons({Vaziani_135})
TankerShellEast:SetTACAN(TACAN.shell_e[1], TACAN.shell_e[3], TACAN.shell_e[2])
TankerShellEast:SetRadio(FREQUENCIES.AAR.common[1])
AWVaziani:AddMission(TankerShellEast)

TankerTexacoEast = AUFTRAG:NewTANKER(ZONE_TEXACO_EAST_AAR:GetCoordinate(), 22000, 310, 100, 40, 1)
TankerTexacoEast:AssignSquadrons({Vaziani_MPRS})
TankerTexacoEast:SetTACAN(TACAN.texaco_e[1], TACAN.texaco_e[3], TACAN.texaco_e[2])
TankerTexacoEast:SetRadio(FREQUENCIES.AAR.common[1])
AWVaziani:AddMission(TankerTexacoEast)


if (aw_vaziani_cap or aw_vaziani_escort) then
	Vaziani_F5 = SQUADRON:New("ME F5",12,"F5 Vaziani")
	Vaziani_F5:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
	Vaziani_F5:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 50)
	Vaziani_F5:SetTakeoffHot()
	Vaziani_F5:SetFuelLowRefuel(true)
	Vaziani_F5:SetFuelLowThreshold(0.3)
	Vaziani_F5:SetTurnoverTime(10,60)
	Vaziani_F5:SetCallsign(CALLSIGN.Aircraft.Ford, 1)
	Vaziani_F5:SetTakeoffHot()
	Vaziani_F5:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
	AWVaziani:AddSquadron(Vaziani_F5)
	if (aw_vaziani_cap) then
		AWVaziani:NewPayload("ME F5", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
	end
	if (aw_vaziani_escort) then
		AWVaziani:NewPayload("ME F5", -1, {AUFTRAG.Type.ESCORT},100)
	end
end

AWVaziani:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AwacsDarkstar = AWACS:New("Darkstar", AWVaziani, "blue", AIRBASE.Caucasus.Vaziani, "ATLANTA", "HOUSTON", "CHICAGO", FREQUENCIES.AWACS.darkstar[1] ,radio.modulation.AM)
if (aw_vaziani_escort) then
	AwacsDarkstar:SetEscort(1)
end
AwacsDarkstar:SetBullsEyeAlias("TEXAS")
AwacsDarkstar:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, 30000, 220, 120, 20)
AwacsDarkstar:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
if (moose_awacs_rejection_red_zone) then
	AwacsDarkstar:SetRejectionZone(borderRed)
end
AwacsDarkstar:SetAdditionalZone(borderBlue)
AwacsDarkstar:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 2, 300)
AwacsDarkstar:SetModernEraAgressive()

AwacsDarkstar.PlayerGuidance = true -- allow missile warning call-outs.
AwacsDarkstar.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AwacsDarkstar.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AwacsDarkstar.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AwacsDarkstar.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AwacsDarkstar.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AwacsDarkstar.NoMissileCalls = false -- suppress missile callouts
AwacsDarkstar.PlayerCapAssigment = true -- no task assignment for players
AwacsDarkstar.invisible = true -- set AWACS to be invisible to hostiles
AwacsDarkstar.immortal = true -- set AWACS to be immortal
AwacsDarkstar.GoogleTTSPadding = 1 -- seconds
AwacsDarkstar.WindowsTTSPadding = 2.5 -- seconds

AwacsDarkstar:__Start(5)

if (debug_awacs) then
	AwacsDarkstar.debug = true -- set to true to produce more log output.
else
  	AwacsDarkstar.debug = false
end