RED = {}
RED.Squadrons = {}
RED.Airwings = {}
RED.Commander = nil


RED.Squadrons.AWACS = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AWACS, 2, "RED_AWACS")
RED.Squadrons.AWACS:SetSkill(AI.Skill.EXCELLENT)
RED.Squadrons.AWACS:SetFuelLowThreshold(0.4)
RED.Squadrons.AWACS:SetFuelLowRefuel(true)
RED.Squadrons.AWACS:SetTurnoverTime(10, 20)
RED.Squadrons.AWACS:SetTakeoffHot()
RED.Squadrons.AWACS:AddMissionCapability({AUFTRAG.Type.ALERT5})
RED.Squadrons.AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT, AUFTRAG.Type.AWACS }, 100)

RED.Squadrons.AAR = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AAR, 3, "RED_AAR")
RED.Squadrons.AAR:SetSkill(AI.Skill.EXCELLENT)
RED.Squadrons.AAR:SetFuelLowThreshold(0.4)
RED.Squadrons.AAR:SetFuelLowRefuel(false)
RED.Squadrons.AAR:SetTurnoverTime(10, 20)
RED.Squadrons.AAR:SetTakeoffHot()
RED.Squadrons.AAR:AddMissionCapability({AUFTRAG.Type.ALERT5})
RED.Squadrons.AAR:AddMissionCapability({ AUFTRAG.Type.ORBIT, AUFTRAG.Type.TANKER }, 100)

RED.Squadrons.MiG29 = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_ESCORT, 6, "RED_MiG29")
RED.Squadrons.MiG29:SetSkill(AI.Skill.EXCELLENT)
RED.Squadrons.MiG29:SetFuelLowThreshold(0.4)
RED.Squadrons.MiG29:SetFuelLowRefuel(true)
-- RED.Squadrons.MiG29:SetGrouping(2)
RED.Squadrons.MiG29:SetTakeoffHot()
RED.Squadrons.MiG29:AddMissionCapability({AUFTRAG.Type.ORBIT, AUFTRAG.Type.GCICAP, AUFTRAG.Type.CAP}, 70)
RED.Squadrons.MiG29:AddMissionCapability({AUFTRAG.Type.INTERCEPT}, 50)
RED.Squadrons.MiG29:AddMissionCapability({AUFTRAG.Type.ESCORT}, 100)
RED.Squadrons.MiG29:AddMissionCapability({AUFTRAG.Type.ALERT5})
RED.Squadrons.MiG29:SetMissionRange(100)

RED.Squadrons.Su27 = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_CAP, 12, "RED_Su27")
RED.Squadrons.Su27:SetSkill(AI.Skill.EXCELLENT)
RED.Squadrons.Su27:SetFuelLowThreshold(0.4)
RED.Squadrons.Su27:SetFuelLowRefuel(true)
-- RED.Squadrons.Su27:SetGrouping(2)
RED.Squadrons.Su27:SetTakeoffHot()
RED.Squadrons.Su27:AddMissionCapability({AUFTRAG.Type.ORBIT, AUFTRAG.Type.GCICAP, AUFTRAG.Type.CAP}, 100)
RED.Squadrons.Su27:AddMissionCapability({AUFTRAG.Type.INTERCEPT}, 80)
RED.Squadrons.Su27:AddMissionCapability({AUFTRAG.Type.ESCORT}, 90)
RED.Squadrons.Su27:AddMissionCapability({AUFTRAG.Type.ALERT5})
RED.Squadrons.Su27:SetMissionRange(120)

