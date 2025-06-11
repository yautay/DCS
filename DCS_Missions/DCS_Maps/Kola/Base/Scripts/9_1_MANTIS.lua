RedMANTIS = MANTIS:New("redemantis", "Red SAM", "Red EWR", "Red HQ", "red", false)
RedMANTIS:AddZones({ZoneRedAccept}, {ZoneRedReject}, nil)
-- RedMANTIS:SetUsingEmOnOff(true)
RedMANTIS:SetDetectInterval(10)
RedMANTIS:Debug(true)
RedMANTIS.verbose = true
RedMANTIS:Start()