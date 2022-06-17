
-- ###########################################################
-- ###                  Kutaisi Air Wing                   ###
-- ###########################################################
ZONE_BERLIN_CAP = ZONE:New("BERLIN")
ZONE_PARIS_FEZ = ZONE:New("PARIS")
ZONE_WARSAW_AWACS = ZONE:New("WARSAW")
ZONE_SHELL_WEST_AAR = ZONE:New("SHELL WEST")
ZONE_TEXACO_WEST_AAR = ZONE:New("TEXACO WEST")

AWKutaisi = AIRWING:New("WH KUTAISI", "Kutaisi Air Wing")

if (debug_aw_kutaisi) then
	function AWKutaisi:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWKutaisi:SetMarker(false)
AWKutaisi:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
AWKutaisi:SetRespawnAfterDestroyed(600)


Kutaisi_AWACS = SQUADRON:New("ME AWACS E3",2,"AWACS Kutaisi")
Kutaisi_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Kutaisi_AWACS:SetTakeoffAir()
Kutaisi_AWACS:SetFuelLowRefuel(false)
Kutaisi_AWACS:SetFuelLowThreshold(0.25)
Kutaisi_AWACS:SetTurnoverTime(30,180)
Kutaisi_AWACS:SetCallsign(CALLSIGN.Aircraft.Overlord, 1)
Kutaisi_AWACS:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_AWACS)
AWKutaisi:NewPayload("ME AWACS E3" ,-1,{AUFTRAG.Type.ORBIT},100)

Kutaisi_MPRS = SQUADRON:New("ME TANKER KC135MPRS",2,"AAR MPRS Kutaisi")
Kutaisi_MPRS:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Kutaisi_MPRS:SetTakeoffAir()
Kutaisi_MPRS:SetFuelLowRefuel(false)
Kutaisi_MPRS:SetFuelLowThreshold(0.25)
Kutaisi_MPRS:SetTurnoverTime(15,60)
Kutaisi_MPRS:SetCallsign(CALLSIGN.Aircraft.Shell, 2)
Kutaisi_MPRS:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_MPRS)
AWKutaisi:NewPayload("ME TANKER KC135MPRS", -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

Kutaisi_135 = SQUADRON:New("ME AAR KC135",2,"AAR 135 Kutaisi")
Kutaisi_135:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Kutaisi_135:SetTakeoffAir()
Kutaisi_135:SetFuelLowRefuel(false)
Kutaisi_135:SetFuelLowThreshold(0.25)
Kutaisi_135:SetTurnoverTime(15,60)
Kutaisi_135:SetCallsign(CALLSIGN.Aircraft.Texaco, 2)
Kutaisi_135:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_135)
AWKutaisi:NewPayload("ME AAR KC135", -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

TankerShellWest = AUFTRAG:NewTANKER(ZONE_SHELL_WEST_AAR:GetCoordinate(), 25000, 320, 100, 40, 0)
TankerShellWest:AssignSquadrons({Kutaisi_135})
TankerShellWest:SetTACAN(TACAN.shell_w[1], TACAN.shell_w[3], TACAN.shell_w[2])
TankerShellWest:SetRadio(FREQUENCIES.AAR.common[1])
AWKutaisi:AddMission(TankerShellWest)

TankerTexacoWest = AUFTRAG:NewTANKER(ZONE_TEXACO_WEST_AAR:GetCoordinate(), 22000, 310, 100, 40, 1)
TankerTexacoWest:AssignSquadrons({Kutaisi_MPRS})
TankerTexacoWest:SetTACAN(TACAN.texaco_w[1], TACAN.texaco_w[3], TACAN.texaco_w[2])
TankerTexacoWest:SetRadio(FREQUENCIES.AAR.common[1])
AWKutaisi:AddMission(TankerTexacoWest)


if (aw_kutaisi_cap or aw_kutaisi_escort) then
	Kutaisi_SU27 = SQUADRON:New("ME SU27",12,"SU27 Vaziani")
	Kutaisi_SU27:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
	Kutaisi_SU27:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 50)
	Kutaisi_SU27:SetTakeoffHot()
	Kutaisi_SU27:SetFuelLowRefuel(true)
	Kutaisi_SU27:SetFuelLowThreshold(0.3)
	Kutaisi_SU27:SetTurnoverTime(10,60)
	Kutaisi_SU27:SetCallsign(CALLSIGN.Aircraft.Ford, 2)
	Kutaisi_SU27:SetTakeoffHot()
	Kutaisi_SU27:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)
	AWKutaisi:AddSquadron(Kutaisi_SU27)
	if (aw_kutaisi_cap) then
		AWKutaisi:NewPayload("ME SU27", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
	end
	if (aw_kutaisi_escort) then
		AWKutaisi:NewPayload("ME SU27", -1, {AUFTRAG.Type.ESCORT},100)
	end
end

AWKutaisi:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AwacsOverlord = AWACS:New("Overlord", AWKutaisi, "blue", AIRBASE.Caucasus.Kutaisi, "WARSAW", "PARIS", "BERLIN", FREQUENCIES.AWACS.overlord[1] ,radio.modulation.AM)
if (aw_kutaisi_escort) then
	AwacsOverlord:SetEscort(1)
end
AwacsOverlord:SetBullsEyeAlias("TEXAS")
AwacsOverlord:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, 30000, 220, 120, 20)
AwacsOverlord:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
if (moose_awacs_rejection_red_zone) then
	AwacsOverlord:SetRejectionZone(borderRed)
end
AwacsOverlord:SetAdditionalZone(borderBlue, true)
AwacsOverlord:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 2, 300)
AwacsOverlord:SetModernEraAgressive()

AwacsOverlord.PlayerGuidance = true -- allow missile warning call-outs.
AwacsOverlord.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AwacsOverlord.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AwacsOverlord.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AwacsOverlord.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AwacsOverlord.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AwacsOverlord.NoMissileCalls = false -- suppress missile callouts
AwacsOverlord.PlayerCapAssigment = true -- no task assignment for players
AwacsOverlord.invisible = true -- set AWACS to be invisible to hostiles
AwacsOverlord.immortal = true -- set AWACS to be immortal
AwacsOverlord.GoogleTTSPadding = 1 -- seconds
AwacsOverlord.WindowsTTSPadding = 2.5 -- seconds

AwacsOverlord:__Start(5)

if (debug_awacs) then
	AwacsOverlord.debug = true -- set to true to produce more log output.
else
  	AwacsOverlord.debug = false
end