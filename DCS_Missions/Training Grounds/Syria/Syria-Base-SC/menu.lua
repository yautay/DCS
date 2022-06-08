local debug_menu = false
local dump_to_file = true

local ordered_flight_freq = {
    FREQUENCIES.SPECIAL.guard_hi,
    FREQUENCIES.SPECIAL.guard_lo,
    FREQUENCIES.SPECIAL.guard_fm,
    FREQUENCIES.FLIGHTS.flight_hi,
    FREQUENCIES.FLIGHTS.flight_lo,
    FREQUENCIES.FLIGHTS.flight_fm,
    FREQUENCIES.AWACS.darkstar,
    FREQUENCIES.AWACS.overlord,
    FREQUENCIES.AWACS.wizard,
    FREQUENCIES.AAR.common,
    FREQUENCIES.AAR.arco
}
local ordered_elint_freq = {
    FREQUENCIES.ELINT.allepo_hi,
    FREQUENCIES.ELINT.atis_allepo_hi,
    FREQUENCIES.ELINT.beirut_hi,
    FREQUENCIES.ELINT.atis_beirut_hi,
}
local ordered_ground_freq = {
    FREQUENCIES.CV.sc,
    FREQUENCIES.CV.lso,
    FREQUENCIES.CV.marshal,
    FREQUENCIES.GROUND.atis_ramat_david,
}
local ordered_tacan_data = {
    TACAN.sc,
    TACAN.arco,
    TACAN.shell,
    TACAN.texaco,
}
local ordered_icls_data = {
    ICLS.sc,
}

local info_preset_f14_159 = info_preset_f14_159()
local info_preset_f14_182 = info_preset_f14_182()

-- local info_preset_f16_164 = info_preset_f16_164()
-- local info_preset_f16_222 = info_preset_f16_222()

local info_preset_f18_210_1 = info_preset_f18_210_1()
local info_preset_f18_210_2 = info_preset_f18_210_2()

-- local info_preset_mig21_832 = info_preset_mig21_832()

-- local info_preset_ru_heli_828 = info_preset_ru_heli_828()
-- local info_preset_ru_heli_863 = info_preset_ru_heli_863()

local function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

local function freq_text(general_freqs)
    local tmp_table = {}
    local msg = string.format("General freq in use: \n")
    table.insert(tmp_table, msg)
    for i, v in ipairs(general_freqs) do
        local tmp_string = string.format("%.2f -> %s %s \n", v[1], v[2], v[3])
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
        local tmp_string = string.format("Ch %s Code: %s -> %s \n", v[1], v[2], v[3])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

-- local function back_course(to_course)
--   local from_course = to_course + 180
--   if from_course > 360 then
--     from_course = from_course - 360
--   end
--   return from_course
-- end

-- local function routes_text(general_routing)
--     local tmp_table = {}
--     local msg = string.format("General Air Routes: \n")
--     table.insert(tmp_table, msg)
--     for i, v in ipairs(general_routing) do
--       local tmp_string = string.format("%s - %s : %d - %d / %d\n", v[1], v[4], v[2], back_course(v[2]), v[3])
--       table.insert(tmp_table, tmp_string)
--     end
--     local final_msg = table.concat(tmp_table)
--     return final_msg .. "\n"
-- end

local flight_freqs_info = freq_text(ordered_flight_freq)
local elint_freqs_info = freq_text(ordered_elint_freq)
local ground_freqs_info = freq_text(ordered_ground_freq)
local tacan_info = tacans_text(ordered_tacan_data)
local icls_info = icls_text(ordered_icls_data)

local presets_f14 = info_preset_f14_159 .. info_preset_f14_182
-- local presets_f16 = info_preset_f16_164
-- local presets_f16 = info_preset_f16_164 .. info_preset_f16_222
local presets_f18 = info_preset_f18_210_1 .. info_preset_f18_210_2
-- local presets_mig21 = info_preset_mig21_832
-- local presets_ka50 = info_preset_ru_heli_828
-- local presets_mi24 = info_preset_ru_heli_828 .. info_preset_ru_heli_863
-- local presets_mi8 = info_preset_ru_heli_828 .. info_preset_ru_heli_863

MenuSeler = MENU_MISSION:New("Seler Menu")
MenuFreq = MENU_MISSION:New("Data", MenuSeler)
MenuPresets = MENU_MISSION:New("Presets", MenuSeler)

local freqInfo = MENU_MISSION_COMMAND:New("Flights", MenuFreq, Msg, {flight_freqs_info, 10})
local freqInfo = MENU_MISSION_COMMAND:New("ELINT", MenuFreq, Msg, {elint_freqs_info, 10})
local freqInfo = MENU_MISSION_COMMAND:New("Ground", MenuFreq, Msg, {ground_freqs_info, 10})

local TacanInfo = MENU_MISSION_COMMAND:New("TACAN", MenuFreq, Msg, {tacan_info, 10})
local IclsInfo = MENU_MISSION_COMMAND:New("ICLS", MenuFreq, Msg, {icls_info, 10})

local PresetsInfoF14 = MENU_MISSION_COMMAND:New("Presets F-14", MenuPresets, Msg, {presets_f14, 10})
-- local PresetsInfoF16 = MENU_MISSION_COMMAND:New("Presets F-16", MenuPresets, Msg, {presets_f16, 10})
local PresetsInfoF18 = MENU_MISSION_COMMAND:New("Presets F-18", MenuPresets, Msg, {presets_f18, 10})
-- local PresetsInfoMig21 = MENU_MISSION_COMMAND:New("Presets MiG-21", MenuPresets, Msg, {presets_mig21, 10})
-- local PresetsInfoKa50 = MENU_MISSION_COMMAND:New("Presets Ka-50", MenuPresets, Msg, {presets_ka50, 10})
-- local PresetsInfoMi24 = MENU_MISSION_COMMAND:New("Presets Mi-24", MenuPresets, Msg, {presets_mi24, 10})
-- local PresetsInfoMi8 = MENU_MISSION_COMMAND:New("Presets Mi-8", MenuPresets, Msg, {presets_mi8, 10})


if (dump_to_file) then
    save_to_file("presets_f14", presets_f14)
    -- save_to_file("presets_f16", presets_f16)
    save_to_file("presets_f18", presets_f18)
    -- save_to_file("presets_mig21", presets_mig21)
    -- save_to_file("presets_ka50", presets_ka50)
    -- save_to_file("presets_mi24", presets_mi24)
    -- save_to_file("presets_mi8", presets_mi8)
    save_to_file("freqs_info", freqs_info)
    save_to_file("tacan_info", tacan_info)
    save_to_file("icls_info", icls_info)
end
