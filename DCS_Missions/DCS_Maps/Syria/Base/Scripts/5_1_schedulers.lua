function tanker_platform_updater(airwing)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup = FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission = Mission --Ops.Auftrag#AUFTRAG
        local callsign = "nil"
        local index = 99

        if (mission:GetType() == AUFTRAG.Type.TANKER) then
            env.info("CUSTOM BEACON UPDATE - TANKERS")
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive()
            local unit_beacon = unit_alive:GetBeacon()

            if (mission.refuelSystem == 1) then
                -- garden hose
                callsign = "SHELL"
                if (string.find(mission:GetName(), "One")) then
                    index = 1
                    env.info(string.format("CUSTOM BEACON UPDATE ON %s ", mission:GetName()))
                    unit_beacon:ActivateTACAN(TACAN.shell_1[1], TACAN.shell_1[2], TACAN.shell_1[3], TACAN.shell_1[5])
                elseif (string.find(mission:GetName(), "Two")) then
                    index = 2
                    env.info(string.format("CUSTOM BEACON UPDATE ON %s ", mission:GetName()))
                    unit_beacon:ActivateTACAN(TACAN.shell_2[1], TACAN.shell_2[2], TACAN.shell_2[3], TACAN.shell_2[5])
                --elseif (string.find(mission:GetName(), "Three")) then
                --    index = 3
                --    unit_beacon:ActivateTACAN(TACAN.shell_3[1], TACAN.shell_3[2], TACAN.shell_3[3], TACAN.shell_3[5])
                end

            elseif (mission.refuelSystem == 0) then
                -- broom stick
                callsign = "TEXACO"
                if (string.find(mission:GetName(), "One")) then
                    index = 1
                    env.info(string.format("CUSTOM BEACON UPDATE ON %s ", mission:GetName()))
                    unit_beacon:ActivateTACAN(TACAN.texaco_1[1], TACAN.texaco_1[2], TACAN.texaco_1[3], TACAN.texaco_1[5])
            --    elseif (string.find(mission:GetName(), "Two")) then
            --        index = 2
            --        unit_beacon:ActivateTACAN(TACAN.texaco_2[1], TACAN.texaco_2[2], TACAN.texaco_2[3], TACAN.texaco_2[5])
                end
            end
            env.info(string.format("CUSTOM TANKER PLATFORM UPDATE %s -> %s-%d", unit_alive:GetName(), callsign, index))
            unit_alive:CommandSetCallsign(callsign, index, 1)
        end
    end
end

--tanker_platform_updater(AW_LCRA)
--tanker_platform_updater(AW_LCLK)