RED.Squadrons.MiG31 = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, 3, "RED_MiG31")
RED.Squadrons.MiG31:SetSkill(AI.Skill.EXCELLENT)
RED.Squadrons.MiG31:SetFuelLowThreshold(0.4)
RED.Squadrons.MiG31:SetFuelLowRefuel(true)
-- RED.Squadrons.MiG31:SetGrouping(2)
RED.Squadrons.MiG31:SetTakeoffHot()
RED.Squadrons.MiG31:AddMissionCapability({AUFTRAG.Type.ORBIT, AUFTRAG.Type.GCICAP, AUFTRAG.Type.CAP}, 50)
RED.Squadrons.MiG31:AddMissionCapability({AUFTRAG.Type.INTERCEPT}, 100)
RED.Squadrons.MiG31:AddMissionCapability({AUFTRAG.Type.ESCORT}, 50)
RED.Squadrons.MiG31:AddMissionCapability({AUFTRAG.Type.ALERT5})
RED.Squadrons.MiG31:SetMissionRange(120)

--- Airbases of the Kola map
--
-- * AIRBASE.Kola.Banak
-- * AIRBASE.Kola.Bodo
-- * AIRBASE.Kola.Ivalo
-- * AIRBASE.Kola.Jokkmokk
-- * AIRBASE.Kola.Kalixfors
-- * AIRBASE.Kola.Kallax
-- * AIRBASE.Kola.Kemi_Tornio
-- * AIRBASE.Kola.Kirkenes
-- * AIRBASE.Kola.Kiruna
-- * AIRBASE.Kola.Kuusamo
-- * AIRBASE.Kola.Monchegorsk
-- * AIRBASE.Kola.Murmansk_International
-- * AIRBASE.Kola.Olenya
-- * AIRBASE.Kola.Rovaniemi
-- * AIRBASE.Kola.Severomorsk_1
-- * AIRBASE.Kola.Severomorsk_3
-- * AIRBASE.Kola.Vidsel
-- * AIRBASE.Kola.Vuojarvi
-- * AIRBASE.Kola.Andoya
-- * AIRBASE.Kola.Alakourtti
-- * AIRBASE.Kola.Kittila
-- * AIRBASE.Kola.Bardufoss
-- * AIRBASE.Kola.Alta
-- * AIRBASE.Kola.Sodankyla
-- * AIRBASE.Kola.Enontekio
-- * AIRBASE.Kola.Evenes
-- * AIRBASE.Kola.Hosio

RED.Airwings.Olenya=AIRWING:New("WH Olenya", "AW Olenya") --Ops.AirWing#AIRWING
RED.Airwings.Olenya:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Olenya))
RED.Airwings.Monchegorsk=AIRWING:New("WH Monchegorsk", "AW Monchegorsk")
RED.Airwings.Monchegorsk:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Monchegorsk))
RED.Airwings.Severomorsk_1=AIRWING:New("WH Severomorsk 1", "AW WH Severomorsk 1")
RED.Airwings.Severomorsk_1:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Severomorsk_1))
RED.Airwings.Murmansk_International=AIRWING:New("WH Murmansk_International", "AW Murmansk_International")
RED.Airwings.Murmansk_International:SetAirbase(AIRBASE:FindByName(AIRBASE.Kola.Murmansk_International))

RED.Airwings.Murmansk_International:AddSquadron(RED.Squadrons.AAR)
RED.Airwings.Murmansk_International:AddSquadron(RED.Squadrons.AWACS)
RED.Airwings.Monchegorsk:AddSquadron(RED.Squadrons.MiG29)
RED.Airwings.Severomorsk_1:AddSquadron(RED.Squadrons.MiG31)
RED.Airwings.Olenya:AddSquadron(RED.Squadrons.Su27)

RED.Airwings.Murmansk_International:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_AAR, -1, { AUFTRAG.Type.TANKER }, 100)
RED.Airwings.Murmansk_International:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_AWACS, -1, { AUFTRAG.Type.AWACS }, 100)
RED.Airwings.Severomorsk_1:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, -1, { AUFTRAG.Type.INTERCEPT }, 100)
RED.Airwings.Monchegorsk:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_MiG29_CAP, -1, { AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.PATROLZONE }, 100)
RED.Airwings.Monchegorsk:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_ESCORT, -1, { AUFTRAG.Type.ESCORT }, 100)
RED.Airwings.Olenya:NewPayload(TEMPLATE.AIR.ADVERSARY.RED_CAP, -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ESCORT, AUFTRAG.Type.GCICAP, AUFTRAG.Type.CAP }, 100)

