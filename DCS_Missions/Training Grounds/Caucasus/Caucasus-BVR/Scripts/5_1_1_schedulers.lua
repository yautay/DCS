function elint_platform_updater(hound_object, airwing, sector_name)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission=Mission --Ops.Auftrag#AUFTRAG
        if (mission:GetType() == AUFTRAG.Type.ORBIT) then
            env.info("ELINT PLATFORM UPDATE")
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive():GetName()
            env.info(string.format("Adding platform %s", unit_alive))
            hound_object:addPlatform(unit_alive)
            hound_object:setTransmitter(sector_name, unit_alive)
            function flightgroup:OnAfterFuelLow(From, Event, To)
                env.info(string.format("Removing platform %s", unit_alive))
                hound_object:removePlatform (unit_alive)  
            end
        end
    end
end
function tanker_platform_updater(airwing)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission=Mission --Ops.Auftrag#AUFTRAG
        local callsign = "nil"
        local index = 99
        if (mission:GetType() == AUFTRAG.Type.TANKER) then
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive()
            if (mission.refuelSystem == 1) then --probe
                callsign = CALLSIGN.Tanker.Shell
            elseif (mission.refuelSystem == 0) then --boom
                callsign = CALLSIGN.Tanker.Texaco
            end
            if (string.find(mission:GetName(), "East")) then
                index = 1
            elseif (string.find(mission:GetName(), "West")) then
                index = 2
            end
            env.info(string.format("TANKER PLATFORM UPDATE %s -> %s-%d", unit_alive:GetName(), callsign, index))
            unit_alive:CommandSetCallsign(callsign, index, 1)
        end
    end
end

if (elint) then
    if (aw_vaziani) then
        elint_platform_updater(HoundBlue, AWVaziani, "Vaziani")
    end
    if (aw_kutaisi) then
        elint_platform_updater(HoundBlue, AWKutaisi, "Kutaisi")
    end
end
if (aw_vaziani) then
    tanker_platform_updater(AWVaziani)
end
if (aw_kutaisi) then
    tanker_platform_updater(AWKutaisi)
end

-- HoundScheduler = SCHEDULER:New(nil, platform_update,{}, 10, 10)
