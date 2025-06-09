Squadron_A50 = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AWACS, 1, "RED_AWACS")
Squadron_A50:SetSkill(AI.Skill.EXCELLENT)
Squadron_A50:SetFuelLowThreshold(0.3)
Squadron_A50:SetFuelLowRefuel(true)
Squadron_A50:SetTurnoverTime(10, 20)
Squadron_A50:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)

Squadron_A50_ESCORT = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.MIG21_PAIR, 6, "RED_AWACS_ESCORT") -- taking a template with 2 planes here, will result in a group of 2 escorts which can fly in formation escorting the AWACS.
Squadron_A50_ESCORT:AddMissionCapability({ AUFTRAG.Type.ESCORT })
Squadron_A50_ESCORT:SetFuelLowRefuel(false)
Squadron_A50_ESCORT:SetFuelLowThreshold(0.3)


-- Squadron_MRA_Viggen_F13 = SQUADRON:New(TEMPLATE.viggen_aa_light, 22, "F13 Squadron") --Ops.Squadron#SQUADRON
-- Squadron_MRA_Viggen_F13:SetCallsign(CALLSIGN.Aircraft.Colt, 1)
-- Squadron_MRA_Viggen_F13:SetSkill(AI.Skill.EXCELLENT)
-- --Squadron_MRA_Viggen_F13:SetRadio(VAR_KOLA.FREQUENCIES.FLIGHTS.vfma212_1_u[1])
-- Squadron_MRA_Viggen_F13:SetFuelLowThreshold(0.3)
-- Squadron_MRA_Viggen_F13:SetGrouping(2)
-- Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.BAI, AUFTRAG.Type.BOMBING, AUFTRAG.Type.BOMBRUNWAY }, 70)
-- Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 30)
-- Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 40)
-- Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 70)
--
Squadron_RED_CAP = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_CAP, 8, "RED_CAP")
Squadron_MRA_F1_SQ142:SetSkill(AI.Skill.EXCELLENT)
Squadron_MRA_F1_SQ142:SetFuelLowThreshold(0.3)
Squadron_MRA_F1_SQ142:SetFuelLowRefuel(true)
Squadron_MRA_F1_SQ142:SetGrouping(2)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 100)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 30)

Squadron_RED_INTERCEPT = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_INTERCEPT, 3, "RED_INTERCEPT")
Squadron_MRA_F1_SQ142:SetSkill(AI.Skill.EXCELLENT)
Squadron_MRA_F1_SQ142:SetFuelLowThreshold(0.3)
Squadron_MRA_F1_SQ142:SetFuelLowRefuel(true)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 50)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 100)

Squadron_RED_AAR = SQUADRON:New(TEMPLATE.AIR.ADVERSARY.RED_AAR, 2, "RED_AAR")
Squadron_MRA_F1_SQ142:SetSkill(AI.Skill.EXCELLENT)
Squadron_MRA_F1_SQ142:SetFuelLowThreshold(0.3)
Squadron_MRA_F1_SQ142:SetFuelLowRefuel(false)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.ORBIT, 100)