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
                if (string.find(mission:GetName(), "East")) then
                    index = 1
                elseif (string.find(mission:GetName(), "Center")) then
                    index = 2
                elseif (string.find(mission:GetName(), "West")) then
                    index = 3
                end
        
            elseif (mission.refuelSystem == 0) then --boom
                callsign = CALLSIGN.Tanker.Texaco
                if (string.find(mission:GetName(), "East")) then
                    index = 1
                elseif (string.find(mission:GetName(), "West")) then
                    index = 2
                end
            end
            
            env.info(string.format("TANKER PLATFORM UPDATE %s -> %s-%d", unit_alive:GetName(), callsign, index))
            unit_alive:CommandSetCallsign(callsign, index, 1)
            
            unit_beacon = unit_alive:GetBeacon()
        
            if (mission.refuelSystem == 1) then --probe
                if (string.find(mission:GetName(), "East")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_e[1], FREQUENCIES.TACAN.shell_e[2], FREQUENCIES.TACAN.shell_e[3], false)
                elseif (string.find(mission:GetName(), "Center")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_c[1], FREQUENCIES.TACAN.shell_c[2], FREQUENCIES.TACAN.shell_c[3], false)
                elseif (string.find(mission:GetName(), "West")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_w[1], FREQUENCIES.TACAN.shell_w[2], FREQUENCIES.TACAN.shell_w[3], false)
                end
        
            elseif (mission.refuelSystem == 0) then --boom
                if (string.find(mission:GetName(), "East")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.texaco_e[1], FREQUENCIES.TACAN.texaco_e[2], FREQUENCIES.TACAN.texaco_e[3], false)
                elseif (string.find(mission:GetName(), "West")) then
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.texaco_w[1], FREQUENCIES.TACAN.texaco_w[2], FREQUENCIES.TACAN.texaco_w[3], false)
                end
            end 
            

        end
    end
end

if (aw_vaziani) then
    tanker_platform_updater(AWVaziani)
end
if (aw_kutaisi) then
    tanker_platform_updater(AWKutaisi)
end
