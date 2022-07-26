local zone_range_hatay = ZONE_POLYGON:New("Range-1", GROUP:FindByName("Range-1")):DrawZone(-1, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.2, 0, true)

-- Strafe pits. Each pit can consist of multiple targets. Here we have two pits and each of the pits has two targets.
-- These are names of the corresponding units defined in the ME.
local range_hatay_strafepit_west = {"Range-Hatay-Pit-W-1", "Range-Hatay-Pit-W-2"}
local range_hatay_strafepit_east = {"Range-Hatay-Pit-E-1", "Range-Hatay-Pit-E-1"}

 -- Table of bombing target names. Again these are the names of the corresponding units as defined in the ME.
local range_hatay_bombtargets = {"Range-Hatay-Bomb-S",
                                 "Range-Hatay-Bomb-C",
                                 "Range-Hatay-Bomb-N"}
 -- Create a range object.
RangeHatay=RANGE:New("Hatay Range")

 -- Distance between strafe target and foul line. You have to specify the names of the unit or static objects.
 -- Note that this could also be done manually by simply measuring the distance between the target and the foul line in the ME.

 -- Add strafe pits. Each pit (left and right) consists of two targets. Where "nil" is used as input, the default value is used.
RangeHatay:AddStrafePit(range_hatay_strafepit_west, 3000, 300, 200, false, 10, 700)
RangeHatay:AddStrafePit(range_hatay_strafepit_east, 3000, 300, 200, false, 20, 700)

 -- Add bombing targets. A good hit is if the bomb falls less then 50 m from the target.
RangeHatay:AddBombingTargets(range_hatay_bombtargets, 50)

 -- Start range.
RANGE:SetAutosaveOn()
RangeHatay:Start()
