AW_BLUE = AIRWING:New("WH Kutaisi", "Blue Air Wing")
AW_BLUE:SetMarker(false)
AW_BLUE:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
AW_BLUE:Start()

AW_BLUE:AddSquadron(BLUE_AWACS)
AW_BLUE:NewPayload("WIZARD", -1, { AUFTRAG.Type.ORBIT }, 100)
