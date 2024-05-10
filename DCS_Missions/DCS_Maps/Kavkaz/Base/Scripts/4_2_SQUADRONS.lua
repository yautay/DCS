Squadron_Yaks = SQUADRON:New("Yaks", 10, "Yaks") --Ops.Squadron#SQUADRON
Squadron_Yaks:SetCallsign(CALLSIGN.Aircraft.Colt, 1)
Squadron_Yaks:SetSkill(AI.Skill.EXCELLENT)
Squadron_Yaks:SetFuelLowThreshold(0.3)
Squadron_Yaks:SetGrouping(2)
Squadron_Yaks:AddMissionCapability({AUFTRAG.Type.ORBIT}, 100)