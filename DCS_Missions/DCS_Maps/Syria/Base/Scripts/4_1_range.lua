RANGE:SetAutosaveOn()

function get_range_wx(ZoneObject)
    local CoordinateObject = ZoneObject:GetCoordinate()
    local pressure = CoordinateObject:GetPressureText()
    local temperature = CoordinateObject:GetTemperatureText()
    local wind_0 = CoordinateObject:GetWindText()
    local wind_1km = CoordinateObject:GetWindText(1000)
    local wind_3km = CoordinateObject:GetWindText(3000)
    local wind_6km = CoordinateObject:GetWindText(6000)
    local wx_data = {
        ["pressure"] = pressure,
        ["temperature"] = temperature,
        ["wind_0"] = wind_0,
        ["wind_1km"] = wind_1km,
        ["wind_3km"] = wind_3km,
        ["wind_6km"] = wind_6km,
    }
    BASE:E(wx_data)
    return wx_data
end

function iterate_set(SetObject)
    local set_data = {}
    set_data["names"] = {}
    SetObject:ForEachStatic(
        function(GroupObject)
            local object_name = GroupObject:GetName()
            local object_coordinates = GroupObject:GetCoordinate()
            local object_coordinates_lldms = object_coordinates:ToStringLLDMS()
            local object_coordinates_llddm = object_coordinates:ToStringLLDDM()
            local object_coordinate_mgrs = object_coordinates:ToStringMGRS()
            local object_coordinates_h = object_coordinates:GetLandHeight()
            set_data[object_name] = {
                    ["lldms"] = object_coordinates_lldms,
                    ["llddm"] = object_coordinates_llddm,
                    ["mgrs"] = object_coordinate_mgrs,
                    ["height_mtrs"] = object_coordinates_h,
                    ["height_ft"] = UTILS.MetersToFeet(object_coordinates_h)
            }
            BASE:E(object_name)
            table.insert(set_data["names"], object_name)
        end)
    return set_data
end

local RangeHatay=RANGE:New("Range Hatay")
--FIX DRAWIG
local zone_range_hatay = ZONE_POLYGON:New("Zone Range Hatay", GROUP:FindByName("Zone Range Hatay")):DrawZone(1, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.2, 0, true)

local set_range_hatay_strafepits = SET_STATIC:New():FilterPrefixes("Range Hatay Target Pit"):FilterStart()
local set_range_hatay_bombtargets = SET_STATIC:New():FilterPrefixes("Range Hatay Target Bomb"):FilterStart()

local dict_range_hatay_strafepits = iterate_set(set_range_hatay_strafepits)
local dict_hatay_bombtargets = iterate_set(set_range_hatay_bombtargets)
--SAVE REPORT
local dict_range_hatay_wx = get_range_wx(zone_range_hatay)

--RANGE.AddStrafePitGroup(group, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
RangeHatay:AddStrafePit(dict_range_hatay_strafepits.names, 3000, 500, 200, false, 10, 400)

--RANGE.AddBombingTargetGroup(group, goodhitrange, randommove)
BASE:E(dict_hatay_bombtargets.names)
RangeHatay:AddBombingTargets(dict_hatay_bombtargets.names, 20)

-- Start range.
RangeHatay:Start()

