RedMANTIS = MANTIS:New("redemantis", "Red SAM", "Red EWR", nil, "red", false)
RedAcceptZONE = ZONE_POLYGON:NewFromGroupName("Red Accept Zone")
RedMANTIS:AddZones({RedAcceptZONE}, {}, {})
RedMANTIS:Start()