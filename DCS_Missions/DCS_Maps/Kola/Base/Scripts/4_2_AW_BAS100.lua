function getNotam(atisObject)
    local name = atisObject.airbasename
    saveToFile(SHEET_PATH .. "\\NOTAM-ATIS-" .. string.upper(name), string.upper(atisObject:GetSRSText()))
end

AtisBAS100= ATIS:New("Bas_100", VAR_KOLA.FREQUENCIES.MAP.BAS100.atis[1])
AtisBAS100:SetRadioRelayUnitName("BAS100 Relay")
AtisBAS100:SetTowerFrequencies({VAR_KOLA.FREQUENCIES.MAP.BAS100.twr_1[1], VAR_KOLA.FREQUENCIES.MAP.BAS100.twr_2[1], VAR_KOLA.FREQUENCIES.MAP.BAS100.twr_3[1]})
AtisBAS100:SetTACAN(27)
AtisBAS100:SetSRS(SRS_PATH, "female", "en-US")
AtisBAS100:SetMapMarks()
AtisBAS100:SetTransmitOnlyWithPlayers(true)
AtisBAS100:ReportZuluTimeOnly()
AtisBAS100:Start()

SchedulerBAS100MasterObject = SCHEDULER:New( AtisBAS100 )
SchedulerBAS100 = SchedulerBAS100MasterObject:Schedule( AtisBAS100, getNotam, {AtisBAS100}, 5)

ATC_EFRO=FLIGHTCONTROL:New("Bas_100", {VAR_KOLA.FREQUENCIES.MAP.BAS100.twr_1[1], VAR_KOLA.FREQUENCIES.MAP.BAS100.twr_2[1], VAR_KOLA.FREQUENCIES.MAP.BAS100.twr_3[1]}, radio.modulation.AM, SRS_PATH)
ATC_EFRO:SetVerbosity(2)
ATC_EFRO:SetParkingGuardStatic("StaticGuard")
ATC_EFRO:SetSpeedLimitTaxi(25)
ATC_EFRO:SetLimitTaxi(3, false, 1)
ATC_EFRO:SetLimitLanding(2, 99)
-- FLIGHTCONTROL.AddHoldingPattern(ArrivalZone, Heading, Length, FlightlevelMin, FlightlevelMax, Prio)
ATC_EFRO:AddHoldingPattern(ZONE:New("BAS100 Holding Alpha"), 270, 5, 6, 18, 10)
ATC_EFRO:SetATIS(AtisBAS100)
-- Start the ATC.
ATC_EFRO:Start()
