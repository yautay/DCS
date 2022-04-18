_SETTINGS:SetPlayerMenuOff()

local frequencies = frequencies()
local tacans = tacans()
local icls = icls()

-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- BLUE Aux. flights
Tanker_Shell =
    SPAWN:New("Tanker 70Y Shell"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(shell_11)
        shell_11:EnRouteTaskTanker()
        shell_11:CommandSetCallsign(3, 1)
        shell_11:CommandSetFrequency(frequencies.freq_aar[1])
    end
):InitRepeatOnLanding()
Tanker_Texaco =
    SPAWN:New("Tanker 71Y Texaco"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(texaco_11)
        texaco_11:EnRouteTaskTanker()
        texaco_11:CommandSetCallsign(1, 1)
        texaco_11:CommandSetFrequency(frequencies.freq_aar[1])
    end
):InitRepeatOnLanding()
AWACS_Overlord =
    SPAWN:New("EW-AWACS-1"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(overlord_11)
        overlord_11:EnRouteTaskAWACS()
        overlord_11:CommandSetCallsign(1, 1)
        overlord_11:CommandSetFrequency(frequencies.freq_awacs[1])
    end
):InitRepeatOnLanding()

-- F10 Map Markings
ZONE:New("TKR-1-1"):GetCoordinate(0):LineToAll(ZONE:New("TKR-1-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 2, true, "SHELL")
ZONE:New("TKR-2"):GetCoordinate(0):CircleToAll(7500, -1, {0, 0, 1}, 1, {0, 0, 1}, .3, 2, true, "TEXACO")
ZONE:New("AWACS-1"):GetCoordinate(0):CircleToAll(7500, -1, {0, 0, 1}, 1, {0, 0, 1}, .3, 2, true, "OVERLORD")

-- SAMs
--BLUE_SAM_1 = SPAWN:New("BLUE-SAM-01"):InitLimit(20, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_SAM_SUKHUMI = SPAWN:New("Sukhumi-SAM"):InitLimit(13, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_MANTIS = MANTIS:New("BLUE_MANTIS", "BLUE-SAM", "EW-AWACS", nil, coalition.side.BLUE, false):Start()

-- ###########################################################
-- ###                      BLUE CV                        ###
-- ###########################################################

-- F10 Map Markings

ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)
ZONE_POLYGON:New("CV-1-Area", GROUP:FindByName("helper_cv_stennis")):DrawZone(-1, {0, 0, 1}, 1, {0, 0, 1}, 0.4, 2)

-- S-3B Recovery Tanker
tanker = RECOVERYTANKER:New("USS Theodore Roosevelt", "USS Theodore Roosevelt AAR")
tanker:SetTakeoffHot()
tanker:SetRadio(frequencies.freq_aar[1])
tanker:SetModex(511)
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:SetTACAN(tacans.tacan_arco[1], tacans.tacan_arco[2], tacans.tacan_arco[3])
tanker:__Start(1)

-- E-2D AWACS
awacs = RECOVERYTANKER:New("USS Theodore Roosevelt", "USS Theodore Roosevelt AWACS")
awacs:SetAWACS()
awacs:SetRadio(frequencies.freq_awacs[1])
awacs:SetAltitude(20000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(15, 15)
awacs:SetModex(611)
awacs:__Start(1)

-- Rescue Helo
rescuehelo = RESCUEHELO:New("USS Theodore Roosevelt", "USS Theodore Roosevelt SAR")
rescuehelo:SetModex(42)
rescuehelo:__Start(1)

-- AIRBOSS object.
AirbossStennis = AIRBOSS:New("USS Theodore Roosevelt")
AirbossStennis:SetTACAN(tacans.tacan_sc[1], tacans.tacan_sc[2], tacans.tacan_sc[3]):SetICLS(
    icls.icls_sc[1],
    icls.icls_sc[2]
)
AirbossStennis:SetMarshalRadio(freq_marshal, "AM"):SetLSORadio(freq_lso, "AM")

local window1 = AirbossStennis:AddRecoveryWindow("6:00", "19:00", 1, nil, true, 25)
local window2 = AirbossStennis:AddRecoveryWindow("19:00", "20:00", 2, nil, true, 25)
local window3 = AirbossStennis:AddRecoveryWindow("20:00", "06:00", 3, nil, true, 25)

AirbossStennis:SetMenuSingleCarrier()
AirbossStennis:SetMenuRecovery(30, 25, false)
AirbossStennis:SetDespawnOnEngineShutdown()
AirbossStennis:Load()
AirbossStennis:SetAutoSave()
AirbossStennis:SetTrapSheet()
AirbossStennis:Start()
AirbossStennis:SetHandleAIOFF()

--- Function called when recovery tanker is started.
function tanker:OnAfterStart(From, Event, To)
    AirbossStennis:SetRecoveryTanker(tanker)
    AirbossStennis:SetRadioRelayLSO(self:GetUnitName())
end

--- Function called when AWACS is started.
function awacs:OnAfterStart(From, Event, To)
    AirbossStennis:SetAWACS(awacs)
end

--- Function called when rescue helo is started.
function rescuehelo:OnAfterStart(From, Event, To)
    AirbossStennis:SetRadioRelayMarshal(self:GetUnitName())
end

--- Function called when a player gets graded by the LSO.
function AirbossStennis:OnAfterLSOGrade(From, Event, To, playerData, grade)
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
    env.info(string.format("Player %s scored %.1f", name, score))
end