RED.Airwings.Murmansk_International:AddPatrolPointTANKER(ZoneRedTankers, 28000, UTILS.KnotsToAltKIAS(363, 28000), 335, 30, Unit.RefuelingSystem.PROBE_AND_DROGUE)
-- RED.Airwings.Murmansk_International:AddPatrolPointAWACS(ZoneRedAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 335, 30)

RED.Airwings.Murmansk_International:SetNumberTankerProbe(1)
-- RED.Airwings.Murmansk_International:SetNumberAWACS(1)

Olena_Alert5_CAP=AUFTRAG:NewALERT5(AUFTRAG.Type.CAP)
Olena_Alert5_CAP:SetRequiredAssets(12)
RED.Airwings.Olenya:AddMission(Olena_Alert5_CAP)

Severomorsk_1_Alert5_INTERCEPT=AUFTRAG:NewALERT5(AUFTRAG.Type.INTERCEPT)
Severomorsk_1_Alert5_INTERCEPT:SetRequiredAssets(3)
RED.Airwings.Severomorsk_1:AddMission(Severomorsk_1_Alert5_INTERCEPT)

Monchegorsk_Alert5_ESCORT=AUFTRAG:NewALERT5(AUFTRAG.Type.ESCORT)
Monchegorsk_Alert5_ESCORT:SetRequiredAssets(6)
RED.Airwings.Monchegorsk:AddMission(Monchegorsk_Alert5_ESCORT)

Murmansk_International_Alert5_AWACS=AUFTRAG:NewALERT5(AUFTRAG.Type.AWACS)
Murmansk_International_Alert5_AWACS:SetRequiredAssets(2)
RED.Airwings.Murmansk_International:AddMission(Murmansk_International_Alert5_AWACS)

Murmansk_International_Alert5_TANKER=AUFTRAG:NewALERT5(AUFTRAG.Type.TANKER)
Murmansk_International_Alert5_TANKER:SetRequiredAssets(3)
RED.Airwings.Murmansk_International:AddMission(Murmansk_International_Alert5_TANKER)

Murmansk_International_Mission_AWACS=AUFTRAG:NewAWACS(ZoneRedAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 335, 30)
Murmansk_International_Mission_AWACS:SetPriority(1)
Murmansk_International_Mission_AWACS:SetRequiredAssets(1)
Murmansk_International_Mission_AWACS:AssignSquadrons({RED.Squadrons.AWACS})
Murmansk_International_Mission_AWACS:SetRequiredEscorts(1, 1)

RED.Commander = COMMANDER:New(coalition.side.BLUE)
RED.Commander:AddAirwing(RED.Airwings.Murmansk_International)
RED.Commander:AddAirwing(RED.Airwings.Severomorsk_1)
RED.Commander:AddAirwing(RED.Airwings.Monchegorsk)
RED.Commander:AddAirwing(RED.Airwings.Olenya)
RED.Commander:AddMission(Murmansk_International_Mission_AWACS)

-- RED.Commander:AddCapZone(ZoneRedCAP, 30000, UTILS.KnotsToAltKIAS(350, 33000), 320, 30)
-- RED.Commander:AddGciCapZone(ZoneRedCAP, 30000, UTILS.KnotsToAltKIAS(350, 30000), 320, 30)
-- RED.Commander:AddAwacsZone(ZoneRedAwacs, 33000, UTILS.KnotsToAltKIAS(363, 33000), 345, 30)
-- RED.Commander:AddTankerZone(ZoneRedTankers, 30000, UTILS.KnotsToAltKIAS(363, 33000), 345, 30, Unit.RefuelingSystem.PROBE_AND_DROGUE)

RED.Commander:__Start(1)
