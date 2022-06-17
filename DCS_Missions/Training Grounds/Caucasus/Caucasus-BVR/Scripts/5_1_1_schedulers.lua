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

if (elint) then
    if (aw_vaziani) then
        elint_platform_updater(HoundBlue, AWVaziani, "Vaziani")
    end
    if (aw_kutaisi) then
        elint_platform_updater(HoundBlue, AWKutaisi, "Kutaisi")
    end
end
   
-- HoundScheduler = SCHEDULER:New(nil, platform_update,{}, 10, 10)
