_SETTINGS:SetPlayerMenuOff()

-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- BLUE Aux. flights
Tanker_Shell =
    SPAWN:New("Tanker Shell"):InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
    function(shell_11)
        shell_11:EnRouteTaskTanker()
        shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1, 1)
        shell_11:CommandSetFrequency(FREQUENCIES.AAR.common[1])
        local beacon = shell_11:GetBeacon()
        beacon:ActivateTACAN(TACAN.shell[1], TACAN.shell[2], TACAN.shell[3], true)
    end
):InitRepeatOnLanding()
Tanker_Texaco =
    SPAWN:New("Tanker Texaco"):InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
    function(texaco_11)
        texaco_11:EnRouteTaskTanker()
        texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1, 1)
        texaco_11:CommandSetFrequency(FREQUENCIES.AAR.common[1])
        local beacon = texaco_11:GetBeacon()
        beacon:ActivateTACAN(TACAN.texaco[1], TACAN.texaco[2], TACAN.texaco[3], true)
    end
):InitRepeatOnLanding()
AWACS_Darkstar =
    SPAWN:New("AWACS Kish"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(darkstar_11)
        darkstar_11:EnRouteTaskAWACS()
        darkstar_11:CommandSetCallsign(CALLSIGN.AWACS.Darkstar, 1, 1)
        darkstar_11:CommandSetFrequency(FREQUENCIES.AWACS.darkstar[1])
    end
):InitRepeatOnLanding()
AWACS_Overlord =
    SPAWN:New("AWACS Hormuz"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(overlord_11)
        overlord_11:EnRouteTaskAWACS()
        overlord_11:CommandSetCallsign(CALLSIGN.AWACS.Overlord, 1, 1)
        overlord_11:CommandSetFrequency(FREQUENCIES.AWACS.overlord[1])
    end
):InitRepeatOnLanding()

-- ###########################################################
-- ###                      BLUE CV                        ###
-- ###########################################################

-- F10 Map Markings

ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)

-- S-3B Recovery Tanker
local tanker = RECOVERYTANKER:New(UNIT:FindByName("USS Theodore Roosevelt"), "USS Theodore Roosevelt AAR")
tanker:SetTakeoffAir()
tanker:SetRadio(FREQUENCIES.AAR.arco[1])
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:SetTACAN(TACAN.arco[1], TACAN.arco[3])
tanker:Start()

-- E-2D AWACS
local awacs = RECOVERYTANKER:New("USS Theodore Roosevelt", "USS Theodore Roosevelt AWACS")
awacs:SetTakeoffAir()
awacs:SetAWACS()
awacs:SetRadio(FREQUENCIES.AWACS.wizard[1])
awacs:SetAltitude(25000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(15, 15)
awacs:Start()

-- Rescue Helo
local rescuehelo = RESCUEHELO:New(UNIT:FindByName("USS Theodore Roosevelt"), "USS Theodore Roosevelt SAR")
rescuehelo:SetTakeoffAir()
rescuehelo:Start()

-- AIRBOSS object.
AirbossStennis = AIRBOSS:New("USS Theodore Roosevelt")
AirbossStennis:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3]):SetICLS(ICLS.sc[1], ICLS.sc[2])
AirbossStennis:SetMarshalRadio(FREQUENCIES.CV.marshal[1], FREQUENCIES.CV.marshal[3]):SetLSORadio(
    FREQUENCIES.CV.lso[3],
    FREQUENCIES.CV.lso[3]
)

local window1 = AirbossStennis:AddRecoveryWindow("5:00", "19:00", 1, nil, true, 25)
local window2 = AirbossStennis:AddRecoveryWindow("19:00", "20:00", 2, nil, true, 25)
local window3 = AirbossStennis:AddRecoveryWindow("20:00", "06:00+1", 3, nil, true, 25)

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

-- ###########################################################
-- ###                      CHROME                         ###
-- ###########################################################

atisDubai=ATIS:New(AIRBASE.PersianGulf.Dubai_Intl, 131.7)
atisDubai:SetRadioRelayUnitName("ELINT South")
atisDubai:SetMetricUnits()
atisDubai:SetActiveRunway("R")

atisDubai:Start()

atisMinhad=ATIS:New(AIRBASE.PersianGulf.Al_Minhad_AB, FREQUENCIES.GROUND.al_minhad_atis[1])
atisMinhad:SetRadioRelayUnitName("ELINT South")
atisMinhad:SetTACAN(99)
atisMinhad:SetTowerFrequencies({FREQUENCIES.GROUND.al_minhad_hi[1], FREQUENCIES.GROUND.al_minhad_lo[1]})
atisMinhad:AddILS(110.70, "09")
atisMinhad:AddILS(110.75, "27")
atisMinhad:SetSRS("C:\\DCS-SimpleRadio-Standalone", "female", "en-US")
atisMinhad:SetMapMarks()
atisMinhad:Start()
