RedMANTIS = MANTIS:New("redemantis", "Red SAM", "Red EWR", nil, "red", false)
RedMANTIS:AddZones({ZoneRedAccept}, {ZoneRedReject}, {ZoneRedDefend})
RedMANTIS:TraceOn()
RedMANTIS.verbose = true
RedMANTIS:Start()