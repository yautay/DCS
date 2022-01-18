_SETTINGS:SetPlayerMenuOff()

-- CONSTS

local ATIS_Kobuleti = 122.300
local ATIS_Gudauta = 122.225
local ATIS_Soganlug = 122.600
local ATIS_Vaziani = 122.700
local ATIS_Kutaisi = 122.100
local TOWER_Kutasi = {134, 263}
local TACAN_Kutasi = 44
local ILS_Kutasi = 109.75
local ATIS_Senaki = 122.525
local ATIS_Batumi = 122.550
local ATIS_Sukhumi = 122.500
local TOWER_Sukhumi = {129, 258}
local TACAN_Sukhumi = 13
local ATIS_Tbilisi = 132.800

local ATIS_Anapa = 125.400
local ATIS_Gelendzhik = 134.875
local ATIS_Maykop = 128.700
local ATIS_Krasnodar = 122.450
local ATIS_Krasnodar = 128.300
local ATIS_Novorossiysk = 128.200
local ATIS_Krymsk = 128.600
local ATIS_Mineralnye = 125.250
local ATIS_Nalchik = 128.800
local ATIS_Beslan = 128.225
local ATIS_Sochi = 126.200
local ATIS_Mozdok = 128.550

-- ###########################################################
-- ###                  BLUE COALITION                     ###
-- ###########################################################

-- ATIS 
pathToSRS = "F:\\DCS-SimpleRadio-Standalone\\"
Atis_Sukhumi=ATIS:New(AIRBASE.Caucasus.Sukhumi_Babushara, ATIS_Sukhumi):SetRadioRelayUnitName("Radio Relay Sukhumi"):SetActiveRunway("12"):SetTowerFrequencies(TOWER_Sukhumi):SetTACAN(TACAN_Sukhumi):SetSRS(pathToSRS, 'female', 'en-GB', 5004):Start()
Atis_Kutasi=ATIS:New(AIRBASE.Caucasus.Kutaisi, ATIS_Kutaisi):SetRadioRelayUnitName("Radio Relay Kutasi"):SetActiveRunway("07"):SetTowerFrequencies(TOWER_Kutasi):SetTACAN(TACAN_Kutasi):AddILS(ILS_Kutasi, "07"):SetSRS(pathToSRS, 'female', 'en-GB', 5004):Start()

-- BASES
AIRBASE:FindByName(AIRBASE.Caucasus.Sukhumi_Babushara):GetCoordinate():CircleToAll(7500, 2, {1,1,0}, 1.0, {1,1,0}, 0.2)
AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi):GetCoordinate():CircleToAll(7500, 2, {1,1,0}, 1.0, {1,1,0}, 0.2)

