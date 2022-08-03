function tanker_platform_updater(airwing)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)

        local flightgroup = FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission = Mission --Ops.Auftrag#AUFTRAG
        local callsign = "nil"
        local index = 99

        if (mission:GetType() == AUFTRAG.Type.TANKER) then
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive()
            local unit_beacon = unit_alive:GetBeacon()

            if (mission.refuelSystem == 1) then
                -- garden hose
                callsign = CALLSIGN.Tanker.Shell
                if (string.find(mission:GetName(), "One")) then
                    index = 1
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_1[1], FREQUENCIES.TACAN.shell_1[2], FREQUENCIES.TACAN.shell_1[3], FREQUENCIES.TACAN.shell_1[5])
                elseif (string.find(mission:GetName(), "Two")) then
                    index = 2
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_2[1], FREQUENCIES.TACAN.shell_2[2], FREQUENCIES.TACAN.shell_2[3], FREQUENCIES.TACAN.shell_2[5])
                elseif (string.find(mission:GetName(), "Three")) then
                    index = 3
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.shell_3[1], FREQUENCIES.TACAN.shell_3[2], FREQUENCIES.TACAN.shell_3[3], FREQUENCIES.TACAN.shell_3[5])
                end

            elseif (mission.refuelSystem == 0) then
                -- broom stick
                callsign = CALLSIGN.Tanker.Texaco
                if (string.find(mission:GetName(), "One")) then
                    index = 1
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.texaco_1[1], FREQUENCIES.TACAN.texaco_1[2], FREQUENCIES.TACAN.texaco_1[3], FREQUENCIES.TACAN.texaco_1[5])
                elseif (string.find(mission:GetName(), "Two")) then
                    index = 2
                    unit_beacon:ActivateTACAN(FREQUENCIES.TACAN.texaco_2[1], FREQUENCIES.TACAN.texaco_2[2], FREQUENCIES.TACAN.texaco_2[3], FREQUENCIES.TACAN.texaco_2[5])
                end
            end
            env.info(string.format("TANKER PLATFORM UPDATE %s -> %s-%d", unit_alive:GetName(), callsign, index))
            unit_alive:CommandSetCallsign(callsign, index, 1)
        end
    end
end

if (aw_ramat_david) then
    tanker_platform_updater(AW_LLRD)
end

