Squadron_Yaks = SQUADRON:New("Yaks", 2, "Yaks") --Ops.Squadron#SQUADRON
Squadron_Yaks:SetCallsign(CALLSIGN.Aircraft.Colt, 1)
Squadron_Yaks:SetSkill(AI.Skill.EXCELLENT)
Squadron_Yaks:SetFuelLowThreshold(0.3)
Squadron_Yaks:SetGrouping(2)
Squadron_Yaks:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)

Squadron_Bell = SQUADRON:New("Bell", 1, "Bell") --Ops.Squadron#SQUADRON
Squadron_Bell:SetCallsign(CALLSIGN.Aircraft.Colt, 2)
Squadron_Bell:SetSkill(AI.Skill.EXCELLENT)
Squadron_Bell:SetFuelLowThreshold(0.3)
Squadron_Bell:SetGrouping(1)
Squadron_Bell:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)

Squadron_Mosie = SQUADRON:New("Mosquito", 2, "Mosquito") --Ops.Squadron#SQUADRON
Squadron_Mosie:SetCallsign(CALLSIGN.Aircraft.Colt, 3)
Squadron_Mosie:SetSkill(AI.Skill.EXCELLENT)
Squadron_Mosie:SetFuelLowThreshold(0.3)
Squadron_Mosie:SetGrouping(2)
Squadron_Mosie:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)

Squadron_AWACS = SQUADRON:New("AWACS", 2, "AWACS")
Squadron_AWACS:SetCallsign(CALLSIGN.AWACS.Wizard, 1)
Squadron_AWACS:SetSkill(AI.Skill.EXCELLENT)
Squadron_AWACS:SetFuelLowThreshold(0.3)
Squadron_AWACS:SetFuelLowRefuel(true)
Squadron_AWACS:AddMissionCapability({ AUFTRAG.Type.AWACS }, 100)

Squadron_AAR = SQUADRON:New("AAR", 2, "AAR")
Squadron_AAR:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
Squadron_AAR:SetSkill(AI.Skill.EXCELLENT)
Squadron_AAR:SetFuelLowThreshold(0.3)
Squadron_AAR:SetFuelLowRefuel(false)
Squadron_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)


RedM19 = SQUADRON:New("M19", 20, "M19")
RedM19:SetSkill(AI.Skill.EXCELLENT)
RedM19:SetFuelLowThreshold(0.4)
RedM19:SetGrouping(2)
RedM19:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 100)

RedP51 = SQUADRON:New("P51", 20, "P51")
RedP51:SetSkill(AI.Skill.EXCELLENT)
RedP51:SetFuelLowThreshold(0.3)
RedP51:SetGrouping(3)
RedP51:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP }, 100)

