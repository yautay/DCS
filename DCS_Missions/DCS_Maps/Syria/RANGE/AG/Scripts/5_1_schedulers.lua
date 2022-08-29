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
                    unit_beacon:ActivateTACAN(TACAN.shell_1[1], TACAN.shell_1[2], TACAN.shell_1[3], TACAN.shell_1[5])
                elseif (string.find(mission:GetName(), "Two")) then
                    index = 2
                    unit_beacon:ActivateTACAN(TACAN.shell_2[1], TACAN.shell_2[2], TACAN.shell_2[3], TACAN.shell_2[5])
                elseif (string.find(mission:GetName(), "Three")) then
                    index = 3
                    unit_beacon:ActivateTACAN(TACAN.shell_3[1], TACAN.shell_3[2], TACAN.shell_3[3], TACAN.shell_3[5])
                end

            elseif (mission.refuelSystem == 0) then
                -- broom stick
                callsign = CALLSIGN.Tanker.Texaco
                if (string.find(mission:GetName(), "One")) then
                    index = 1
                    unit_beacon:ActivateTACAN(TACAN.texaco_1[1], TACAN.texaco_1[2], TACAN.texaco_1[3], TACAN.texaco_1[5])
                elseif (string.find(mission:GetName(), "Two")) then
                    index = 2
                    unit_beacon:ActivateTACAN(TACAN.texaco_2[1], TACAN.texaco_2[2], TACAN.texaco_2[3], TACAN.texaco_2[5])
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

function skynet_update(reference_object, iads_object)
    --SAM UNITS
    for k, v in pairs(reference_object) do
        local sam = iads_object:addSAMSite(v["sam_name"])
        for ig, vg in pairs(v["generators"]) do
            sam:addPowerSource(Unit.getByName(vg:GetName()))
            sam:addPowerSource(StaticObject.getByName(vg:GetName()))
        end
        for il, vl in pairs(v["links"]) do
            sam:addConnectionNode(Unit.getByName(vl:GetName()))
            sam:addConnectionNode(StaticObject.getByName(vl:GetName()))
        end
    end
    --EWR's
    redIADS:addEarlyWarningRadarsByPrefix('EWR')

    --CC
    local cc = redIADS:addCommandCenter(StaticObject.getByName("Command Center"))
    cc:addConnectionNode(StaticObject.getByName("CC CON 1"))
    cc:addConnectionNode(StaticObject.getByName("CC CON 2"))
    --local iadsDebug = redIADS:getDebugSettings()
    --iadsDebug.IADSStatus = true
    --iadsDebug.contacts = true
    --iadsDebug.jammerProbability = true
    --
    --iadsDebug.addedEWRadar = true
    --iadsDebug.addedSAMSite = true
    --iadsDebug.warnings = true
    --iadsDebug.radarWentLive = true
    --iadsDebug.radarWentDark = true
    --iadsDebug.harmDefence = true
    --
    --iadsDebug.samSiteStatusEnvOutput = true
    --iadsDebug.earlyWarningRadarStatusEnvOutput = true
    --iadsDebug.commandCenterStatusEnvOutput = true
    redIADS:activate()
end

SkynetScheduler = SCHEDULER:New(nil, skynet_update, { sam_alive_data , redIADS}, 10)




