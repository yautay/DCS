function getNotam(atisObject)
    local name = atisObject.airbasename
    saveToFile(SHEET_PATH .. "\\NOTAM-ATIS-" .. string.upper(name), string.upper(atisObject:GetSRSText()))
end

AtisSENAKI= ATIS:New(AIRBASE.Caucasus.Senaki_Kolkhi, FREQUENCIES_MAP.GROUND.atis_senaki[1])
AtisSENAKI:SetRadioRelayUnitName("Senaki Relay")
AtisSENAKI:SetTowerFrequencies({FREQUENCIES_MAP.GROUND.twr_senaki_1[1], FREQUENCIES_MAP.GROUND.twr_senaki_2[1], FREQUENCIES_MAP.GROUND.twr_senaki_3[1]})
AtisSENAKI:AddILS(108.90, "09")
AtisSENAKI:SetTACAN(31)
AtisSENAKI:SetSRS(SRS_PATH, "female", "en-US")
AtisSENAKI:SetMapMarks(false)
AtisSENAKI:SetTransmitOnlyWithPlayers(true)
AtisSENAKI:ReportZuluTimeOnly()
AtisSENAKI:Start()

SchedulerSenakiMasterObject = SCHEDULER:New( AtisSENAKI )
SchedulerSenaki = SchedulerSenakiMasterObject:Schedule( AtisSENAKI, getNotam, {AtisSENAKI}, 120)

ATC_SENAKI=FLIGHTCONTROL:New(AIRBASE.Caucasus.Senaki_Kolkhi, {FREQUENCIES_MAP.GROUND.twr_senaki_1[1], FREQUENCIES_MAP.GROUND.twr_senaki_2[1], FREQUENCIES_MAP.GROUND.twr_senaki_3[1]}, radio.modulation.AM, SRS_PATH)
ATC_SENAKI:SetSpeedLimitTaxi(30)
ATC_SENAKI:SetParkingGuardStatic("TEMPLATE_STATIC_ops_gnd")
ATC_SENAKI:SetLimitTaxi(4, false, 2)
ATC_SENAKI:SetLimitLanding(4, 99)
ATC_SENAKI:SetATIS(AtisSENAKI)
ATC_SENAKI:Start()
