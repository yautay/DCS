function get_aar_squadron(template_str, name_str, airframes_int, callsign_list, freq_list, tacan)
    local aar_squadron = SQUADRON:New(template_str, airframes_int, name_str)
    aar_squadron:SetCallsign(callsign_list[1], callsign_list[2])
    aar_squadron:SetSkill(AI.Skill.EXCELLENT)
    aar_squadron:SetRadio(freq_list[1], freq_list[3])
    aar_squadron:SetFuelLowThreshold(0.3)
    aar_squadron:AddTacanChannel(tacan[1], tacan[2])
    aar_squadron:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
    return aar_squadron
end

Squadron_AWACS_e3a = SQUADRON:New(TEMPLATE.AIR.AWACS.DARKSTAR, 4, "5th AWACS Squadron")
Squadron_AWACS_e3a:SetCallsign(CALLSIGN.AWACS.Darkstar, 1)
Squadron_AWACS_e3a:SetSkill(AI.Skill.EXCELLENT)
Squadron_AWACS_e3a:SetRadio(VAR_KOLA.FREQUENCIES.AWACS.darkstar[1], VAR_KOLA.FREQUENCIES.AWACS.darkstar[3])
Squadron_AWACS_e3a:SetFuelLowThreshold(0.3)
Squadron_AWACS_e3a:SetFuelLowRefuel(true)
Squadron_AWACS_e3a:SetTurnoverTime(10, 20)
Squadron_AWACS_e3a:AddMissionCapability({ AUFTRAG.Type.AWACS }, 100)

Squadron_TANKER_kc135 = get_aar_squadron(
        TEMPLATE.AIR.AAR.TEXACO,
        "18th Air Refueling Squadron",
        1,
        { CALLSIGN.Tanker.Texaco, 1 },
        VAR_KOLA.FREQUENCIES.AAR.texaco_one,
        VAR_KOLA.TACAN.texaco_one)

Squadron_TANKER_kc135mprs = get_aar_squadron(
        TEMPLATE.AIR.AAR.SHELL,
        "Aerial Refueling Squadron Mariners",
        1,
        { CALLSIGN.Tanker.Shell, 1 },
        VAR_KOLA.FREQUENCIES.AAR.shell_one,
        VAR_KOLA.TACAN.shell_one)

Squadron_ESCORTS_F15 = SQUADRON:New(TEMPLATE.AIR.AI.F15C_ESCORTS, 12, "Escorts F15") -- taking a template with 2 planes here, will result in a group of 2 escorts which can fly in formation escorting the AWACS.
Squadron_ESCORTS_F15:AddMissionCapability({ AUFTRAG.Type.ESCORT })
Squadron_ESCORTS_F15:SetFuelLowRefuel(true)
Squadron_ESCORTS_F15:SetFuelLowThreshold(0.3)
Squadron_ESCORTS_F15:SetTurnoverTime(10, 20)
Squadron_ESCORTS_F15:SetRadio(VAR_KOLA.FREQUENCIES.AWACS.darkstar[1], VAR_KOLA.FREQUENCIES.AWACS.darkstar[3])

Squadron_RELAY_HELI_CVN = SQUADRON:New(TEMPLATE.AIR.AI.RELAY_HELI, 12, "RELAY HELI CVN")
Squadron_RELAY_HELI_CVN:AddMissionCapability({ AUFTRAG.Type.PATROLZONE }, 100)
Squadron_RELAY_HELI_CVN:SetTakeoffHot()

Squadron_RELAY_HELI_LHA = SQUADRON:New(TEMPLATE.AIR.AI.RELAY_HELI, 12, "RELAY HELI LHA")
Squadron_RELAY_HELI_LHA:AddMissionCapability({ AUFTRAG.Type.PATROLZONE }, 100)
Squadron_RELAY_HELI_LHA:SetTakeoffHot()


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
-- Squadron_MRA_F1_SQ142 = SQUADRON:New(TEMPLATE.f1_aa_light, 16, "SQ142 Squadron")
-- Squadron_MRA_F1_SQ142:SetCallsign(CALLSIGN.Aircraft.Colt, 2)
-- Squadron_MRA_F1_SQ142:SetSkill(AI.Skill.EXCELLENT)
-- --Squadron_MRA_F1_SQ142:SetRadio(VAR_KOLA.FREQUENCIES.FLIGHTS.vfma212_1_u[1])
-- Squadron_MRA_F1_SQ142:SetFuelLowThreshold(0.3)
-- Squadron_MRA_F1_SQ142:SetFuelLowRefuel(true)
-- Squadron_MRA_F1_SQ142:SetGrouping(2)
-- Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.BOMBRUNWAY }, 80)
-- Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.BAI }, 60)
-- Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 70)
-- Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 80)
-- Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 60)
