local zone_range_hatay = ZONE_POLYGON:New("Range-1", GROUP:FindByName("Range-1")):DrawZone(2, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.2, 0, true)

-- Strafe pits. Each pit can consist of multiple targets. Here we have two pits and each of the pits has two targets.
-- These are names of the corresponding units defined in the ME.
local range_hatay_strafepit_west = {"Range-Hatay-Pit-W-1", "Range-Hatay-Pit-W-2"}
local range_hatay_strafepit_east = {"Range-Hatay-Pit-E-1", "Range-Hatay-Pit-E-1"}

 -- Table of bombing target names. Again these are the names of the corresponding units as defined in the ME.
local range_hatay_bombtargets = {"Range-Hatay-Bomb-S",
                                 "Range-Hatay-Bomb-C",
                                 "Range-Hatay-Bomb-N"}
local range_hatay_airstrip = {"Range-Hatay-Strip-1",
                              "Range-Hatay-Strip-2",
                              "Range-Hatay-Strip-3",
                              "Range-Hatay-Strip-4"}
 -- Create a range object.
RangeHatay=RANGE:New("Hatay Range")

 -- Distance between strafe target and foul line. You have to specify the names of the unit or static objects.
 -- Note that this could also be done manually by simply measuring the distance between the target and the foul line in the ME.
RangeHatay:GetFoullineDistance(100)

 -- Add strafe pits. Each pit (left and right) consists of two targets. Where "nil" is used as input, the default value is used.
RangeHatay:AddStrafePit(range_hatay_strafepit_west, 3000, 300, 200, false, 10, 500)
RangeHatay:AddStrafePit(range_hatay_strafepit_east, 3000, 300, 200, false, 20, 500)

 -- Add bombing targets. A good hit is if the bomb falls less then 50 m from the target.
RangeHatay:AddBombingTargets(range_hatay_bombtargets, 50)
RangeHatay:AddBombingTargets(range_hatay_airstrip, 10)

 -- Start range.
RANGE:SetAutosaveOn()
RangeHatay:Start()

range_hatay_set_bomb_targets = SET_STATIC:New():FilterPrefixes("Range-Hatay-Bomb")
range_hatay_set_strafe_pits = SET_STATIC:New():FilterPrefixes("Range-Hatay-Pit")
range_hatay_set_airstrip_target = SET_STATIC:New():FilterPrefixes("Range-Hatay-Strip")
range_hatay_set_bomb_targets_data = {}
range_hatay_set_strafe_pits_data = {}
range_hatay_set_airstrip_target_data = {}

function callback_range_object(static_object, data_list)
    table.insert(data_list, data_extractor_static_object(static_object))
end

range_hatay_set_bomb_targets:ForEachStatic(callback_range_object, {range_hatay_set_bomb_targets_data})
range_hatay_set_strafe_pits:ForEachStatic(callback_range_object, {range_hatay_set_strafe_pits_data})
range_hatay_set_airstrip_target:ForEachStatic(callback_range_object, {range_hatay_set_airstrip_target_data})