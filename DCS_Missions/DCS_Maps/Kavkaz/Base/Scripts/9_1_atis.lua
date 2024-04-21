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
