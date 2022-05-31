local debug_menu = false

local general_freqs = manual_ordered_frequencies()
local general_tacans = manual_ordered_tacans()
local general_icls = manual_ordered_icls()
-- local general_routing = air_routes()

local info_preset_f14_159 = info_preset_f14_159()
local info_preset_f14_182 = info_preset_f14_182()

local info_preset_f16_164 = info_preset_f16_164()
-- local info_preset_f16_222 = info_preset_f16_222()

local info_preset_f18_210_1 = info_preset_f18_210_1()
local info_preset_f18_210_2 = info_preset_f18_210_2()

local info_preset_mig21_832 = info_preset_mig21_832()

local info_preset_ru_heli_828 = info_preset_ru_heli_828()
local info_preset_ru_heli_863 = info_preset_ru_heli_863()

local function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

local function frequencies_text(general_freqs)
    local tmp_table = {}
    local msg = string.format("General frequencies in use: \n")
    table.insert(tmp_table, msg)
    for i, v in ipairs(general_freqs) do
        local tmp_string = string.format("%.2f -> %s \n", v[1], v[2])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function tacans_text(general_tacans)
    local tmp_table = {}
    local msg = string.format("TACANs in use: \n")
    table.insert(tmp_table, msg)
    for i, v in ipairs(general_tacans) do
        local tmp_string = string.format("Ch %d %s Code: %s -> %s \n", v[1], v[2], v[3], v[4])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function icls_text(general_icls)
    local tmp_table = {}
    local msg = string.format("ICLS/ILS in use: \n")
    table.insert(tmp_table, msg)
    for i, v in ipairs(general_icls) do
        local tmp_string = string.format("Ch %d Code: %s -> %s \n", v[1], v[2], v[3])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function back_course(to_course)
  local from_course = to_course + 180
  if from_course > 360 then
    from_course = from_course - 360
  end
  return from_course
end

local function routes_text(general_routing)
    local tmp_table = {}
    local msg = string.format("General Air Routes: \n")
    table.insert(tmp_table, msg)
    for i, v in ipairs(general_routing) do
      local tmp_string = string.format("%s - %s : %d - %d / %d\n", v[1], v[4], v[2], back_course(v[2]), v[3])
      table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local freqs_info = frequencies_text(general_freqs)
local tacan_info = tacans_text(general_tacans)
local icls_info = icls_text(general_icls)
-- local routes_info = routes_text(general_routing)

local presets_f14 = info_preset_f14_159 .. info_preset_f14_182

local presets_f16 = info_preset_f16_164

-- local presets_f16 = info_preset_f16_164 .. info_preset_f16_222

local presets_f18 = info_preset_f18_210_1 .. info_preset_f18_210_2

local presets_mig21 = info_preset_mig21_832

local presets_ka50 = info_preset_ru_heli_828

local presets_mi24 = info_preset_ru_heli_828 .. info_preset_ru_heli_863

local presets_mi8 = info_preset_ru_heli_828 .. info_preset_ru_heli_863

MenuSeler = MENU_MISSION:New("Seler Menu") --Główny kontener
local FrequenciesInfo = MENU_MISSION_COMMAND:New("Radio Frequiencies", MenuSeler, Msg, {freqs_info, 10})
local TacanInfo = MENU_MISSION_COMMAND:New("TACAN Frequiencies", MenuSeler, Msg, {tacan_info, 10})
local IclsInfo = MENU_MISSION_COMMAND:New("ICLS Frequiencies", MenuSeler, Msg, {icls_info, 10})
-- local RoutesInfo = MENU_MISSION_COMMAND:New("Air Routes", MenuSeler, Msg, {routes_info, 10})
local PresetsInfo = MENU_MISSION:New("Presets", MenuSeler)
local PresetsInfoF14 = MENU_MISSION_COMMAND:New("Presets F-14", PresetsInfo, Msg, {presets_f14, 10})
local PresetsInfoF16 = MENU_MISSION_COMMAND:New("Presets F-16", PresetsInfo, Msg, {presets_f16, 10})
local PresetsInfoF18 = MENU_MISSION_COMMAND:New("Presets F-18", PresetsInfo, Msg, {presets_f18, 10})
local PresetsInfoMig21 = MENU_MISSION_COMMAND:New("Presets MiG-21", PresetsInfo, Msg, {presets_mig21, 10})
local PresetsInfoKa50 = MENU_MISSION_COMMAND:New("Presets Ka-50", PresetsInfo, Msg, {presets_ka50, 10})
local PresetsInfoMi24 = MENU_MISSION_COMMAND:New("Presets Mi-24", PresetsInfo, Msg, {presets_mi24, 10})
local PresetsInfoMi8 = MENU_MISSION_COMMAND:New("Presets Mi-8", PresetsInfo, Msg, {presets_mi8, 10})

function menu_seler()
  return MenuSeler
end

if (debug_menu == true) then
    env.info(presets_f14)
    env.info(presets_f16)
    env.info(presets_f18)
    env.info(presets_mig21)
    env.info(presets_ka50)
    env.info(presets_mi24)
    env.info(presets_mi8)
    env.info(freqs_info)
    env.info(tacan_info)
    env.info(icls_info)
    -- env.info(routes_info)
end
