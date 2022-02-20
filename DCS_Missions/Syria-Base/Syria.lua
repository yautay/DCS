_SETTINGS:SetPlayerMenuOff()

-- CONSTS

-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- BLUE Aux. flights
Tanker_Shell = SPAWN:New("Tanker 70Y Shell"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup(function (shell_11) shell_11:CommandSetCallsign(1,0) end):InitRepeatOnLanding()
Tanker_Texaco = SPAWN:New("Tanker 71Y Texaco"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup(function (texaco_11) texaco_11:CommandSetCallsign(1,0) end):InitRepeatOnLanding()
AWACS_Overlord = SPAWN:New("EW-AWACS-1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup(function (overlord_11) overlord_11:CommandSetCallsign(1,0) end):InitRepeatOnLanding()

-- F10 Map Markings
ZONE:New("TKR-1-1"):GetCoordinate(0):LineToAll(ZONE:New("TKR-1-2"):GetCoordinate(0), -1, {0,0,1}, 1, 2, true, "SHELL")
ZONE:New("TKR-2"):GetCoordinate(0):CircleToAll(7500, -1, {0,0,1}, 1, {0,0,1}, .3, 2, true, "TEXACO")
ZONE:New("AWACS-1"):GetCoordinate(0):CircleToAll(7500, -1, {0,0,1}, 1, {0,0,1}, .3, 2, true, "TEXACO")

-- SAMs
--BLUE_SAM_1 = SPAWN:New("BLUE-SAM-01"):InitLimit(20, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_SAM_SUKHUMI = SPAWN:New("Sukhumi-SAM"):InitLimit(13, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--BLUE_MANTIS = MANTIS:New("BLUE_MANTIS", "BLUE-SAM", "EW-AWACS", nil, coalition.side.BLUE, false):Start()

-- ###########################################################
-- ###                      BLUE CV                        ###
-- ###########################################################

-- F10 Map Markings

ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0,.5,1}, 1, 4, true)
ZONE:New("CV-2"):GetCoordinate(0):LineToAll(ZONE:New("CV-3"):GetCoordinate(0), -1, {0,.5,1}, 1, 4, true)
ZONE_POLYGON:New("CV-1-Area", GROUP:FindByName("helper_cv_stennis")):DrawZone(-1, {0,.5,1}, 1, {0,.5,1}, 0.4, 2)

-- S-3B Recovery Tanker.
-- ARCO 250.00 1->"TRK" A6 250KIAS
tanker=RECOVERYTANKER:New("USS Stennis", "USS Stennis AAR")
tanker:SetTakeoffHot()
tanker:SetRadio(250)
tanker:SetModex(511)
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:SetTACAN(1, "TKR")
tanker:__Start(1)

-- E-2D AWACS spawning on Stennis.
-- Wizard 260.00 A20
awacs=RECOVERYTANKER:New("USS Stennis", "USS Stennis AWACS")
awacs:SetAWACS()
awacs:SetRadio(260)
awacs:SetAltitude(20000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(15, 15)
awacs:SetModex(611)
awacs:__Start(1)

-- Rescue Helo spawning on Stennis.
rescuehelo=RESCUEHELO:New("USS Stennis", "USS Stennis SAR")
rescuehelo:SetModex(42)
rescuehelo:__Start(1)


-- Create AIRBOSS object.
AirbossStennis=AIRBOSS:New("USS Stennis")
AirbossStennis:SetTACAN(74, "X", "STN"):SetICLS(1, "STN")
AirbossStennis:SetMarshalRadio(305, "AM"):SetLSORadio(264, "AM")

-- Add recovery windows:
-- Case I from 9 to 10 am.
local window1=AirbossStennis:AddRecoveryWindow( "6:00", "6:15", 1, nil, true, 25)
local window2=AirbossStennis:AddRecoveryWindow( "7:00", "7:15", 1, nil, true, 25)
local window3=AirbossStennis:AddRecoveryWindow( "8:00", "8:15", 1, nil, true, 25)
local window4=AirbossStennis:AddRecoveryWindow( "9:00", "9:15", 1, nil, true, 25)
local window5=AirbossStennis:AddRecoveryWindow( "10:00", "10:15", 1, nil, true, 25)
local window6=AirbossStennis:AddRecoveryWindow( "11:00", "11:15", 1, nil, true, 25)
local window7=AirbossStennis:AddRecoveryWindow( "12:00", "12:15", 1, nil, true, 25)
local window8=AirbossStennis:AddRecoveryWindow( "13:00", "13:15", 1, nil, true, 25)
local window9=AirbossStennis:AddRecoveryWindow( "14:00", "14:15", 1, nil, true, 25)
local window10=AirbossStennis:AddRecoveryWindow( "15:00", "15:15", 1, nil, true, 25)
-- Case II with +15 degrees holding offset from 15:00 for 60 min.
--local window2=AirbossStennis:AddRecoveryWindow("15:00", "16:00", 2,  15, true, 23)
-- Case III with +30 degrees holding offset from 2100 to 2200.
--local window3=AirbossStennis:AddRecoveryWindow("21:00", "22:00", 3,  30, true, 21)

AirbossStennis:SetMenuSingleCarrier()
AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
AirbossStennis:SetMenuRecovery(30, 25, false)
AirbossStennis:SetDespawnOnEngineShutdown()
AirbossStennis:Load()
AirbossStennis:SetAutoSave()
AirbossStennis:SetTrapSheet()
AirbossStennis:Start()


--- Function called when recovery tanker is started.
function tanker:OnAfterStart(From,Event,To)
  AirbossStennis:SetRecoveryTanker(tanker)  
  AirbossStennis:SetRadioRelayLSO(self:GetUnitName()) 
end

--- Function called when AWACS is started.
function awacs:OnAfterStart(From,Event,To)
  AirbossStennis:SetAWACS(awacs)
end


--- Function called when rescue helo is started.
function rescuehelo:OnAfterStart(From,Event,To)
  AirbossStennis:SetRadioRelayMarshal(self:GetUnitName())
end

--- Function called when a player gets graded by the LSO.
function AirbossStennis:OnAfterLSOGrade(From, Event, To, playerData, grade)
  local PlayerData=playerData --Ops.Airboss#AIRBOSS.PlayerData
  local Grade=grade --Ops.Airboss#AIRBOSS.LSOgrade

  ----------------------------------------
  --- Interface your Discord bot here! ---
  ----------------------------------------
  
  local score=tonumber(Grade.points)
  local name=tostring(PlayerData.name)
  
  -- Report LSO grade to dcs.log file.
  env.info(string.format("Player %s scored %.1f", name, score))
end

-- TF CAP

TF_CAP_ZONE_BORDER = ZONE_UNIT:New("TF-CAP-ZONE", UNIT:FindByName("USS Stennis"), UTILS.NMToMeters(50)):DrawZone(-1, {1,.8,0}, 1.0, {1,.8,0}, 0.4, 2)
TF_CAP_ZONE_CAP = ZONE_UNIT:New("TF-CAP-ZONE", UNIT:FindByName("USS Stennis"), UTILS.NMToMeters(20)):DrawZone(-1, {1,.8,0}, 1.0, {1,.8,0}, 0.4, 2)

TF_Stennis_CC = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"TF CV Stennis", "USS Stennis AWACS"}):FilterStart(), 150000))
TF_Stennis_CC:SetBorderZone(TF_CAP_ZONE_BORDER)
TF_Stennis_CC:SetDefaultTakeoffFromParkingHot() 
TF_Stennis_CC:SetDefaultLandingAtRunway()
TF_Stennis_CC:SetDefaultFuelThreshold(0.20)
TF_Stennis_CC:SetDefaultDamageThreshold(0.90)
TF_Stennis_CC:SetEngageRadius(UTILS.NMToMeters(50))
TF_Stennis_CC:SetDisengageRadius(UTILS.NMToMeters(50))

