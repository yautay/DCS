


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
            table.insert(set_data["names"], object_name)
        end)
    return set_data
end

function get_target_coordinates_report(list_from_iterate_set, string_report_title)
    local ReportObject = REPORT:New(string_report_title)
    for k, v in pairs(list_from_iterate_set) do
        if not k == "names" then
            ReportObject:Add(string.format("OBJECT: %s", k))
            ReportObject:Add(string.format("--- LLDMS: %s", v.lldms))
            ReportObject:Add(string.format("--- LLDDM: %s", v.llddm))
            ReportObject:Add(string.format("--- MGRS: %s", v.mgrs))
            ReportObject:Add(string.format("--- FT: %s", v.height_ft))
        end
    end
    local text = ReportObject:Text()
    env.info(text)
    return text
end

--STRAFE RANGE
local RangeHatayStrafe = RANGE:New("Range Hatay Strafe")
local zone_range_hatay_strafe = ZONE_POLYGON:New("Zone Range Hatay Strafe", GROUP:FindByName("Zone Range Hatay Strafe"))

local set_range_hatay_strafepit_E = SET_STATIC:New():FilterPrefixes("Range Hatay Target Pit E"):FilterStart()
local set_range_hatay_strafepit_W = SET_STATIC:New():FilterPrefixes("Range Hatay Target Pit W"):FilterStart()

local dict_range_hatay_strafepit_E = iterate_set(set_range_hatay_strafepit_E)
local dict_range_hatay_strafepit_W = iterate_set(set_range_hatay_strafepit_W)

--RANGE.AddStrafePitGroup(group, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
RangeHatayStrafe:AddStrafePit(dict_range_hatay_strafepit_E.names, 5000, 1200, 22, true, 10, 300)
RangeHatayStrafe:AddStrafePit(dict_range_hatay_strafepit_W.names, 5000, 1200, 22, true, 10, 300)

RangeHatayStrafe:SetRangeZone(zone_range_hatay_strafe)
RangeHatayStrafe:SetRangeControl(FREQUENCIES.GROUND.hatay_range_uhf[1], "Range Hatay Relay")
RangeHatayStrafe:SetInstructorRadio(FREQUENCIES.GROUND.hatay_range_uhf[1], "Range Hatay Relay")
RangeHatayStrafe:Start()

--BOMB RANGE
local RangeHatayBomb = RANGE:New("Range Hatay Bomb")
local zone_range_hatay_bomb = ZONE_POLYGON:New("Zone Range Hatay Bomb", GROUP:FindByName("Zone Range Hatay Bomb"))

local set_range_hatay_bombtarget_N = SET_STATIC:New():FilterPrefixes("Range Hatay Target Bomb N"):FilterStart()
local set_range_hatay_bombtarget_S = SET_STATIC:New():FilterPrefixes("Range Hatay Target Bomb S"):FilterStart()

local dict_hatay_bombtarget_N = iterate_set(set_range_hatay_bombtarget_N)
local dict_hatay_bombtarget_S = iterate_set(set_range_hatay_bombtarget_S)

--RANGE.AddBombingTargetGroup(group, goodhitrange, randommove)
RangeHatayBomb:AddBombingTargets(dict_hatay_bombtarget_N.names, 20)
RangeHatayBomb:AddBombingTargets(dict_hatay_bombtarget_S.names, 20)

RangeHatayBomb:SetRangeZone(zone_range_hatay_bomb)
RangeHatayBomb:SetRangeControl(FREQUENCIES.GROUND.hatay_range_uhf[1], "Range Hatay Relay")
RangeHatayBomb:SetInstructorRadio(FREQUENCIES.GROUND.hatay_range_uhf[1], "Range Hatay Relay")
RangeHatayBomb:Start()


local text_range_hatay_wx = get_range_wx(zone_range_hatay_strafe, "HATAY RANGE METEO")
MENU_MISSION_COMMAND:New("Hatay Range WX", MenuSeler, Msg, {text_range_hatay_wx, 10})

save_to_file("hatay_range_wx", text_range_hatay_wx)
save_to_file("hattay_range_bombtarget_n", get_target_coordinates_report(dict_hatay_bombtarget_N, "Bomb Targets North"))
save_to_file("hattay_range_bombtarget_s", get_target_coordinates_report(dict_hatay_bombtarget_S, "Bomb Targets South"))

RangeHatayBomb:SetAutosaveOn()
RangeHatayBomb:SetMessageTimeDuration(5)
RangeHatayBomb:SetSoundfilesPath("Range Soundfiles/")

RangeHatayStrafe:SetAutosaveOn()
RangeHatayStrafe:SetMaxStrafeAlt(5000)
RangeHatayStrafe:SetMessageTimeDuration(5)
RangeHatayStrafe:SetSoundfilesPath("Range Soundfiles/")