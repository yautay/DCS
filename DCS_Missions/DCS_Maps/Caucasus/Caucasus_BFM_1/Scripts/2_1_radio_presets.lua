-- 225/399,97
local f16_164 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    -- AAR
    -- 5 -> DESIGNATED TANKER
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    -- 19 -> SECTION
    -- 20 -> FLIGHT
}
-- 30/155,97
local f16_222 = {
    -- GROUND
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
-- 30/399,97
local f18_210_1 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    -- AAR
    -- 5 -> DESIGNATED TANKER
    -- CV
    {"9", FREQUENCIES.CV.sc},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
-- -- 30/399,97
local f18_210_2 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    -- AAR
    -- 5 -> DESIGNATED TANKER
    -- CV
    {"9", FREQUENCIES.CV.sc},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
local presets_data = {
    preset_f16_164 = f16_164,
    preset_f16_222 = f16_222,
    preset_f18_210_1 = f18_210_1,
    preset_f18_210_2 = f18_210_2,
}

local function info_preset(preset_data, radio_name)
    local tmp_table = {}
    local msg = string.format("Radio %s presets: \n", radio_name)
    table.insert(tmp_table, msg)
    for i, v in ipairs(preset_data) do
        local tmp_string = string.format("  Ch %s preset %.2f -> %s \n", v[1], v[2][1], v[2][2])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function info_preset_f16_164()
    return info_preset(presets_data.preset_f16_164, "AN/ARC-164")
end

local function info_preset_f16_222()
    return info_preset(presets_data.preset_f16_222, "AN/ARC-222")
end

local function info_preset_f18_210_1()
    return info_preset(presets_data.preset_f18_210_1, "ARC-210-1")
end

local function info_preset_f18_210_2()
    return info_preset(presets_data.preset_f18_210_2, "ARC-210-2")
end
