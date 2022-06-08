local debug_airbos = false

-- ###########################################################
-- ###                      BLUE CV                        ###
-- ###########################################################

-- F10 Map Markings

ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)

-- S-3B Recovery Tanker
tanker = RECOVERYTANKER:New(UNIT:FindByName("CV"), "CV AAR")
tanker:SetAltitude(6000)
tanker:SetSpeed(274)
tanker:SetRacetrackDistances(12, 6)
tanker:SetRadio(FREQUENCIES.AAR.arco[1])
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:SetTACAN(TACAN.arco[1], TACAN.arco[3])
tanker:Start()

-- E-2D AWACS
awacs = RECOVERYTANKER:New("CV", "CV AWACS")
awacs:SetAWACS()
awacs:SetRadio(FREQUENCIES.AWACS.wizard[1])
awacs:SetAltitude(25000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetTACAN(2, "WIZ")
awacs:SetRacetrackDistances(20, 8)
awacs:Start()

-- Rescue Helo
rescuehelo = RESCUEHELO:New(UNIT:FindByName("CV"), "CV SAR")
rescuehelo:Start()

-- AIRBOSS object.
Airboss = AIRBOSS:New("CV")
Airboss:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3])
Airboss:SetICLS(ICLS.sc[1], ICLS.sc[2])
Airboss:SetMarshalRadio(FREQUENCIES.CV.marshal[1], FREQUENCIES.CV.marshal[3])
Airboss:SetRadioRelayMarshal("Marshal relay")
Airboss:SetLSORadio(FREQUENCIES.CV.lso[1])
Airboss:SetRadioRelayLSO("LSO relay")
Airboss:SetQueueUpdateTime(10)

local window1 = Airboss:AddRecoveryWindow("5:00", "19:00", 1, nil, true, 25)
-- local window2 = Airboss:AddRecoveryWindow("19:00", "20:00", 2, nil, true, 25)
-- local window3 = Airboss:AddRecoveryWindow("20:00", "06:00+1", 3, nil, true, 25)

Airboss:SetSoundfilesFolder("Airboss Soundfiles")
Airboss:SetMenuSingleCarrier()
Airboss:SetDefaultPlayerSkill("Naval Aviator")
Airboss:SetMenuRecovery(30, 25, false)
Airboss:SetDespawnOnEngineShutdown()
Airboss:Load()
Airboss:SetAutoSave()
Airboss:SetTrapSheet()

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

    ----------------------------------------
    --- Interface your Discord bot here! ---
    ----------------------------------------

    local score = tonumber(Grade.points)
    local gradeLso = tostring(Grade.grade)
    local timeInGrove = tonumber(Grade.Tgroove)
    local wire = tonumber(Grade.wire)
    local name = tostring(PlayerData.name)

    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("CUSTOM: Player %s scored %.1f", name, score))
end