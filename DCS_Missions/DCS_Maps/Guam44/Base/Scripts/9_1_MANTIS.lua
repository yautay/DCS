RedMANTIS = MANTIS:New("redemantis", "Red SAM", "Red EWR", "Red HQ", "red", true, nil, true)
RedMANTIS:AddZones({ZoneRedAccept}, {ZoneRedReject}, nil)
-- RedMANTIS:Debug(true)
-- RedMANTIS.verbose = true
RedMANTIS:SetDetectInterval(10)
RedMANTIS:Start()

-- SCHEDULER:New(nil, function()
--   BASE:E(RedMANTIS.Detection)
-- end, {}, 5, 30)
