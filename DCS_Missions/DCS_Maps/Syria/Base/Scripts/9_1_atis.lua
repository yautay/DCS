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
    local atis_msg={}
    atis_msg.command=HELPERS.SOCKET_NOTAM
    atis_msg.server_name="Nygus Server"
    atis_msg.text="\n\n" .. string.upper(atisObject:GetSRSText()) .. "\n\n"
    if (atis_msg.text) then
        socketBot:SendTable(atis_msg)
    end
end

SchedulerLCRAMasterObject = SCHEDULER:New( AtisLCRA )
SchedulerLCRA = SchedulerLCRAMasterObject:Schedule( AtisLCRA, getAtisData, {AtisLCRA}, 120)
