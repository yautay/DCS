Squadron_Yaks = SQUADRON:New("Yaks", 2, "Yaks") --Ops.Squadron#SQUADRON
Squadron_Yaks:SetCallsign(CALLSIGN.Aircraft.Colt, 1)
Squadron_Yaks:SetSkill(AI.Skill.EXCELLENT)
Squadron_Yaks:SetFuelLowThreshold(0.3)
Squadron_Yaks:SetGrouping(2)
Squadron_Yaks:AddMissionCapability({AUFTRAG.Type.ORBIT}, 100)

Squadron_Bell = SQUADRON:New("Bell", 1, "Bell") --Ops.Squadron#SQUADRON
Squadron_Bell:SetCallsign(CALLSIGN.Aircraft.Colt, 2)
Squadron_Bell:SetSkill(AI.Skill.EXCELLENT)
Squadron_Bell:SetFuelLowThreshold(0.3)
Squadron_Bell:SetGrouping(1)
Squadron_Bell:AddMissionCapability({AUFTRAG.Type.ORBIT}, 100)

Squadron_Mosie = SQUADRON:New("Mosquito", 2, "Mosquito") --Ops.Squadron#SQUADRON
Squadron_Mosie:SetCallsign(CALLSIGN.Aircraft.Colt, 3)
Squadron_Mosie:SetSkill(AI.Skill.EXCELLENT)
Squadron_Mosie:SetFuelLowThreshold(0.3)
Squadron_Mosie:SetGrouping(2)
Squadron_Mosie:AddMissionCapability({AUFTRAG.Type.ORBIT}, 100)