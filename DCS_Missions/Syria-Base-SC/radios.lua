local frequencies = frequencies()

local f14_159 = {
    {"1", frequencies.freq_marshal},
    {"2", frequencies.freq_lso},
    {"3", frequencies.freq_awacs},
    {"4", frequencies.freq_aar},
    {"7", frequencies.freq_flight},
    {"12", frequencies.freq_incirlik_2},
    {"14", frequencies.freq_paphos_2},
    {"16", frequencies.freq_larnaca_2}
}
local f14_182 = {
    {"1", frequencies.freq_marshal},
    {"2", frequencies.freq_lso},
    {"3", frequencies.freq_awacs},
    {"4", frequencies.freq_aar},
    {"7", frequencies.freq_flight},
    {"10", frequencies.freq_sc},
    {"11", frequencies.freq_incirlik_1},
    {"12", frequencies.freq_incirlik_2},
    {"13", frequencies.freq_paphos_1},
    {"14", frequencies.freq_paphos_2},
    {"15", frequencies.freq_larnaca_1},
    {"16", frequencies.freq_larnaca_2}
}
local f16_164 = {
    {"3", frequencies.freq_awacs},
    {"4", frequencies.freq_aar},
    {"7", frequencies.freq_flight},
    {"12", frequencies.freq_incirlik_2},
    {"14", frequencies.freq_paphos_2},
    {"16", frequencies.freq_larnaca_2}
}
local f16_222 = {
    {"11", frequencies.freq_incirlik_1},
    {"13", frequencies.freq_paphos_1},
    {"15", frequencies.freq_larnaca_1}
}
local f18_210_1 = {
    {"1", frequencies.freq_marshal},
    {"2", frequencies.freq_lso},
    {"3", frequencies.freq_awacs},
    {"4", frequencies.freq_aar},
    {"7", frequencies.freq_flight},
    {"10", frequencies.freq_sc},
    {"11", frequencies.freq_incirlik_1},
    {"12", frequencies.freq_incirlik_2},
    {"13", frequencies.freq_paphos_1},
    {"14", frequencies.freq_paphos_2},
    {"15", frequencies.freq_larnaca_1},
    {"16", frequencies.freq_larnaca_2}
}
local f18_210_2 = {
    {"1", frequencies.freq_marshal},
    {"2", frequencies.freq_lso},
    {"3", frequencies.freq_awacs},
    {"4", frequencies.freq_aar},
    {"7", frequencies.freq_flight},
    {"10", frequencies.freq_sc},
    {"11", frequencies.freq_incirlik_1},
    {"12", frequencies.freq_incirlik_2},
    {"13", frequencies.freq_paphos_1},
    {"14", frequencies.freq_paphos_2},
    {"15", frequencies.freq_larnaca_1},
    {"16", frequencies.freq_larnaca_2}
}
local presets_data = {
    preset_f14_159 = f14_159,
    preset_f14_182 = f14_182,
    preset_f16_164 = f16_164,
    preset_f16_222 = f16_222,
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
    return info_preset(presets_data.preset_f14_159,"AN/ARC-159")
end

function info_preset_f14_182()
    return info_preset(presets_data.preset_f14_182,"AN/ARC-182")
end

function info_preset_f16_164()
    return info_preset(presets_data.preset_f16_164,"AN/ARC-164")
end

function info_preset_f16_222()
    return info_preset(presets_data.preset_f16_222,"AN/ARC-222")
end

function info_preset_f18_210_1()
    return info_preset(presets_data.preset_f18_210_1,"ARC-210-1")
end

function info_preset_f18_210_2()
    return info_preset(presets_data.preset_f18_210_2,"ARC-210-2")
end