-- BLUE Aux. flights
Tanker_Shell = SPAWN:New("Tanker 70Y Shell"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup(function (shell_11) shell_11:CommandSetCallsign(1,0) end):InitRepeatOnLanding()
Tanker_Texaco = SPAWN:New("Tanker 71Y Texaco"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup(function (texaco_11) texaco_11:CommandSetCallsign(1,0) end):InitRepeatOnLanding()
AWACS_Overlord = SPAWN:New("EW-AWACS-1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup(function (overlord_11) overlord_11:CommandSetCallsign(1,0) end):InitRepeatOnLanding()

-- SAMs
BLUE_SAM_1 = SPAWN:New("BLUE-SAM-01"):InitLimit(20, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
BLUE_MANTIS = MANTIS:New("BLUE_MANTIS", "BLUE-SAM", "EW-AWACS", nil, coalition.side.BLUE, false):Start()

-- ZONES
Shell_Zone = ZONE_POLYGON:New("Shell-Zone", GROUP:FindByName("Tanker 70Y Shell")):DrawZone(-1, {0,0,0.5}, 0.7, {0,0,0.5}, 0.3, 1)
Texaco_Zone = ZONE_POLYGON:New("Texaco-Zone", GROUP:FindByName("Tanker 71Y Texaco")):DrawZone(-1, {0,0,0.5}, 0.7, {0,0,0.5}, 0.3, 1)
Awacs_Zone_1 = ZONE_POLYGON:New("AWACS-Zone-1", GROUP:FindByName("EW-AWACS-1")):DrawZone(-1, {0.2,0.5,0.5}, 0.7, {0.2,0.5,0.5}, 0.4, 1)

-- ###########################################################
-- ###                      BLUE CV                        ###
-- ###########################################################

-- S-3B Recovery Tanker spawning in air.
tanker=RECOVERYTANKER:New("USS Stennis", "Stennis AAR")
tanker:SetTakeoffAir()
tanker:SetRadio(250)
tanker:SetModex(511)
tanker:SetTACAN(1, "TKR")
tanker:__Start(1)

-- E-2D AWACS spawning on Stennis.
awacs=RECOVERYTANKER:New("USS Stennis", "Stennis AWACS")
awacs:SetAWACS()
awacs:SetRadio(260)
awacs:SetAltitude(20000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(30, 15)
awacs:SetModex(611)
awacs:SetTACAN(2, "WIZ")
awacs:__Start(1)

-- Rescue Helo spawning on Stennis.
rescuehelo=RESCUEHELO:New("USS Stennis", "Rescue Helo")
rescuehelo:SetModex(42)
rescuehelo:__Start(1)


-- Create AIRBOSS object.
AirbossStennis=AIRBOSS:New("USS Stennis")
AirbossStennis:SetTACAN(74, "X", "STN"):SetICLS(1, "STN")
AirbossStennis:SetMarshalRadio(305, "AM"):SetLSORadio(264, "AM")
AirbossStennis:SetAirbossNiceGuy(true)

-- Add recovery windows:
-- Case I from 9 to 10 am.
-- local window1=AirbossStennis:AddRecoveryWindow( "9:00", "10:00", 1, nil, true, 25)
-- Case II with +15 degrees holding offset from 15:00 for 60 min.
--local window2=AirbossStennis:AddRecoveryWindow("15:00", "16:00", 2,  15, true, 23)
-- Case III with +30 degrees holding offset from 2100 to 2200.
--local window3=AirbossStennis:AddRecoveryWindow("21:00", "22:00", 3,  30, true, 21)

-- Set folder of airboss sound files within miz file.
AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")

-- Single carrier menu optimization.
AirbossStennis:SetMenuSingleCarrier()

-- Skipper menu.
AirbossStennis:SetMenuRecovery(30, 25, false)

-- Remove landed AI planes from flight deck.
AirbossStennis:SetDespawnOnEngineShutdown()

-- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
AirbossStennis:Load()

-- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
AirbossStennis:SetAutoSave()

-- Enable trap sheet.
AirbossStennis:SetTrapSheet()

-- Start airboss class.
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

  

--function DisplayWind()
--  local wpa, wpp, wtot = AirbossStennis:GetWindOnDeck()
--  local sog = AirbossStennis.carrier:GetVelocityKNOTS()
--  local text = string.format("SOG=%.1f kts, HDG=%03d, turning=%s, state=%s \n", sog, Airboss_Stennis:GetHeading(), tostring(Airboss_Stennis.turning), Airboss_Stennis:GetState())
--  text = text .. string.format("WIND || %.1f, ==%.1f, total %.1f kts", UTILS.MpsToKnots(wpa), UTILS.MpsToKnots(wpp), UTILS.MpsToKnots(wtot))
--  UTILS.DisplayMissionTime(25)
--  MESSAGE:New(text, 25):ToAll()
--end
--
--SCHEDULER:New(nil, DisplayWind, {}, 30, 10)

trainer = MISSILETRAINER:New(200,"Training mode")

-- ###########################################################
-- ###                   RED COALITION                     ###
-- ###########################################################

-- ZONES -----------------------------------------------------

A2A_Mineralnye_ZONE = ZONE_POLYGON:New("A2A_Mineralnye", GROUP:FindByName("A2A_Mineralnye")):DrawZone(-1, {1,1,0}, 1.0, {1,1,0}, 0.4, 2)
A2A_Leninsky_ZONE = ZONE_POLYGON:New("A2A_Beslan", GROUP:FindByName("A2A_Beslan")):DrawZone(-1, {1,0,0}, 1.0, {1,0,0}, 0.4, 2)
A2G_Sochi_ZONE = ZONE_AIRBASE:New(AIRBASE.Caucasus.Sochi_Adler, UTILS.NMToMeters(20)):DrawZone(-1, {0.5,0,1}, 1.0, {0.5,0,1}, 0.4, 2)

CAP_Oktyabrskiy = ZONE_POLYGON:New("CAP_Oktyabrskiy", GROUP:FindByName("CAP_Oktyabrskiy")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)
CAP_Russkoye_N = ZONE_POLYGON:New("CAP_Russkoye_N", GROUP:FindByName("CAP_Russkoye_N")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)
CAP_Russkoye_E = ZONE_POLYGON:New("CAP_Russkoye_E", GROUP:FindByName("CAP_Russkoye_E")):DrawZone(-1, {0,0,0}, 1.0, {0,0,0}, 0.2, 3)

-- EWRS ------------------------------------------------------
Mineralnye_EW_01 = SPAWN:New("RED1-EW-Mineralnye-EW-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
Mineralnye_EW_02 = SPAWN:New("RED1-EW-Mineralnye-EW-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
Mineralnye_EW_03 = SPAWN:New("RED1-EW-Mineralnye-EW-3"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
AWACS_Red_01 = SPAWN:New("RED2-EW-AWACS-1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):InitRepeatOnLanding()
Beslan_EW_01 = SPAWN:New("RED2-EW-Beslan-EW-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
Sochi_EW_01 = SPAWN:New("RED3-EW-Sochi-EW-1"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )
Sochi_EW_02 = SPAWN:New("RED3-EW-Sochi-EW-2"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25 )

-- SAMS ------------------------------------------------------

Mineralnye_SHORAD = SPAWN:New("Mineralnye-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
Mineralnye_MANTIS = MANTIS:New("Mineralnye-MANTIS", "Mineralnye-SHORAD", "RED1-EW", nil, coalition.side.RED, false):Start()

Nalchik_SHORAD = SPAWN:New("Nalchik-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
Nalchik_MANTIS = MANTIS:New("Nalchik-MANTIS", "Nalchik-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()

Beslan_SHORAD = SPAWN:New("Beslan-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
Beslan_MANTIS = MANTIS:New("Beslan-IADS", "Beslan-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()

Mozdok_SHORAD = SPAWN:New("Mozdok-SHORAD"):InitLimit(3, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
Mozdok_MANTIS = MANTIS:New("Mozdok-IADS", "Mozdok-SHORAD", "RED2-EW", nil, coalition.side.RED, false):Start()

Sochi_SHORAD = SPAWN:New("Sochi-MERAD"):InitLimit(16, 0):SpawnScheduled(UTILS.ClockToSeconds("01:00:00"), .25 )
Sochi_MANTIS = MANTIS:New("Sochi-MANTIS", "Sochi-SHORAD", "RED3-EW", nil, coalition.side.RED, false):Start()

-- DSIPATCHERS -----------------------------------------------

A2A_Mineralnye_CC = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED1-EW"}):FilterStart(), 150000))
A2A_Mineralnye_CC:SetBorderZone(A2A_Mineralnye_ZONE)
A2A_Mineralnye_CC:SetDefaultTakeoffFromRunway() 
A2A_Mineralnye_CC:SetDefaultLandingAtRunway()
A2A_Mineralnye_CC:SetDefaultFuelThreshold(0.20)
A2A_Mineralnye_CC:SetDefaultDamageThreshold(0.90)
A2A_Mineralnye_CC:SetEngageRadius(UTILS.NMToMeters(100))
A2A_Mineralnye_CC:SetDisengageRadius(UTILS.NMToMeters(75))

A2A_Mineralnye_CC:SetSquadron("Agressors Regiment", AIRBASE.Caucasus.Nalchik, "Nalchik_f5")
A2A_Mineralnye_CC:SetSquadronCap("Agressors Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(10000), UTILS.FeetToMeters(30000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Mineralnye_CC:SetSquadronCapInterval("Agressors Regiment", 1, 60, 180, 1 )
A2A_Mineralnye_CC:SetSquadronGrouping("Agressors Regiment", 3)
A2A_Mineralnye_CC:SetSquadronOverhead("Agressors Regiment", 1)

A2A_Mineralnye_CC:SetSquadron("176th Fighter Aviation Regiment", AIRBASE.Caucasus.Mineralnye_Vody, "Mineralnye_mig21")
A2A_Mineralnye_CC:SetSquadronCap("176th Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(19000), UTILS.FeetToMeters(27000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(320), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Mineralnye_CC:SetSquadronCapInterval("176th Fighter Aviation Regiment", 2, 30, 90, 1 )
A2A_Mineralnye_CC:SetSquadronGrouping("176th Fighter Aviation Regiment", 2)
A2A_Mineralnye_CC:SetSquadronOverhead("176th Fighter Aviation Regiment", 1.2)

A2A_Leninsky_CC = AI_A2A_DISPATCHER:New(DETECTION_AREAS:New(SET_GROUP:New():FilterPrefixes({"RED2-EW"}):FilterStart(), 300000))
A2A_Leninsky_CC:SetBorderZone(A2A_Leninsky_ZONE)
A2A_Leninsky_CC:SetDefaultTakeoffFromRunway() 
A2A_Leninsky_CC:SetDefaultLandingAtRunway()
A2A_Leninsky_CC:SetDefaultFuelThreshold(0.20)
A2A_Leninsky_CC:SetDefaultDamageThreshold(0.70)
A2A_Leninsky_CC:SetEngageRadius(UTILS.NMToMeters(120))
A2A_Leninsky_CC:SetDisengageRadius(UTILS.NMToMeters(80))

A2A_Leninsky_CC:SetSquadron("201th Fighter Aviation Regiment", AIRBASE.Caucasus.Nalchik, "Nalchik_mig29")
A2A_Leninsky_CC:SetSquadronCap("201th Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(19000), UTILS.FeetToMeters(27000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(400), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Leninsky_CC:SetSquadronCapInterval("201th Fighter Aviation Regiment", 1, 30, 90, 1 )
A2A_Leninsky_CC:SetSquadronGrouping("201th Fighter Aviation Regiment", 2)
A2A_Leninsky_CC:SetSquadronOverhead("201th Fighter Aviation Regiment", 1)

A2A_Leninsky_CC:SetSquadron("201th Fighter Aviation Regiment", AIRBASE.Caucasus.Nalchik, "Mozdok_su27")
A2A_Leninsky_CC:SetSquadronCap("201th Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(25000), UTILS.FeetToMeters(35000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(400), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
A2A_Leninsky_CC:SetSquadronCapInterval("201th Fighter Aviation Regiment", 1, 60, 90, 1 )
A2A_Leninsky_CC:SetSquadronGrouping("201th Fighter Aviation Regiment", 2)
A2A_Leninsky_CC:SetSquadronOverhead("201th Fighter Aviation Regiment", 1)

--A2A_Leninsky_CC:SetSquadron("Heavy Fighter Aviation Regiment", AIRBASE.Caucasus.Mozdok, "Mozdok_mig31")
--A2A_Leninsky_CC:SetSquadronCap("Heavy Fighter Aviation Regiment", CAP_Oktyabrskiy, UTILS.FeetToMeters(30000), UTILS.FeetToMeters(40000), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(400), UTILS.KnotsToKmph(270), UTILS.KnotsToKmph(900), "BARO" )
--A2A_Leninsky_CC:SetSquadronCapInterval("Heavy Fighter Aviation Regiment", 1, 180, 600, 1 )
--A2A_Leninsky_CC:SetSquadronGrouping("Heavy Fighter Aviation Regiment", 2)
--A2A_Leninsky_CC:SetSquadronOverhead("Heavy Fighter Aviation Regiment", 0.5)
