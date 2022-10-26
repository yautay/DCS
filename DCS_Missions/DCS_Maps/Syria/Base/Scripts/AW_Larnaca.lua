function orbit_mark(route, text)
    route[1]:LineToAll(calculateCoordinateFromRoute(route[1], route[4], route[5], false, false), 2, CONST.RGB.range, 1, 2, true, text)
end

ZONE_SHELL_2_AAR = ZONE:New("SHELL_2_AAR")
ZONE_SEA_PATROL = ZONE:New("SEA PATROL")
ZONE_ELINT_PATROL = ZONE:New("ELINT PATROL")

AW_LCLK = AIRWING:New("WH Larnaca", "Larnaca Air Wing")

AW_LCLK:SetMarker(false)
AW_LCLK:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Larnaca))
AW_LCLK:SetRespawnAfterDestroyed(600)
AW_LCLK:__Start(2)

AW_LCLK_AAR_C130 = SQUADRON:New("ME AAR C130", 6, "AAR Squadron C130")
AW_LCLK_AAR_C130:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LCLK_AAR_C130:SetTakeoffType("Hot")
AW_LCLK_AAR_C130:SetFuelLowRefuel(false)
AW_LCLK_AAR_C130:SetFuelLowThreshold(0.4)
AW_LCLK_AAR_C130:SetTurnoverTime(30, 5)
AW_LCLK:AddSquadron(AW_LCLK_AAR_C130)
AW_LCLK:NewPayload("ME AAR C130", -1, { AUFTRAG.Type.TANKER }, 100)

local Shell_2_1_route = {ZONE_SHELL_2_AAR:GetCoordinate(), 20000, 290, 0, 40}
orbit_mark(Shell_2_1_route, "SHELL 2-1")

MISSION_Shell_2 = AUFTRAG:NewTANKER(Shell_2_1_route[1], Shell_2_1_route[2], Shell_2_1_route[3], Shell_2_1_route[4], Shell_2_1_route[5], 1)
MISSION_Shell_2:AssignSquadrons({ AW_LCLK_AAR_C130 })
MISSION_Shell_2:SetRadio(FREQUENCIES.AAR.shell_2[1])
MISSION_Shell_2:SetName("Shell Two")
AW_LCLK:AddMission(MISSION_Shell_2)

AW_LCLK_P8A = SQUADRON:New("ME SEA CONTROL", 6, "Poseidon Squadron")
AW_LCLK_P8A:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_LCLK_P8A:SetTakeoffType("Hot")
AW_LCLK_P8A:SetFuelLowRefuel(true)
AW_LCLK_P8A:SetFuelLowThreshold(0.4)
AW_LCLK_P8A:SetTurnoverTime(30, 5)
AW_LCLK:AddSquadron(AW_LCLK_P8A)
AW_LCLK:NewPayload("ME SEA CONTROL", -1, { AUFTRAG.Type.PATROLZONE }, 100)

AW_LCLK_ELINT = SQUADRON:New("ME AWACS RJ", 2, "AWACS")
AW_LCLK_ELINT:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_LCLK_ELINT:SetTakeoffType("Hot")
AW_LCLK_ELINT:SetFuelLowRefuel(true)
AW_LCLK_ELINT:SetFuelLowThreshold(0.4)
AW_LCLK_ELINT:SetTurnoverTime(30, 5)
AW_LCLK_ELINT:SetRadio(FREQUENCIES.AWACS.wizard[1], FREQUENCIES.AWACS.wizard[3])
AW_LCLK:AddSquadron(AW_LCLK_ELINT)
AW_LCLK:NewPayload("ME AWACS RJ", -1, { AUFTRAG.Type.PATROLZONE }, 100)

local sea_patrol_route = {ZONE_SEA_PATROL:GetCoordinate(), 14000, 370, 35, 60}
MISSION_Sea_Control= AUFTRAG:NewORBIT_RACETRACK(sea_patrol_route[1], sea_patrol_route[2], sea_patrol_route[3], sea_patrol_route[4], sea_patrol_route[5])
MISSION_Sea_Control:AssignSquadrons({ AW_LCLK_P8A })
MISSION_Sea_Control:SetRadio(FREQUENCIES.AWACS.wizard[1])
MISSION_Sea_Control:SetName("Poseidon")
AW_LCLK:AddMission(MISSION_Sea_Control)

local elint_patrol_route = {ZONE_ELINT_PATROL:GetCoordinate(), 30000, 420, 75, 100}
MISSION_Elint_Recce= AUFTRAG:NewORBIT_RACETRACK(elint_patrol_route[1], elint_patrol_route[2], elint_patrol_route[3], elint_patrol_route[4], elint_patrol_route[5])
MISSION_Elint_Recce:AssignSquadrons({ AW_LCLK_ELINT })
MISSION_Elint_Recce:SetRadio(FREQUENCIES.AWACS.wizard[1])
MISSION_Elint_Recce:SetName("Rivet Joint")
AW_LCLK:AddMission(MISSION_Elint_Recce)