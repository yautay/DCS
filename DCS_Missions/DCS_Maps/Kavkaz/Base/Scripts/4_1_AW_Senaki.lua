function getNotam(atisObject)
    local name = atisObject.airbasename
    saveToFile(SHEET_PATH .. "\\NOTAM-ATIS-" .. string.upper(name), string.upper(atisObject:GetSRSText()))
end

AtisAG1651= ATIS:New(BASES.Senaki_Kolkhi, FREQUENCIES_MAP.GROUND.atis_ag1651[1])
AtisAG1651:SetRadioRelayUnitName("AG1651 Relay")
AtisAG1651:SetTowerFrequencies({FREQUENCIES_MAP.GROUND.twr_ag1651_1[1], FREQUENCIES_MAP.GROUND.twr_ag1651_2[1], FREQUENCIES_MAP.GROUND.twr_ag1651_3[1]})
AtisAG1651:AddILS(108.90, "09")
AtisAG1651:SetTACAN(31)
AtisAG1651:SetSRS(SRS_PATH, "female", "en-US")
AtisAG1651:SetMapMarks()
AtisAG1651:SetTransmitOnlyWithPlayers(true)
AtisAG1651:ReportZuluTimeOnly()
AtisAG1651:Start()

SchedulerAG1651MasterObject = SCHEDULER:New( AtisAG1651 )
SchedulerAG1651 = SchedulerAG1651MasterObject:Schedule( AtisAG1651, getNotam, {AtisAG1651}, 5)

ATC_SENAKI=FLIGHTCONTROL:New(BASES.Senaki_Kolkhi, {FREQUENCIES_MAP.GROUND.twr_ag1651_1[1], FREQUENCIES_MAP.GROUND.twr_ag1651_2[1], FREQUENCIES_MAP.GROUND.twr_ag1651_3[1]}, radio.modulation.AM, SRS_PATH)
ATC_SENAKI:SetVerbosity(2)
ATC_SENAKI:SetParkingGuardStatic("StaticGuard")
ATC_SENAKI:SetSpeedLimitTaxi(25)
ATC_SENAKI:SetLimitTaxi(3, false, 1)
ATC_SENAKI:SetLimitLanding(2, 99)
-- FLIGHTCONTROL.AddHoldingPattern(ArrivalZone, Heading, Length, FlightlevelMin, FlightlevelMax, Prio)
ATC_SENAKI:AddHoldingPattern(ZONE:New("Senaki Holding Alpha"), 090, 3, 2, 12, 10)
ATC_SENAKI:AddHoldingPattern(ZONE:New("Senaki Holding Bravo"), 270, 3, 2, 12, 20)
ATC_SENAKI:SetATIS(AtisAG1651)
-- Start the ATC.
ATC_SENAKI:Start()

ZONE_PATROL = ZONE:New("SENAKI_PATROL_CAP")
ZONE_ENGAGE = ZONE:New("GCI_ENGAGE_ZONE")

AW_Senaki = AIRWING:New("WH Senaki", "Senaki Air Wing")

AW_Senaki:SetMarker(true)
AW_Senaki:SetAirbase(AIRBASE:FindByName(BASES.Senaki_Kolkhi))
AW_Senaki:SetRespawnAfterDestroyed(600)
AW_Senaki:__Start(2)

--function AWACS:New(Name,AirWing,Coalition,AirbaseName,AwacsOrbit,OpsZone,StationZone,Frequency,Modulation)
GCI_SENAKI = AWACS:New("GCI Senaki",AW_Senaki,"blue",BASES.Senaki_Kolkhi,nil,ZONE_ENGAGE,"GCI_ENGAGE_ZONE",FREQUENCIES.GCI.GCI_SENAKI[1], radio.modulation.AM)
GCI_SENAKI:SetAsGCI(GROUP:FindByName("EWR Senaki"),2)
GCI_SENAKI:SetBullsEyeAlias("BULLS")
GCI_SENAKI:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
GCI_SENAKI:SetPolicingWW2()

GCI_SENAKI.PlayerGuidance = false -- allow missile warning call-outs.
GCI_SENAKI.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
GCI_SENAKI.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
GCI_SENAKI.DeclareRadius = 3 -- you need to be this close to the lead unit for declare/VID to work, in NM.
GCI_SENAKI.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
GCI_SENAKI.maxassigndistance = 200 -- Don't assign targets further out than this, in NM.
GCI_SENAKI.NoMissileCalls = true -- suppress missile callouts
GCI_SENAKI.PlayerCapAssigment = true -- no task assignment for players
GCI_SENAKI.invisible = true -- set AWACS to be invisible to hostiles
GCI_SENAKI.immortal = true -- set AWACS to be immortal
GCI_SENAKI.GoogleTTSPadding = 1 -- seconds
GCI_SENAKI.WindowsTTSPadding = 2.5 -- seconds

GCI_SENAKI:SuppressScreenMessages(false)
GCI_SENAKI:__Start(2)
