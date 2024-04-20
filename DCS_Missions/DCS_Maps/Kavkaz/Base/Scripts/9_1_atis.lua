AtisAG1651= ATIS:New(BASES.SENAKI, FREQUENCIES_MAP.GROUND.atis_ag1651[1])
AtisAG1651:SetRadioRelayUnitName("AG1651 Relay")
AtisAG1651:SetTowerFrequencies({FREQUENCIES_MAP.GROUND.twr_ag1651_1[1], FREQUENCIES_MAP.GROUND.twr_ag1651_2[1], FREQUENCIES_MAP.GROUND.twr_ag1651_3[1]})
AtisAG1651:AddILS(108.90, "09")
AtisAG1651:SetTACAN(31)
AtisAG1651:SetSRS(SRS_PATH, "female", "en-US")
AtisAG1651:SetMapMarks()
AtisAG1651:SetTransmitOnlyWithPlayers(true)
AtisAG1651:ReportZuluTimeOnly()
AtisAG1651:Start()

function getAtisData(atisObject)
    local atis_msg={}
    atis_msg.command=HELPERS.SOCKET_NOTAM
    atis_msg.server_name="Nygus Server"
    atis_msg.text="\n\n" .. string.upper(atisObject:GetSRSText()) .. "\n\n"
--     if (atis_msg.text) then
--         socketBot:SendTable(atis_msg)
--     end
end

SchedulerLCRAMasterObject = SCHEDULER:New( AtisAG1651 )
SchedulerLCRA = SchedulerLCRAMasterObject:Schedule( AtisAG1651, getAtisData, {AtisAG1651}, 75)
