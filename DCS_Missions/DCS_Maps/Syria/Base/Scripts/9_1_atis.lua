AtisLCRA= ATIS:New(AIRBASE.Syria.Akrotiri, FREQUENCIES.GROUND.atis_lcra[1])
AtisLCRA:SetRadioRelayUnitName("LCRA Relay")
AtisLCRA:SetTowerFrequencies({FREQUENCIES.GROUND.twr_lcra_v[1], FREQUENCIES.GROUND.twr_lcra_u[1]})
AtisLCRA:AddILS(109.70, "29")
AtisLCRA:AddNDBinner(365.00)
AtisLCRA:SetSRS(SRS_PATH, "female", "en-US")
AtisLCRA:SetMapMarks()
AtisLCRA:SetTransmitOnlyWithPlayers(Switch)
AtisLCRA:Start()

function getAtisData(atisObject)
    local atis_data =  atisObject:GetSRSText()
    if (atis_data) then
        socketBot:SendText(atis_data)
    end
end

SchedulerLCRAMasterObject = SCHEDULER:New( AtisLCRA )
SchedulerLCRA = SchedulerLCRAMasterObject:Schedule( AtisLCRA, getAtisData, {AtisLCRA}, 120)
