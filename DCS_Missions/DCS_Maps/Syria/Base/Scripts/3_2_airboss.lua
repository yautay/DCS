name_CVN_75 = "CVN-75"
name_CVN_75_SAR = "CVN-SAR"
name_CVN_75_AWACS = "CVN-AWACS"
name_CVN_75_TANKER = "CVN-TANKER"
name_CVN_75_RALAY_MARSHAL = "CVN-RELAY-MARSHAL"

-- S-3B Recovery Tanker
cvn_75_tanker = RECOVERYTANKER:New(UNIT:FindByName(name_CVN_75), name_CVN_75_TANKER)
cvn_75_tanker:SetSpeed(274)
cvn_75_tanker:SetAltitude(6000)
cvn_75_tanker:SetRacetrackDistances(6, 8)
cvn_75_tanker:SetRadio(FREQUENCIES.AAR.arco[1])
cvn_75_tanker:SetCallsign(CALLSIGN.Tanker.Arco)
cvn_75_tanker:SetTACAN(TACAN.arco[1], TACAN.arco[3], TACAN.arco[2])
cvn_75_tanker:SetTakeoffHot()
cvn_75_tanker:Start()

-- E-2D AWACS
cvn_75_awacs = RECOVERYTANKER:New(name_CVN_75, name_CVN_75_AWACS)
cvn_75_awacs:SetAWACS()
cvn_75_awacs:SetRadio(FREQUENCIES.AWACS.wizard[1])
cvn_75_awacs:SetAltitude(22000)
cvn_75_awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
cvn_75_awacs:SetRacetrackDistances(20, 10)
cvn_75_awacs:SetTACANoff()
cvn_75_awacs:SetTakeoffHot()
cvn_75_awacs:Start()

-- Rescue Helo
cvn_75_sar = RESCUEHELO:New(UNIT:FindByName(name_CVN_75), name_CVN_75_SAR)
cvn_75_sar:Start()

-- AIRBOSS object.
cvn_75_airboss = AIRBOSS:New(name_CVN_75)
cvn_75_airboss:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3])
cvn_75_airboss:SetICLS(ICLS.sc[1], ICLS.sc[2])
cvn_75_airboss:SetMarshalRadio(FREQUENCIES.CV.btn16[1], FREQUENCIES.CV.btn16[3])
cvn_75_airboss:SetRadioRelayMarshal(name_CVN_75_RALAY_MARSHAL)
cvn_75_airboss:SetQueueUpdateTime(30)

-- RECOVERIES C1
--local case3_1 = cvn_75_airboss:AddRecoveryWindow("04:30", "05:00", 3, 30, false, 30)
--local case2_1 = cvn_75_airboss:AddRecoveryWindow("05:30", "06:30", 2, 30, false, 30)
--local case1_1 = cvn_75_airboss:AddRecoveryWindow("07:00", "07:20", 1, nil, false, 30)
--local case1_2 = cvn_75_airboss:AddRecoveryWindow("08:00", "08:20", 1, nil, false, 30)
--local case1_3 = cvn_75_airboss:AddRecoveryWindow("09:00", "09:20", 1, nil, false, 30)
--local case1_4 = cvn_75_airboss:AddRecoveryWindow("10:00", "10:20", 1, nil, false, 30)
--local case1_5 = cvn_75_airboss:AddRecoveryWindow("11:00", "11:20", 1, nil, false, 30)
--local case1_6 = cvn_75_airboss:AddRecoveryWindow("12:00", "12:20", 1, nil, false, 30)
-- RECOVERIES C3
local case3_1 = cvn_75_airboss:AddRecoveryWindow("10:00", "15:00", 3, 30, false, 30)


-- AIRBOSS SET'UP
cvn_75_airboss:SetDefaultPlayerSkill("Naval Aviator")
cvn_75_airboss:SetMenuRecovery(30, 28, true)
cvn_75_airboss:SetDespawnOnEngineShutdown()
cvn_75_airboss:Load()
cvn_75_airboss:SetAutoSave()
cvn_75_airboss:SetTrapSheet(SHEET_PATH, nil)
cvn_75_airboss:SetHandleAION()
if SERVER then
    cvn_75_airboss:SetMPWireCorrection()
end
cvn_75_airboss:SetSoundfilesFolder("Airboss Soundfiles/")
cvn_75_airboss:SetVoiceOversMarshalByGabriella("Airboss Soundfiles/Airboss Soundpack Marshal Gabriella")
cvn_75_airboss:SetVoiceOversLSOByRaynor("Airboss Soundfiles/Airboss Soundpack LSO Raynor")
cvn_75_airboss:Start()

