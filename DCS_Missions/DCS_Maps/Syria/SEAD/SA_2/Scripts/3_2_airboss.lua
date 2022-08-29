
-- S-3B Recovery Tanker
cvn73_tanker = RECOVERYTANKER:New(UNIT:FindByName("CVN 73"), "CVN TANKER")
cvn73_tanker:SetSpeed(274)
cvn73_tanker:SetAltitude(6000)
cvn73_tanker:SetRacetrackDistances(6, 8)
cvn73_tanker:SetRadio(FREQUENCIES.AAR.arco[1])
cvn73_tanker:SetCallsign(CALLSIGN.Tanker.Arco)
cvn73_tanker:SetTACANoff()
cvn73_tanker:SetTakeoffHot()
cvn73_tanker:Start()

function cvn73_tanker:OnAfterStart(From, Event, To)
    env.info(string.format("RECOVERY TANKER EVENT %S from %s to %s", Event, From, To))
    local unit = UNIT:FindByName(cvn73_tanker:GetUnit())
    local beacon = unit:GetBeacon()
    beacon:ActivateTACAN(TACAN.arco[1], TACAN.arco[2], TACAN.arco[3], TACAN.arco[5])
end

-- E-2D AWACS
cvn73_awacs = RECOVERYTANKER:New("CVN 73", "CVN AWACS")
cvn73_awacs:SetAWACS()
cvn73_awacs:SetRadio(FREQUENCIES.AWACS.wizard[1])
cvn73_awacs:SetAltitude(22000)
cvn73_awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
cvn73_awacs:SetRacetrackDistances(20, 10)
cvn73_awacs:SetTACANoff()
cvn73_awacs:SetTakeoffHot()
cvn73_awacs:Start()

-- Rescue Helo
cvn73_sar = RESCUEHELO:New(UNIT:FindByName("CVN 73"), "CVN SAR")
cvn73_sar:Start()

-- AIRBOSS object.
cvn_73_airboss = AIRBOSS:New("CVN 73")
cvn_73_airboss:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3])
cvn_73_airboss:SetICLS(ICLS.sc[1], ICLS.sc[2])
cvn_73_airboss:SetMarshalRadio(FREQUENCIES.CV.marshal[1], FREQUENCIES.CV.marshal[3])
cvn_73_airboss:SetRadioRelayMarshal("RELAY-CVN-MARSHAL")
cvn_73_airboss:SetQueueUpdateTime(20)

local case1 = cvn_73_airboss:AddRecoveryWindow("18:17", "19:00", 1, nil, true, 25)
local case2_2 = cvn_73_airboss:AddRecoveryWindow("19:05", "19:30", 2, nil, true, 25)
local case3 = cvn_73_airboss:AddRecoveryWindow("19:45", "05:30+1", 3, 30, true, 25)
local case2_1 = cvn_73_airboss:AddRecoveryWindow("05:35+1", "06:30+1", 2, nil, true, 25)
local case1_2 = cvn_73_airboss:AddRecoveryWindow("06:35+1", "19:00+1", 1, nil, true, 25)

-- cvn_73_airboss:SetSoundfilesFolder("Airboss Soundfiles")
cvn_73_airboss:SetMenuSingleCarrier()
cvn_73_airboss:SetDefaultPlayerSkill("Naval Aviator")
cvn_73_airboss:SetMenuRecovery(30, 25, false)
cvn_73_airboss:SetDespawnOnEngineShutdown()
cvn_73_airboss:Load()
cvn_73_airboss:SetAutoSave()
cvn_73_airboss:SetTrapSheet()
cvn_73_airboss:SetHandleAION()
cvn_73_airboss:Start()

function cvn_73_airboss:OnAfterStart(From, Event, To)
    env.info(string.format("ARIBOSS EVENT %S from %s to %s", Event, From, To))
end

--- Function called when a player gets graded by the LSO.
function cvn_73_airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
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

    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("CUSTOM: Player %s scored %.1f", name, score))
end
