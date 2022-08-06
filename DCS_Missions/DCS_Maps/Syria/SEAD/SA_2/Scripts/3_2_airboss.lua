
-- S-3B Recovery Tanker
cvn73_tanker = RECOVERYTANKER:New(UNIT:FindByName("CVN 73"), "CVN TANKER")
cvn73_tanker:SetSpeed(274)
cvn73_tanker:SetAltitude(6000)
cvn73_tanker:SetRacetrackDistances(6, 8)
cvn73_tanker:SetRadio(FREQUENCIES.AAR.arco[1])
cvn73_tanker:SetCallsign(CALLSIGN.Tanker.Arco)
cvn73_tanker:SetTACANoff()
cvn73_tanker:Start()

-- E-2D AWACS_cv
if (cvn_awacs) then
    awacs_cv = RECOVERYTANKER:New("CVN 73", "CVN AWACS")
    awacs_cv:SetAWACS()
    awacs_cv:SetRadio(FREQUENCIES.AWACS.wizard[1])
    awacs_cv:SetAltitude(22000)
    awacs_cv:SetCallsign(CALLSIGN.AWACS.Wizard)
    awacs_cv:SetRacetrackDistances(20, 10)
    awacs_cv:SetTACANoff()
    awacs_cv:Start()
end

-- Rescue Helo
rescuehelo = RESCUEHELO:New(UNIT:FindByName("CVN 73"), "CVN SAR")
rescuehelo:Start()

-- AIRBOSS object.
Airboss = AIRBOSS:New("CSG 73")
Airboss:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3])
Airboss:SetICLS(ICLS.sc[1], ICLS.sc[2])
Airboss:SetMarshalRadio(FREQUENCIES.CV.marshal[1], FREQUENCIES.CV.marshal[3])
-- Airboss:SetRadioRelayMarshal("RELAY-CVN-MARSHAL")
Airboss:SetLSORadio(FREQUENCIES.CV.lso[1])
-- Airboss:SetRadioRelayLSO("RELAY-CVN-LSO")
Airboss:SetQueueUpdateTime(10)

local window1 = Airboss:AddRecoveryWindow("01:00", "06:00", 3, nil, true, 25)
-- local window2 = Airboss:AddRecoveryWindow("19:00", "20:00", 2, nil, true, 25)
-- local window3 = Airboss:AddRecoveryWindow("20:00", "06:00+1", 3, nil, true, 25)

-- Airboss:SetSoundfilesFolder("Airboss Soundfiles")
Airboss:SetMenuSingleCarrier()
Airboss:SetDefaultPlayerSkill("Naval Aviator")
Airboss:SetMenuRecovery(30, 25, false)
Airboss:SetDespawnOnEngineShutdown()
Airboss:Load()
Airboss:SetAutoSave()
Airboss:SetTrapSheet()
Airboss:SetHandleAIOFF()
Airboss:Start()

if (debug_airbos) then
    env.info("CUSTOM Airboss DEBUG ON!")
    BASE:TraceOnOff(true)
    BASE:TraceLevel(3)
    BASE:TraceClass("AIRBOSS")
    Airboss:SetDebugModeON()
end

--- Function called when a player gets graded by the LSO.
function Airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
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