TF_Stennis_CC:SetSquadron("VF-103", "USS Stennis", "CAP-Stennis-1")
TF_Stennis_CC:SetSquadronCap("VF-103", TF_CAP_ZONE_CAP, UTILS.FeetToMeters(25000), UTILS.FeetToMeters(40000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
TF_Stennis_CC:SetSquadronCapInterval("VF-103", 1, 60, 180, 1 )
TF_Stennis_CC:SetSquadronGrouping("VF-103", 2)
TF_Stennis_CC:SetSquadronOverhead("VF-103", 1)

-- ###########################################################
-- ###                   KORMAKITI RANGE                   ###
-- ###########################################################

local strafepit_pits={"Target-Pit-1", "Target-Pit-2", "Target-Pit-3"}
local strafepit_vehicles={"Strafe-Hard-1", "Strafe-Hard-2", "Strafe-Hard-3", "Strafe-Hard-4", "Strafe-Hard-5", "Strafe-Hard-6", "Strafe-Hard-7", "Strafe-Hard-8", "Strafe-Soft-1", "Strafe-Soft-2", "Strafe-Soft-3", "Strafe-Soft-4", "Strafe-Soft-5", "Strafe-Soft-6"}
local bombtargets_circles={"Target-Circle-1", "Target-Circle-2", "Target-Circle-3"}
local bombtargets_urban={"Circle-Urban"}

KormakitiRange=RANGE:New("Kormakiti Range")
KormakitiRange:SetSoundfilesFolder("Range Soundfiles/")
KormakitiRange:SetRangeRadius(15)
KormakitiRange:SetInstructorRadio(235)
KormakitiRange:SetRangeControl(235)
KormakitiRange:SetAutosave()


KormakitiRange:GetFoullineDistance("Target-Pit-1", "Foul Line-mark")

KormakitiRange:AddStrafePit(strafepit_pits, nil, nil, nil, true, nil, fouldist)
KormakitiRange:AddStrafePit(strafepit_vehicles, nil, nil, nil, true, nil, fouldist)
KormakitiRange:AddBombingTargets(bombtargets_urban, 5)
KormakitiRange:AddBombingTargets(bombtargets_urban, 50)
KormakitiRange:AddBombingTargets(strafepit_vehicles, 20)

KormakitiRange:Start()

-- ###########################################################
-- ###                       OTHERS                        ###
-- ###########################################################

trainer = MISSILETRAINER:New(200,"Training mode")


-- ###########################################################
-- ###                   RED COALITION                     ###
-- ###########################################################

-- ZONES -----------------------------------------------------
--A2A_Mineralnye_ZONE = ZONE_POLYGON:New("A2A_Mineralnye", GROUP:FindByName("A2A_Mineralnye")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)
--A2A_Leninsky_ZONE = ZONE_POLYGON:New("A2A_Beslan", GROUP:FindByName("A2A_Beslan")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)
--A2A_Krasnodar_ZONE = ZONE_POLYGON:New("A2A_Krasnodar", GROUP:FindByName("A2A_Krasnodar")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)
--A2A_Sevastopol_ZONE = ZONE_POLYGON:New("A2A_Sevastopol", GROUP:FindByName("A2A_Sevastopol")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)
--A2G_Sochi_ZONE = ZONE_AIRBASE:New(AIRBASE.Caucasus.Sochi_Adler, UTILS.NMToMeters(20)):DrawZone(-1, {0.5,0,1}, 1.0, {0.5,0,1}, 0.4, 2)
--CAP_Oktyabrskiy = ZONE_POLYGON:New("CAP_Oktyabrskiy", GROUP:FindByName("CAP_Oktyabrskiy")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)
--CAP_Russkoye_N = ZONE_POLYGON:New("CAP_Russkoye_N", GROUP:FindByName("CAP_Russkoye_N")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)
--CAP_Russkoye_E = ZONE_POLYGON:New("CAP_Russkoye_E", GROUP:FindByName("CAP_Russkoye_E")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)
--CAP_Sevastopol = ZONE_POLYGON:New("CAP_Sevastopol", GROUP:FindByName("CAP_Sevastopol")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)

-- EWRS ------------------------------------------------------
--Mineralnye_EW_01 = SPAWN:New("RED1-EW-Mineralnye-EW-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Mineralnye_EW_02 = SPAWN:New("RED1-EW-Mineralnye-EW-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Mineralnye_EW_03 = SPAWN:New("RED1-EW-Mineralnye-EW-3"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--AWACS_Red_01 = SPAWN:New("RED2-EW-AWACS-1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):InitRepeatOnLanding()
--Beslan_EW_01 = SPAWN:New("RED2-EW-Beslan-EW-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
--Sochi_EW_01 = SPAWN:New("RED3-EW-Sochi-EW-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Sochi_EW_02 = SPAWN:New("RED3-EW-Sochi-EW-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_01 = SPAWN:New("Krasnodar-EWR-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_02 = SPAWN:New("Krasnodar-EWR-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_03 = SPAWN:New("Krasnodar-EWR-3"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_04 = SPAWN:New("Krasnodar-EWR-4"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_05 = SPAWN:New("Krasnodar-EWR-5"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_06 = SPAWN:New("Krasnodar-EWR-6"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_07 = SPAWN:New("Krasnodar-EWR-7"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_08 = SPAWN:New("Krasnodar-EWR-8"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Krasnodar_EW_09 = SPAWN:New("Krasnodar-EWR-9"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Sevastopol_EW_01 = SPAWN:New("Sevastopol-EWR-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
--Sevastopol_EW_02 = SPAWN:New("Sevastopol-EWR-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )

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

-- DSIPATCHERS -----------------------------------------------
--A2A_Mineralnye_CC = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED1-EW"}):FilterStart(), 150000))
--A2A_Mineralnye_CC:SetBorderZone(A2A_Mineralnye_ZONE)
--A2A_Mineralnye_CC:SetDefaultTakeoffFromRunway() 
--A2A_Mineralnye_CC:SetDefaultLandingAtRunway()
--A2A_Mineralnye_CC:SetDefaultFuelThreshold(0.20)
--A2A_Mineralnye_CC:SetDefaultDamageThreshold(0.90)
--A2A_Mineralnye_CC:SetEngageRadius(UTILS.NMToMeters(100))
--A2A_Mineralnye_CC:SetDisengageRadius(UTILS.NMToMeters(75))
--A2A_Mineralnye_CC:SetSquadron("Agressors Regiment", AIRBASE.Caucasus.Nalchik, "Nalchik_f5")
--A2A_Mineralnye_CC:SetSquadronCap("Agressors Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(10000), UTILS.FeetToMeters(30000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
--A2A_Mineralnye_CC:SetSquadronCapInterval("Agressors Regiment", 1, 60, 180, 1 )
--A2A_Mineralnye_CC:SetSquadronGrouping("Agressors Regiment", 3)
--A2A_Mineralnye_CC:SetSquadronOverhead("Agressors Regiment", 1)
--A2A_Mineralnye_CC:SetSquadron("176th Fighter Aviation Regiment", AIRBASE.Caucasus.Mineralnye_Vody, "Mineralnye_mig21")
--A2A_Mineralnye_CC:SetSquadronCap("176th Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(19000), UTILS.FeetToMeters(27000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
--A2A_Mineralnye_CC:SetSquadronCapInterval("176th Fighter Aviation Regiment", 2, 30, 90, 1 )
--A2A_Mineralnye_CC:SetSquadronGrouping("176th Fighter Aviation Regiment", 2)
--A2A_Mineralnye_CC:SetSquadronOverhead("176th Fighter Aviation Regiment", 1.2)
--A2A_Leninsky_CC = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED2-EW"}):FilterStart(), 300000))
--A2A_Leninsky_CC:SetBorderZone(A2A_Leninsky_ZONE)
--A2A_Leninsky_CC:SetDefaultTakeoffFromRunway() 
--A2A_Leninsky_CC:SetDefaultLandingAtRunway()
--A2A_Leninsky_CC:SetDefaultFuelThreshold(0.20)
--A2A_Leninsky_CC:SetDefaultDamageThreshold(0.70)
--A2A_Leninsky_CC:SetEngageRadius(UTILS.NMToMeters(120))
--A2A_Leninsky_CC:SetDisengageRadius(UTILS.NMToMeters(80))
--A2A_Leninsky_CC:SetSquadron("25th Fighter Aviation Regiment", AIRBASE.Caucasus.Nalchik, "Nalchik_mig29")
--A2A_Leninsky_CC:SetSquadronCap("25th Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(19000), UTILS.FeetToMeters(27000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(400), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
--A2A_Leninsky_CC:SetSquadronCapInterval("25th Fighter Aviation Regiment", 1, 30, 90, 1 )
--A2A_Leninsky_CC:SetSquadronGrouping("25th Fighter Aviation Regiment", 2)
--A2A_Leninsky_CC:SetSquadronOverhead("25th Fighter Aviation Regiment", 1)
--A2A_Leninsky_CC:SetSquadron("207th Fighter Aviation Regiment", AIRBASE.Caucasus.Nalchik, "Mozdok_su27")
--A2A_Leninsky_CC:SetSquadronCap("207th Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(25000), UTILS.FeetToMeters(35000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(400), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
--A2A_Leninsky_CC:SetSquadronCapInterval("207th Fighter Aviation Regiment", 1, 60, 90, 1 )
--A2A_Leninsky_CC:SetSquadronGrouping("207th Fighter Aviation Regiment", 2)
--A2A_Leninsky_CC:SetSquadronOverhead("207th Fighter Aviation Regiment", 1)
--A2A_Leninsky_CC:SetSquadron("Heavy Fighter Aviation Regiment", AIRBASE.Caucasus.Mozdok, "Mozdok_mig31")
--A2A_Leninsky_CC:SetSquadronCap("Heavy Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(30000), UTILS.FeetToMeters(40000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(400), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
--A2A_Leninsky_CC:SetSquadronCapInterval("Heavy Fighter Aviation Regiment", 1, 180, 600, 1 )
--A2A_Leninsky_CC:SetSquadronGrouping("Heavy Fighter Aviation Regiment", 2)
--A2A_Leninsky_CC:SetSquadronOverhead("Heavy Fighter Aviation Regiment", 0.5)
--A2A_Sevastopol_CC = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"Sevastopol-EWR"}):FilterStart(), 100000))
--A2A_Sevastopol_CC:SetBorderZone(A2A_Sevastopol_ZONE)
--A2A_Sevastopol_CC:SetDefaultTakeoffFromRunway() 
--A2A_Sevastopol_CC:SetDefaultLandingAtRunway()
--A2A_Sevastopol_CC:SetDefaultFuelThreshold(0.20)
--A2A_Sevastopol_CC:SetDefaultDamageThreshold(0.60)
--A2A_Sevastopol_CC:SetEngageRadius(UTILS.NMToMeters(100))
--A2A_Sevastopol_CC:SetDisengageRadius(UTILS.NMToMeters(140))
--A2A_Sevastopol_CC:SetSquadron("2nd Naval Fighter Regiment", AIRBASE.Caucasus.Anapa_Vityazevo, "Anapa_Su33")
--A2A_Sevastopol_CC:SetSquadronCap("2nd Naval Fighter Regiment", CAP_Sevastopol, UTILS.FeetToMeters(20000), UTILS.FeetToMeters(40000), UTILS.KnotsToKmph(240), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
--A2A_Sevastopol_CC:SetSquadronCapInterval("2nd Naval Fighter Regiment", 1, 20, 40, 1 )
--A2A_Sevastopol_CC:SetSquadronGrouping("2nd Naval Fighter Regiment", 1)
--A2A_Sevastopol_CC:SetSquadronOverhead("2nd Naval Fighter Regiment", 1)