-- FUNKMAN INTEGRATION
--function recheck_activation_zone(args)
--    local radial = args[2]:GetRadial( 1, false, false, false )
--    local coords = args[2]:GetCoordinate()
--
--    local c1 = coords:Translate( UTILS.NMToMeters( .2 ), radial - 90 ):Translate( UTILS.NMToMeters( -.5 ), radial ) --  0.0  0.5 starboard
--    local c2 = coords:Translate( UTILS.NMToMeters( 1.5 ), radial + 90 ):Translate( UTILS.NMToMeters( -.5 ), radial ) -- -3.0  1.3 starboard, astern
--    local c3 = coords:Translate( UTILS.NMToMeters( 1.5), radial + 90 ):Translate( UTILS.NMToMeters( 3 ), radial ) -- -3.0 -0.4 port, astern
--    local c4 = coords:Translate( UTILS.NMToMeters( 1 ), radial - 90 ):Translate( UTILS.NMToMeters( 3 ), radial )
--
--    local vec2 = {c1:GetVec2(), c2:GetVec2(), c3:GetVec2(), c4:GetVec2()}
--
--    args[1]:UpdateFromVec2( vec2 )
--end
--
--function activate_em_landing_for_unit(args)
--    env.info("CUSTOM DEBUG EM LANDING - LOOP")
--    BASE:E(cvn_75_airboss:_CheckPlayerStatus())
--    --for index, value in ipairs(navy_in_air) do
--    for index, value in ipairs(NAVY_CLIENTS) do
--        local client = CLIENT:FindByName(value)
--        BASE:E(client)
--        BASE:E(client.IsAlive())
--        if client.IsAlive() then
--            env.info("CUSTOM DEBUG EM LANDING - " .. client:GetPlayer() .. " IS ALIVE!")
--            if client:IsInZone(args[1]) then
--                env.info("CUSTOM DEBUG EM LANDING - CLIENT IN ZONE")
--                local unit_alt = client:GetAltitude()
--                if unit_alt < UTILS.FeetToMeters(800) then
--                    env.info("CUSTOM unit " .. element .. " in zone " .. args[1]:GetName())
--                    args[2]:_RequestEmergency(client:GetName())
--                end
--            end
--        end
--    end
--end
--
--cvn_75_auto_activation_zone = ZONE_POLYGON_BASE:New( "CVN-75 LSO Auto Activation Zone" )
--cvn_75_auto_activation_zone:UpdateFromVec2(cvn_75_airboss:GetCoordinate():GetVec2())
--
--
--cvn_75_auto_activation_zone_mo = SCHEDULER:New( self )
--scheduler_cvn_zone_positioning = cvn_75_auto_activation_zone_mo:Schedule(self, recheck_activation_zone, {{cvn_75_auto_activation_zone, cvn_75_airboss}}, 10, 60 )
--scheduler_cvn_zone_evaluation = cvn_75_auto_activation_zone_mo:Schedule(self, activate_em_landing_for_unit, {{cvn_75_auto_activation_zone, cvn_75_airboss}}, 13, 5 )


function cvn_75_airboss:OnAfterStart(From, Event, To)
    env.info(string.format("CUSTOM ARIBOSS EVENT %S from %s to %s", Event, From, To))
end

--- Function called when a player gets graded by the LSO.
function cvn_75_airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
    local PlayerData = playerData --Ops.Airboss#AIRBOSS.PlayerData
    local Grade = grade --Ops.Airboss#AIRBOSS.LSOgrade
    local score = tonumber(Grade.points)
    local gradeLso = tostring(Grade.grade)
    local timeInGrove = tonumber(Grade.Tgroove)
    local wire = tonumber(Grade.wire)
    local name = tostring(PlayerData.name)

    ----------------------------------------
    --- Interface your Discord bot here! ---
    ----------------------------------------
    cvn_75_airboss:SetFunkManOn()
    env.info(string.format("CUSTOM CVN LSO REPORT! : Player %s scored %.1f - wire %d", name, score, wire))
end

name_LHA_1 = "LHA-1"
name_LHA_1_SAR = "LHA-SAR"
name_LHA_1_RALAY_MARSHAL = "LHA-RELAY-MARSHAL"

-- Rescue Helo
lha_1_sar = RESCUEHELO:New(UNIT:FindByName(name_LHA_1), name_LHA_1_SAR)
lha_1_sar:Start()

-- AIRBOSS object.
lha_1_airboss = AIRBOSS:New(name_LHA_1)
lha_1_airboss:SetTACAN(TACAN.lha[1], TACAN.lha[2], TACAN.lha[3])
lha_1_airboss:SetICLS(ICLS.lha[1], ICLS.lha[2])
lha_1_airboss:SetMarshalRadio(FREQUENCIES.LHA.radar[1], FREQUENCIES.LHA.radar[3])
lha_1_airboss:SetRadioRelayMarshal(name_LHA_1_RALAY_MARSHAL)
lha_1_airboss:SetQueueUpdateTime(30)
lha_1_airboss:SetDefaultPlayerSkill("Naval Aviator")
lha_1_airboss:SetMenuRecovery(30, 7, false)
lha_1_airboss:SetDespawnOnEngineShutdown()
lha_1_airboss:SetHandleAION()
lha_1_airboss:SetSoundfilesFolder("Airboss Soundfiles/")
lha_1_airboss:SetVoiceOversMarshalByRaynor("Airboss Soundfiles/Airboss Soundpack Marshal Raynor")
lha_1_airboss:SetVoiceOversLSOByFF("Airboss Soundfiles/Airboss Soundpack LSO FF")
lha_1_airboss:Start()



function lha_1_airboss:OnAfterStart(From, Event, To)
    env.info(string.format("CUSTOM ARIBOSS EVENT %S from %s to %s", Event, From, To))
end
--- Function called when a player gets graded by the LSO.
function lha_1_airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
    local PlayerData = playerData --Ops.Airboss#AIRBOSS.PlayerData
    local Grade = grade --Ops.Airboss#AIRBOSS.LSOgrade
    local score = tonumber(Grade.points)
    local gradeLso = tostring(Grade.grade)
    local timeInGrove = tonumber(Grade.Tgroove)
    local wire = tonumber(Grade.wire)
    local name = tostring(PlayerData.name)

    ----------------------------------------
    --- Interface your Discord bot here! ---
    ----------------------------------------
    lha_1_airboss:SetFunkManOn()
    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("CUSTOM LHA LSO REPORT! : Player %s scored %.1f - wire %d", name, score, wire))
end







