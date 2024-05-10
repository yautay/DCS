function getNotam(atisObject)
    local name = atisObject.airbasename
    saveToFile(SHEET_PATH .. "\\NOTAM-ATIS-" .. string.upper(name), string.upper(atisObject:GetSRSText()))
end

AtisSENAKI= ATIS:New(BASES.Senaki_Kolkhi, FREQUENCIES_MAP.GROUND.atis_senaki[1])
AtisSENAKI:SetRadioRelayUnitName("AG1651 Relay")
AtisSENAKI:SetTowerFrequencies({FREQUENCIES_MAP.GROUND.twr_senaki_1[1], FREQUENCIES_MAP.GROUND.twr_senaki_2[1], FREQUENCIES_MAP.GROUND.twr_senaki_3[1]})
AtisSENAKI:AddILS(108.90, "09")
AtisSENAKI:SetTACAN(31)
AtisSENAKI:SetSRS(SRS_PATH, "female", "en-US")
AtisSENAKI:SetMapMarks()
AtisSENAKI:SetTransmitOnlyWithPlayers(true)
AtisSENAKI:ReportZuluTimeOnly()
AtisSENAKI:Start()

SchedulerSenakiMasterObject = SCHEDULER:New( AtisSENAKI )
SchedulerSenaki = SchedulerSenakiMasterObject:Schedule( AtisSENAKI, getNotam, {AtisSENAKI}, 5)

ATC_SENAKI=FLIGHTCONTROL:New(BASES.Senaki_Kolkhi, {FREQUENCIES_MAP.GROUND.twr_senaki_1[1], FREQUENCIES_MAP.GROUND.twr_senaki_2[1], FREQUENCIES_MAP.GROUND.twr_senaki_3[1]}, radio.modulation.AM, SRS_PATH)
ATC_SENAKI:SetSpeedLimitTaxi(25)
ATC_SENAKI:SetLimitTaxi(6, false, 2)
ATC_SENAKI:SetLimitLanding(4, 99)
ATC_SENAKI:SetATIS(AtisSENAKI)
ATC_SENAKI:Start()
