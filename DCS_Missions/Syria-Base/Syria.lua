local freq_awacs = 251
local freq_aar = 251
local freq_lso = 264
local freq_marshal = 305


-- _SETTINGS:SetPlayerMenuOff()

-- ###########################################################
-- ###                  DISCORD BOT                        ###
-- ###########################################################

--DO NOT EDIT
function repl(dirty)
    local text =
        dirty:gsub("&", ""):gsub('"', ""):gsub("|", " "):gsub("'", ""):gsub("%%", ""):gsub("/", ""):gsub("\\", ""):gsub(
        ">",
        ""
    )
    local clean = text:gsub("<", "")
    return clean
end

function BotSay(msg)
    local message = repl(msg)
    local text =
        'C:\\DiscordSendWebhook.exe -m "' ..
        message ..
            '" -w "https://discord.com/api/webhooks/955109086117113866/6j7q16ckXUXXZ25bIqnp9-q9mAZAHiYQ8RDxjZ_7VjOkDJ0XXwTWVEzWR29hzgXhKlNE"'
    os.execute(text)
end

--SAMPLE MISSION START EVENT
MS = EVENTHANDLER:New()
MS:HandleEvent(EVENTS.MissionStart)

function MS:OnEventMissionStart(EventData) 
  local txt= "Mission started " .. "\n freqs:" .. "\nAWACS: " .. freq_awacs .. "\nAAR:" .. freq_aar .. "\nMARSHAL:" .. freq_marshal .. "\nLSO:" .. freq_marshal 
BotSay(txt)
end


-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- BLUE Aux. flights
Tanker_Shell =
    SPAWN:New("Tanker 70Y Shell"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(shell_11)
        shell_11:CommandSetCallsign(1, 0)
        shell_11:CommandSetFrequency(freq_aar)
    end
):InitRepeatOnLanding()
Tanker_Texaco =
    SPAWN:New("Tanker 71Y Texaco"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(texaco_11)
        texaco_11:CommandSetCallsign(1, 0)
        texaco_11:CommandSetFrequency(freq_aar)
    end
):InitRepeatOnLanding()
AWACS_Overlord =
    SPAWN:New("EW-AWACS-1"):InitLimit(1, 0):SpawnScheduled(60, .1):OnSpawnGroup(
    function(overlord_11)
        overlord_11:CommandSetCallsign(1, 0)
        overlord_11:CommandSetFrequency(freq_awacs)
    end
):InitRepeatOnLanding()

