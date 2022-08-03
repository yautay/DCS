ZONE_SHELL_ONE_AAR = ZONE:New("ZONE_SHELL_ONE_AAR")
ZONE_SHELL_TWO_AAR = ZONE:New("ZONE_SHELL_TWO_AAR")
ZONE_SHELL_THREE_AAR = ZONE:New("ZONE_SHELL_THREE_AAR")

AW_LCRA = AIRWING:New("WH Akrotiri", "Akrotiri Air Wing")

AW_LCRA:SetMarker(false)
AW_LCRA:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Akrotiri))
AW_LCRA:SetRespawnAfterDestroyed(600)


AW_LCRA_AAR = SQUADRON:New("ME AAR RD", 20, "AAR")
AW_LCRA_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LCRA_AAR:SetTakeoffType("Air")
AW_LCRA_AAR:SetFuelLowRefuel(false)
AW_LCRA_AAR:SetFuelLowThreshold(0.4)
AW_LCRA_AAR:SetTurnoverTime(30, 5)
AW_LCRA:AddSquadron(AW_LCRA_AAR)
AW_LCRA:NewPayload("ME AAR RD", -1, { AUFTRAG.Type.TANKER }, 100)

MISSION_Shell_1 = AUFTRAG:NewTANKER(ZONE_SHELL_ONE_AAR:GetCoordinate(), 25000, 431, 0, 20, 1)
MISSION_Shell_1:AssignSquadrons({ AW_LCRA_AAR })
MISSION_Shell_1:SetRadio(FREQUENCIES.AAR.shell_1[1])
MISSION_Shell_1:SetName("Shell One")
AW_LCRA:AddMission(MISSION_Shell_1)

MISSION_Shell_2 = AUFTRAG:NewTANKER(ZONE_SHELL_TWO_AAR:GetCoordinate(), 23000, 418, 0, 20, 1)
MISSION_Shell_2:AssignSquadrons({ AW_LCRA_AAR })
MISSION_Shell_2:SetRadio(FREQUENCIES.AAR.shell_2[1])
MISSION_Shell_2:SetName("Shell Two")
AW_LCRA:AddMission(MISSION_Shell_2)

MISSION_Shell_3 = AUFTRAG:NewTANKER(ZONE_SHELL_THREE_AAR:GetCoordinate(), 21000, 406, 0, 20, 1)
MISSION_Shell_3:AssignSquadrons({ AW_LCRA_AAR })
MISSION_Shell_3:SetRadio(FREQUENCIES.AAR.shell_3[1])
MISSION_Shell_3:SetName("Shell Three")
AW_LCRA:AddMission(MISSION_Shell_3)

AW_LCRA:__Start(2)
