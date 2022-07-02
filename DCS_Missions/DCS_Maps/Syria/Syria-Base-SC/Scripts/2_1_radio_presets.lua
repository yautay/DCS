-- -- FM only 20,0/59,9
-- local ru_heli_828 = {
--     {"1", FREQUENCIES.GROUND.al_minhad_fm},
--     {"2", FREQUENCIES.FLIGHTS.flight_fm},
--     {"5", FREQUENCIES.ELINT.hormuz_fm},
--     {"6", FREQUENCIES.ELINT.atis_hormuz_fm},
--     {"7", FREQUENCIES.ELINT.kish_fm},
--     {"8", FREQUENCIES.ELINT.atis_kish_fm}
-- }
-- -- 100/399,9
-- local ru_heli_863 = {
--     {"0", FREQUENCIES.SPECIAL.guard_hi},
--     {"1", FREQUENCIES.FLIGHTS.flight_hi},
--     {"2", FREQUENCIES.AWACS.overlord},
--     {"3", FREQUENCIES.AWACS.darkstar},
--     {"4", FREQUENCIES.AWACS.wizard},
--     {"5", FREQUENCIES.ELINT.hormuz_hi},
--     {"6", FREQUENCIES.ELINT.atis_hormuz_hi},
--     {"7", FREQUENCIES.ELINT.kish_hi},
--     {"8", FREQUENCIES.ELINT.atis_kish_hi},
--     {"11", FREQUENCIES.GROUND.al_minhad_hi},
--     {"12", FREQUENCIES.GROUND.khasab_hi}
-- }
-- -- 118/390
-- local mig21_832 = {
--     {"0", FREQUENCIES.SPECIAL.guard_hi},
--     {"1", FREQUENCIES.FLIGHTS.flight_hi},
--     {"2", FREQUENCIES.AWACS.overlord},
--     {"3", FREQUENCIES.AWACS.darkstar},
--     {"4", FREQUENCIES.AWACS.wizard},
--     {"5", FREQUENCIES.ELINT.hormuz_hi},
--     {"6", FREQUENCIES.ELINT.atis_hormuz_hi},
--     {"7", FREQUENCIES.ELINT.kish_hi},
--     {"8", FREQUENCIES.ELINT.atis_kish_hi},
--     {"11", FREQUENCIES.GROUND.al_minhad_hi},
--     {"12", FREQUENCIES.GROUND.khasab_hi}
-- }
-- -- 225/399,97
local f14_159 = {
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.darkstar},
    {"4", FREQUENCIES.AWACS.wizard},
    {"5", FREQUENCIES.ELINT.allepo_hi},
    {"6", FREQUENCIES.ELINT.atis_allepo_hi},
    {"7", FREQUENCIES.ELINT.beirut_hi},
    {"8", FREQUENCIES.ELINT.atis_beirut_hi},
    {"9", FREQUENCIES.FLIGHTS.flight_hi},
    {"16", FREQUENCIES.AAR.common},
    {"17", FREQUENCIES.AAR.arco},
    {"18", FREQUENCIES.CV.marshal},
    {"19", FREQUENCIES.CV.lso},
    {"20", FREQUENCIES.SPECIAL.guard_hi},

}
-- -- 30/399,97
local f14_182 = {
    {"1", FREQUENCIES.CV.sc},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.darkstar},
    {"4", FREQUENCIES.AWACS.wizard},
    {"5", FREQUENCIES.ELINT.allepo_hi},
    {"6", FREQUENCIES.ELINT.atis_allepo_hi},
    {"7", FREQUENCIES.ELINT.beirut_hi},
    {"8", FREQUENCIES.ELINT.atis_beirut_hi},
    {"9", FREQUENCIES.FLIGHTS.flight_hi},
    {"11", FREQUENCIES.GROUND.atis_ramat_david},
    {"16", FREQUENCIES.AAR.common},
    {"17", FREQUENCIES.AAR.arco},
    {"18", FREQUENCIES.CV.marshal},
    {"19", FREQUENCIES.CV.lso},
    {"20", FREQUENCIES.SPECIAL.guard_hi},
    {"21", FREQUENCIES.SPECIAL.guard_lo},
    {"29", FREQUENCIES.FLIGHTS.flight_lo},
    {"30", FREQUENCIES.FLIGHTS.flight_fm},
}
-- -- 255/399,97
-- local f16_164 = {
--     {"5", FREQUENCIES.ELINT.hormuz_hi},
--     {"6", FREQUENCIES.ELINT.atis_hormuz_hi},
--     {"7", FREQUENCIES.ELINT.kish_hi},
--     {"8", FREQUENCIES.ELINT.atis_kish_hi},
--     {"11", FREQUENCIES.GROUND.al_minhad_hi},
--     {"12", FREQUENCIES.GROUND.khasab_hi},
-- }
-- -- 30/155,97
-- local f16_222 = {
--     {"2", FREQUENCIES.FLIGHTS.flight_lo},
--     {"5", FREQUENCIES.ELINT.hormuz_lo},
--     {"6", FREQUENCIES.ELINT.atis_hormuz_lo},
--     {"7", FREQUENCIES.ELINT.kish_lo},
--     {"8", FREQUENCIES.ELINT.atis_kish_lo},
--     {"11", FREQUENCIES.GROUND.al_minhad_lo},
--     {"20", FREQUENCIES.SPECIAL.guard_lo},
-- }
-- -- 30/399,97
local f18_210_1 = {
    {"1", FREQUENCIES.CV.sc},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.darkstar},
    {"4", FREQUENCIES.AWACS.wizard},
    {"5", FREQUENCIES.ELINT.allepo_hi},
    {"6", FREQUENCIES.ELINT.atis_allepo_hi},
    {"7", FREQUENCIES.ELINT.beirut_hi},
    {"8", FREQUENCIES.ELINT.atis_beirut_hi},
    {"9", FREQUENCIES.FLIGHTS.flight_hi},
    {"11", FREQUENCIES.GROUND.atis_ramat_david},
    {"16", FREQUENCIES.AAR.common},
    {"17", FREQUENCIES.AAR.arco},
    {"18", FREQUENCIES.CV.marshal},
    {"19", FREQUENCIES.CV.lso},
}
-- -- 30/399,97
local f18_210_2 = {
    {"1", FREQUENCIES.CV.sc},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.darkstar},
    {"4", FREQUENCIES.AWACS.wizard},
    {"5", FREQUENCIES.ELINT.allepo_hi},
    {"6", FREQUENCIES.ELINT.atis_allepo_hi},
    {"7", FREQUENCIES.ELINT.beirut_hi},
    {"8", FREQUENCIES.ELINT.atis_beirut_hi},
    {"9", FREQUENCIES.FLIGHTS.flight_hi},
    {"11", FREQUENCIES.GROUND.atis_ramat_david},
    {"16", FREQUENCIES.AAR.common},
    {"17", FREQUENCIES.AAR.arco},
    {"18", FREQUENCIES.CV.marshal},
    {"19", FREQUENCIES.CV.lso},
}
local presets_data = {
    preset_f14_159 = f14_159,
    preset_f14_182 = f14_182,
    -- preset_f16_164 = f16_164,
    -- preset_f16_222 = f16_222,
    preset_f18_210_1 = f18_210_1,
    preset_f18_210_2 = f18_210_2,
    -- preset_mig21_832 = mig21_832,
    -- preset_ru_heli_282 = ru_heli_828,
    -- preset_ru_heli_863 = ru_heli_863,
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

function info_preset_f14_159()
    return info_preset(presets_data.preset_f14_159, "AN/ARC-159")
end

function info_preset_f14_182()
    return info_preset(presets_data.preset_f14_182, "AN/ARC-182")
end

-- function info_preset_f16_164()
--     return info_preset(presets_data.preset_f16_164, "AN/ARC-164")
-- end

-- function info_preset_f16_222()
--     return info_preset(presets_data.preset_f16_222, "AN/ARC-222")
-- end

function info_preset_f18_210_1()
    return info_preset(presets_data.preset_f18_210_1, "ARC-210-1")
end

function info_preset_f18_210_2()
    return info_preset(presets_data.preset_f18_210_2, "ARC-210-2")
end

-- function info_preset_mig21_832()
--     return info_preset(presets_data.preset_mig21_832, "R-832")
-- end

-- function info_preset_ru_heli_828()
--     return info_preset(presets_data.preset_ru_heli_282, "R-828")
-- end

-- function info_preset_ru_heli_863()
--     return info_preset(presets_data.preset_ru_heli_863, "R-863")
-- end