-- F10 Map Markings
ZONE:New("TKR-1-1"):GetCoordinate(0):LineToAll(ZONE:New("TKR-1-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 2, true, "SHELL")
ZONE:New("TKR-2"):GetCoordinate(0):CircleToAll(7500, -1, {0, 0, 1}, 1, {0, 0, 1}, .3, 2, true, "TEXACO")
ZONE:New("AWACS-1"):GetCoordinate(0):CircleToAll(7500, -1, {0, 0, 1}, 1, {0, 0, 1}, .3, 2, true, "TEXACO")

-- SAMs
--BLUE_SAM_1 = SPAWN:New("BLUE-SAM-01"):InitLimit(20, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_SAM_SUKHUMI = SPAWN:New("Sukhumi-SAM"):InitLimit(13, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_MANTIS = MANTIS:New("BLUE_MANTIS", "BLUE-SAM", "EW-AWACS", nil, coalition.side.BLUE, false):Start()

-- ###########################################################
-- ###                      BLUE CV                        ###
-- ###########################################################

-- F10 Map Markings

ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)
ZONE:New("CV-2"):GetCoordinate(0):LineToAll(ZONE:New("CV-3"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)
ZONE_POLYGON:New("CV-1-Area", GROUP:FindByName("helper_cv_stennis")):DrawZone(-1, {0, 0, 1}, 1, {0, 0, 1}, 0.4, 2)

-- S-3B Recovery Tanker.
-- ARCO 250.00 1->"TRK" A6 250KIAS
tanker = RECOVERYTANKER:New("USS Stennis", "USS Stennis AAR")
tanker:SetTakeoffHot()
tanker:SetRadio(freq_aar)
tanker:SetModex(511)
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:SetTACAN(1, "Y", "TKR")
tanker:__Start(1)

-- E-2D AWACS spawning on Stennis.
-- Wizard 260.00 A20
awacs = RECOVERYTANKER:New("USS Stennis", "USS Stennis AWACS")
awacs:SetAWACS()
awacs:SetRadio(freq_awacs)
awacs:SetAltitude(20000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(15, 15)
awacs:SetModex(611)
awacs:__Start(1)

-- Rescue Helo spawning on Stennis.
rescuehelo = RESCUEHELO:New("USS Stennis", "USS Stennis SAR")
rescuehelo:SetModex(42)
rescuehelo:__Start(1)

-- Create AIRBOSS object.
AirbossStennis = AIRBOSS:New("USS Stennis")
AirbossStennis:SetTACAN(74, "X", "STN"):SetICLS(1, "STN")
AirbossStennis:SetMarshalRadio(freq_marshal, "AM"):SetLSORadio(freq_lso, "AM")

-- Add recovery windows:
-- Case I from 9 to 10 am.
-- local window1=AirbossStennis:AddRecoveryWindow( "6:00", "6:15", 1, nil, true, 25)
-- local window2=AirbossStennis:AddRecoveryWindow( "7:00", "7:15", 1, nil, true, 25)
-- local window3=AirbossStennis:AddRecoveryWindow( "8:00", "8:15", 1, nil, true, 25)
-- local window4=AirbossStennis:AddRecoveryWindow( "9:00", "9:15", 1, nil, true, 25)
-- local window5=AirbossStennis:AddRecoveryWindow( "10:00", "10:15", 1, nil, true, 25)
-- local window6=AirbossStennis:AddRecoveryWindow( "11:00", "11:15", 1, nil, true, 25)
-- local window7=AirbossStennis:AddRecoveryWindow( "12:00", "12:15", 1, nil, true, 25)
-- local window8=AirbossStennis:AddRecoveryWindow( "13:00", "13:15", 1, nil, true, 25)
-- local window9=AirbossStennis:AddRecoveryWindow( "14:00", "14:15", 1, nil, true, 25)
-- local window10=AirbossStennis:AddRecoveryWindow( "15:00", "15:15", 1, nil, true, 25)
-- Case II with +15 degrees holding offset from 15:00 for 60 min.
--local window2=AirbossStennis:AddRecoveryWindow("15:00", "16:00", 2,  15, true, 23)
-- Case III with +30 degrees holding offset from 2100 to 2200.
--local window3=AirbossStennis:AddRecoveryWindow("21:00", "22:00", 3,  30, true, 21)

-- AirbossStennis:SetMenuSingleCarrier()
AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
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

    BotSay(string.format("Player %s scored %.1f", name, score))
    BotSay(string.format("details: wire: %d time in Grove: %d LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("Player %s scored %.1f", name, score))
end

-- ###########################################################
-- ###                       OTHERS                        ###
-- ###########################################################

trainer = MISSILETRAINER:New(200, "Training mode")

-- ###########################################################
-- ###                   RED COALITION                     ###
-- ###########################################################

-- CONVOYS ---------------------------------------------------
ZONE:New("col-0700"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "07:00")
ZONE:New("col-0800"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "08:00")
ZONE:New("col-0930"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "09:30")
ZONE:New("col-1100"):GetCoordinate(0):CircleToAll(5000, -1, {0, 1, 1}, 1, {0, 1, 1}, .3, 2, true, "11:00")

-- ZONES -----------------------------------------------------
ZONE_Al_Assad = ZONE_POLYGON:New("A2A_Al_Assad_ZONE", GROUP:FindByName("Al-Assad-ZONE")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)
CAP_Al_Assad = ZONE_POLYGON:New("Al-Assad-ZONE-CAP", GROUP:FindByName("Al-Assad-ZONE-CAP")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)

-- EWRS ------------------------------------------------------
RED_EW_Assad = SPAWN:New("RED-EW-1-Al-Assad"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )

-- SAMS ------------------------------------------------------
--Krasnodar_SAM = SPAWN:New("Krasnodar-SAM"):InitLimit(14, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Krasnodar_MANTIS = MANTIS:New("Krasnodar-MANTIS", "Krasnodar-SAM", "Krasnodar-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Krasnodar"):GetCoordinate(0):CircleToAll(40000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Mineralnye_SHORAD = SPAWN:New("Mineralnye-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Mineralnye_MANTIS = MANTIS:New("Mineralnye-MANTIS", "Mineralnye-SHORAD", "RED1-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Mineralnye"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Nalchik_SHORAD = SPAWN:New("Nalchik-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Nalchik_MANTIS = MANTIS:New("Nalchik-MANTIS", "Nalchik-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Nalchik"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Beslan_SHORAD = SPAWN:New("Beslan-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Beslan_MANTIS = MANTIS:New("Beslan-IADS", "Beslan-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Beslan"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Mozdok_SHORAD = SPAWN:New("Mozdok-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Mozdok_MANTIS = MANTIS:New("Mozdok-IADS", "Mozdok-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Mozdok"):GetCoordinate(0):CircleToAll(15000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
--Sochi_SHORAD = SPAWN:New("Sochi-MERAD"):InitLimit(16, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Sochi_MANTIS = MANTIS:New("Sochi-MANTIS", "Sochi-SHORAD", "RED3-EW", nil, coalition.side.RED, false):Start()
--ZONE:New("Sochi"):GetCoordinate(0):CircleToAll(50000, -1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)

-- FLIGHTS ---------------------------------------------------
--BIGBIRD_1 = SPAWN:New("A2A-Target-1"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_2 = SPAWN:New("A2A-Target-2"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_3 = SPAWN:New("A2A-Target-3"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_4 = SPAWN:New("A2A-Target-4"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_5 = SPAWN:New("A2A-Target-5"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )
--BIGBIRD_6 = SPAWN:New("A2A-Target-6"):InitLimit(3, 3):SpawnScheduled(UTILS.ClockToSeconds("00:10:00"), .25 )

--DSIPATCHERS -----------------------------------------------
A2A_Al_Assad = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED-EW-1"}):FilterStart(), 150000))
A2A_Al_Assad:SetBorderZone(ZONE_Al_Assad)
A2A_Al_Assad:SetDefaultTakeoffFromRunway()
A2A_Al_Assad:SetDefaultLandingAtRunway()
A2A_Al_Assad:SetDefaultFuelThreshold(0.20)
A2A_Al_Assad:SetDefaultDamageThreshold(0.90)
A2A_Al_Assad:SetEngageRadius(UTILS.NMToMeters(40))
A2A_Al_Assad:SetDisengageRadius(UTILS.NMToMeters(40))

A2A_Al_Assad:SetSquadron("Reds_29", AIRBASE.Syria.Bassel_Al_Assad, "Bassel_Al_Assad_MiG_29")
A2A_Al_Assad:SetSquadronCap("Reds_29", CAP_Al_Assad, UTILS.FeetToMeters(10000), UTILS.FeetToMeters(30000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Al_Assad:SetSquadronCapInterval("Reds_29", 1, 1800, 2000, 1 )
A2A_Al_Assad:SetSquadronGrouping("Reds_29", 2)
A2A_Al_Assad:SetSquadronOverhead("Reds_29", 1)