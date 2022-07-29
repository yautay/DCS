RANGE:SetAutosaveOn()

function get_range_wx(ZoneObject, string_report_title)
    local CoordinateObject = ZoneObject:GetCoordinate()
    local sunrise = CoordinateObject:GetSunrise(false)
    local sunset = CoordinateObject:GetSunset(false)
    local qnh = CoordinateObject:GetPressureText(0)
    local qfe = CoordinateObject:GetPressureText(CoordinateObject:GetLandHeight())
    local temperature = CoordinateObject:GetTemperatureText(CoordinateObject:GetLandHeight())
    local wind_0 = CoordinateObject:GetWindText()
    local wind_1km = CoordinateObject:GetWindText(1000)
    local wind_3km = CoordinateObject:GetWindText(3000)
    local wind_6km = CoordinateObject:GetWindText(6000)
    local wx_data = {
        ["sunrise"] = sunrise,
        ["sunset"] = sunset,
        ["QNH"] = qnh,
        ["QFE"] = qfe,
        ["temperature"] = temperature,
        ["wind_0"] = wind_0,
        ["wind_1km"] = wind_1km,
        ["wind_3km"] = wind_3km,
        ["wind_6km"] = wind_6km,
    }
    local ReportObject = REPORT:New(string_report_title)
    ReportObject:Add(string.format("Sunrise: %s", wx_data.sunrise))
    ReportObject:Add(string.format("Sunset: %s", wx_data.sunset))
    ReportObject:Add(string.format("QNH: %s", wx_data.QNH))
    ReportObject:Add(string.format("QFE: %s", wx_data.QFE))
    ReportObject:Add(string.format("Temperature: %s", wx_data.temperature))
    ReportObject:Add(string.format("Wind @ground: %s", wx_data.wind_0))
    ReportObject:Add(string.format("Wind @3k: %s", wx_data.wind_1km))
    ReportObject:Add(string.format("Wind @10k: %s", wx_data.wind_3km))
    ReportObject:Add(string.format("Wind @20k: %s", wx_data.wind_6km))
    return ReportObject:Text()
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

local zone_range_hatay = ZONE_POLYGON:New("Zone Range Hatay", GROUP:FindByName("Zone Range Hatay"))
        :DrawZone(-1, CONST.RGB.range, 1, CONST.RGB.range, 1, 1, true)
local zone_range_hatay_farp = ZONE:New("Zone FARP Hatay Range")
        :DrawZone(-1, CONST.RGB.farp, 1, CONST.RGB.farp, 1, 1, true)

local set_range_hatay_strafepit_E = SET_STATIC:New():FilterPrefixes("Range Hatay Target Pit E"):FilterStart()
local set_range_hatay_strafepit_W = SET_STATIC:New():FilterPrefixes("Range Hatay Target Pit W"):FilterStart()
local set_range_hatay_bombtarget_N = SET_STATIC:New():FilterPrefixes("Range Hatay Target Bomb N"):FilterStart()
local set_range_hatay_bombtarget_C = SET_STATIC:New():FilterPrefixes("Range Hatay Target Bomb C"):FilterStart()
local set_range_hatay_bombtarget_S = SET_STATIC:New():FilterPrefixes("Range Hatay Target Bomb S"):FilterStart()

local dict_range_hatay_strafepit_E = iterate_set(set_range_hatay_strafepit_E)
local dict_range_hatay_strafepit_W = iterate_set(set_range_hatay_strafepit_W)
local dict_hatay_bombtarget_N = iterate_set(set_range_hatay_bombtarget_N)
local dict_hatay_bombtarget_C = iterate_set(set_range_hatay_bombtarget_C)
local dict_hatay_bombtarget_S = iterate_set(set_range_hatay_bombtarget_S)

local text_range_hatay_wx = get_range_wx(zone_range_hatay, "HATAY RANGE METEO")
save_to_file("hatay_range_wx", text_range_hatay_wx)


--RANGE.AddStrafePitGroup(group, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
RangeHatay:AddStrafePit(dict_range_hatay_strafepit_E.names, 3000, 300, 200, false, 10, 400)
RangeHatay:AddStrafePit(dict_range_hatay_strafepit_W.names, 3000, 300, 200, false, 10, 400)

--RANGE.AddBombingTargetGroup(group, goodhitrange, randommove)
RangeHatay:AddBombingTargets(dict_hatay_bombtarget_N.names, 10)
RangeHatay:AddBombingTargets(dict_hatay_bombtarget_C.names, 20)
RangeHatay:AddBombingTargets(dict_hatay_bombtarget_S.names, 30)

RangeHatay:AddBombingTargetGroup(GROUP:FindByName("Range Hatay Target Trucks"), 20)
RangeHatay:AddBombingTargetGroup(GROUP:FindByName("Range Hatay Target Tanks"), 20)

RangeHatay:SetRangeZone(zone_range_hatay)
RangeHatay:SetRangeControl(FREQUENCIES.GROUND.hatay_range_uhf[1], "Range Hatay Relay")
RangeHatay:Start()


MENU_MISSION_COMMAND:New("Hatay Range WX", MenuSeler, Msg, {text_range_hatay_wx, 10})
