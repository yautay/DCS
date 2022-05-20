local radio_frequencies = frequencies()

local f14_159 = {
    {"1", radio_frequencies.freq_marshal},
    {"2", radio_frequencies.freq_lso},
    {"3", radio_frequencies.freq_awacs},
    {"4", radio_frequencies.freq_aar},
    {"7", radio_frequencies.freq_flight}
}
local f14_182 = {
    {"1", radio_frequencies.freq_marshal},
    {"2", radio_frequencies.freq_lso},
    {"3", radio_frequencies.freq_awacs},
    {"4", radio_frequencies.freq_aar},
    {"7", radio_frequencies.freq_flight},
    {"10", radio_frequencies.freq_sc},
    {"11", radio_frequencies.freq_al_minhad},
    {"12", radio_frequencies.freq_khasab}
}
local f16_164 = {
    {"3", radio_frequencies.freq_awacs},
    {"4", radio_frequencies.freq_aar},
    {"7", radio_frequencies.freq_flight},
    {"11", radio_frequencies.freq_al_minhad},
    {"12", radio_frequencies.freq_khasab}
}
-- local f16_222 = {
--     {"11", radio_frequencies.freq_incirlik_1},
--     {"13", radio_frequencies.freq_paphos_1},
--     {"15", radio_frequencies.freq_larnaca_1}
-- }
local f18_210_1 = {
    {"1", radio_frequencies.freq_marshal},
    {"2", radio_frequencies.freq_lso},
    {"3", radio_frequencies.freq_awacs},
    {"4", radio_frequencies.freq_aar},
    {"7", radio_frequencies.freq_flight},
    {"10", radio_frequencies.freq_sc},
    {"11", radio_frequencies.freq_al_minhad},
    {"12", radio_frequencies.freq_khasab}
}
local f18_210_2 = {
    {"1", radio_frequencies.freq_marshal},
    {"2", radio_frequencies.freq_lso},
    {"3", radio_frequencies.freq_awacs},
    {"4", radio_frequencies.freq_aar},
    {"7", radio_frequencies.freq_flight},
    {"10", radio_frequencies.freq_sc},
    {"11", radio_frequencies.freq_al_minhad},
    {"12", radio_frequencies.freq_khasab}
}
local presets_data = {
    preset_f14_159 = f14_159,
    preset_f14_182 = f14_182,
    preset_f16_164 = f16_164,
    -- preset_f16_222 = f16_222,
    preset_f18_210_1 = f18_210_1,
    preset_f18_210_2 = f18_210_2
}

function info_preset(preset_data, radio_name)
    local tmp_table = {}
    local msg = string.format("Radio %s presets: \n", radio_name)
    table.insert(tmp_table, msg)
    for i, v in ipairs(preset_data) do
        local tmp_string = string.format("  Ch %s preset %.2f -> %s \n", v[1], v[2][1], v[2][2])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    env.info(final_msg)
    return final_msg .. "\n"
end

function info_preset_f14_159()
    return info_preset(presets_data.preset_f14_159, "AN/ARC-159")
end

function info_preset_f14_182()
    return info_preset(presets_data.preset_f14_182, "AN/ARC-182")
end

function info_preset_f16_164()
    return info_preset(presets_data.preset_f16_164, "AN/ARC-164")
end

-- function info_preset_f16_222()
--     return info_preset(presets_data.preset_f16_222, "AN/ARC-222")
-- end

function info_preset_f18_210_1()
    return info_preset(presets_data.preset_f18_210_1, "ARC-210-1")
end

function info_preset_f18_210_2()
    return info_preset(presets_data.preset_f18_210_2, "ARC-210-2")
end
