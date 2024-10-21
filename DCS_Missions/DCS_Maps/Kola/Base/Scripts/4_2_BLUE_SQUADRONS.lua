function get_aar_squadron(template_str, name_str, airframes_int, callsign_list, freq_list, tacan)
    local aar_squadron = SQUADRON:New(template_str, airframes_int, name_str)
    aar_squadron:SetCallsign(callsign_list[1], callsign_list[2])
    aar_squadron:SetSkill(AI.Skill.EXCELLENT)
    aar_squadron:SetRadio(freq_list[1], freq_list[3])
    aar_squadron:SetFuelLowThreshold(0.3)
    aar_squadron:AddTacanChannel(tacan[1], tacan[1])
    aar_squadron:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
    return aar_squadron
end

Squadron_AWACS_e3a = SQUADRON:New(TEMPLATE.e3a_awacs, 2, "5th AWACS Squadron")
Squadron_AWACS_e3a:SetCallsign(CALLSIGN.AWACS.Darkstar, 1)
Squadron_AWACS_e3a:SetSkill(AI.Skill.EXCELLENT)
Squadron_AWACS_e3a:SetRadio(VAR_KOLA.FREQUENCIES.AWACS.darkstar[1], VAR_KOLA.FREQUENCIES.AWACS.darkstar[3])
Squadron_AWACS_e3a:SetFuelLowThreshold(0.3)
Squadron_AWACS_e3a:SetFuelLowRefuel(true)
Squadron_AWACS_e3a:AddMissionCapability({ AUFTRAG.Type.AWACS }, 100)

Squadron_TANKER_kc135 = get_aar_squadron(
        TEMPLATE.tanker_kc135,
        "18th Air Refueling Squadron",
        1,
        { CALLSIGN.Tanker.Texaco, 1 },
        VAR_KOLA.FREQUENCIES.AAR.texaco_one,
        VAR_KOLA.TACAN.texaco_one)

Squadron_TANKER_kc135mprs = get_aar_squadron(
        TEMPLATE.tanker_kc135mprs,
        "Aerial Refueling Squadron Mariners",
        1,
        { CALLSIGN.Tanker.Shell, 1 },
        VAR_KOLA.FREQUENCIES.AAR.shell_one,
        VAR_KOLA.TACAN.shell_one)

Squadron_TANKER_kc10 = get_aar_squadron(
        TEMPLATE.tanker_kc10drouge,
        "Aerial Refueler Squadron 12 Extenders",
        1,
        { CALLSIGN.Tanker.Shell, 2 },
        VAR_KOLA.FREQUENCIES.AAR.shell_two,
        VAR_KOLA.TACAN.shell_two)

Squadron_TANKER_kc10_probe = get_aar_squadron(
        TEMPLATE.tanker_kc10,
        "Aerial Refueler Squadron 11 Extenders",
        1,
        { CALLSIGN.Tanker.Texaco, 2 },
        VAR_KOLA.FREQUENCIES.AAR.texaco_two,
        VAR_KOLA.TACAN.texaco_two)

Squadron_MRA_Viggen_F13 = SQUADRON:New(TEMPLATE.viggen_aa_light, 22, "F13 Squadron") --Ops.Squadron#SQUADRON
Squadron_MRA_Viggen_F13:SetCallsign(CALLSIGN.Aircraft.Colt, 1)
Squadron_MRA_Viggen_F13:SetSkill(AI.Skill.EXCELLENT)
--Squadron_MRA_Viggen_F13:SetRadio(VAR_KOLA.FREQUENCIES.FLIGHTS.vfma212_1_u[1])
Squadron_MRA_Viggen_F13:SetFuelLowThreshold(0.3)
Squadron_MRA_Viggen_F13:SetGrouping(2)
Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.BAI, AUFTRAG.Type.BOMBING, AUFTRAG.Type.BOMBRUNWAY }, 70)
Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 30)
Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 40)
Squadron_MRA_Viggen_F13:AddMissionCapability({ AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 70)

Squadron_MRA_F1_SQ142 = SQUADRON:New(TEMPLATE.f1_aa_light, 16, "SQ142 Squadron")
Squadron_MRA_F1_SQ142:SetCallsign(CALLSIGN.Aircraft.Colt, 2)
Squadron_MRA_F1_SQ142:SetSkill(AI.Skill.EXCELLENT)
--Squadron_MRA_F1_SQ142:SetRadio(VAR_KOLA.FREQUENCIES.FLIGHTS.vfma212_1_u[1])
Squadron_MRA_F1_SQ142:SetFuelLowThreshold(0.3)
Squadron_MRA_F1_SQ142:SetFuelLowRefuel(true)
Squadron_MRA_F1_SQ142:SetGrouping(2)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.BOMBRUNWAY }, 80)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.BAI }, 60)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 70)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.INTERCEPT }, 80)
Squadron_MRA_F1_SQ142:AddMissionCapability({ AUFTRAG.Type.STRIKE, AUFTRAG.Type.CAS, AUFTRAG.Type.SEAD }, 60)