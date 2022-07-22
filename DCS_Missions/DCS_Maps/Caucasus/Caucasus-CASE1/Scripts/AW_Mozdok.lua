-- ###########################################################
-- ###                  Mozdok Air Wing                   ###
-- ###########################################################

AWMozdok = AIRWING:New("WH MOZDOK", "Mozdok Air Wing")

if (debug_aw_mozdok) then
	function AWMozdok:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWMozdok:SetMarker(false)
AWMozdok:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Mozdok))
AWMozdok:SetRespawnAfterDestroyed(600)

Mozdok_AWACS = SQUADRON:New("ME RED AWACS",2,"AWACS Mozdok")
Mozdok_AWACS:AddMissionCapability({AUFTRAG.Type.AWACS},100)
Mozdok_AWACS:SetTakeoffAir()
Mozdok_AWACS:SetFuelLowRefuel(false)
Mozdok_AWACS:SetFuelLowThreshold(0.25)
Mozdok_AWACS:SetTurnoverTime(30,180)
-- Mozdok_AWACS:SetCallsign(CALLSIGN.Aircraft.Darkstar, 1)
-- Mozdok_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWMozdok:AddSquadron(Mozdok_AWACS)
AWMozdok:NewPayload("ME RED AWACS" ,-1,{AUFTRAG.Type.AWACS},100)

Mozdok_27 = SQUADRON:New("ME RED 27 27ER",8,"F5 Mozdok")
Mozdok_27:AddMissionCapability({AUFTRAG.Type.ESCORT}, 100)
Mozdok_27:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 100)
Mozdok_27:SetTakeoffHot()
Mozdok_27:SetFuelLowRefuel(true)
Mozdok_27:SetFuelLowThreshold(0.3)
Mozdok_27:SetTurnoverTime(10,60)
-- Mozdok_27:SetCallsign(CALLSIGN.Aircraft.Ford, 1)
Mozdok_27:SetTakeoffHot()
-- Mozdok_27:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)

AWMozdok:AddSquadron(Mozdok_27)
AWMozdok:NewPayload("ME RED 27 27ER", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)

AWMozdok:__Start(2)
