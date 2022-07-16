local ordered_flight_freq = {
    FREQUENCIES.AWACS.darkstar,
    FREQUENCIES.AWACS.overlord,
    FREQUENCIES.AAR.shell_e,
    FREQUENCIES.AAR.shell_c,
    FREQUENCIES.AAR.shell_w,
    FREQUENCIES.AAR.texaco_e,
    FREQUENCIES.AAR.texaco_w,
    FREQUENCIES.FLIGHTS.sting_1,
	FREQUENCIES.FLIGHTS.joker_1,
    FREQUENCIES.FLIGHTS.hawk_1,
    FREQUENCIES.FLIGHTS.devil_1,
	FREQUENCIES.FLIGHTS.squid_1,
    FREQUENCIES.FLIGHTS.check_1,
    FREQUENCIES.FLIGHTS.viper_1,
	FREQUENCIES.FLIGHTS.venom_1,
    FREQUENCIES.FLIGHTS.jedi_1,
	FREQUENCIES.FLIGHTS.ninja_1,
}
local ordered_ground_freq = {
    FREQUENCIES.CV.sc,
    FREQUENCIES.GROUND.tower_vaziani,
    FREQUENCIES.GROUND.atis_vaziani,
    FREQUENCIES.GROUND.tower_kutaisi,
    FREQUENCIES.GROUND.atis_kutaisi,
}
local ordered_tacan_data = {
    TACAN.sc,
    TACAN.shell_e,
    TACAN.shell_c,
    TACAN.shell_w,
    TACAN.texaco_e,
    TACAN.texaco_w,
}
local ordered_yardstick_data = {
    YARDSTICKS.sting_1,
    YARDSTICKS.joker_1,
    YARDSTICKS.hawk_1,
    YARDSTICKS.devil_1,
    YARDSTICKS.squid_1,
    YARDSTICKS.check_1,
    YARDSTICKS.viper_1,
    YARDSTICKS.venom_1,
    YARDSTICKS.jedi_1,
    YARDSTICKS.ninja_1,
}
local ordered_icls_data = {
    ICLS.sc,
}

local info_preset_f16_164 = info_preset_f16_164()
local info_preset_f16_222 = info_preset_f16_222()

local info_preset_f18_210_1 = info_preset_f18_210_1()
local info_preset_f18_210_2 = info_preset_f18_210_2()

local function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

local function freq_text(general_freqs)
    local tmp_table = {}
    local msg = string.format("General freq in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_freqs) do
        local tmp_string = "empty"
        if (type(v[1]) == "string") then
            tmp_string = string.format("%s -> %s \n", v[1], v[2])
        else    
            tmp_string = string.format("%.2f -> %s %s \n", v[1], v[2], v[3])
        end
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function tacans_text(general_tacans)
    local tmp_table = {}
    local msg = string.format("TACANs in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_tacans) do
        local tmp_string = string.format("Ch %d %s Code: %s -> %s \n", v[1], v[2], v[3], v[4])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function yardsticks_text(general_yardsticks)
    local tmp_table = {}
    local msg = string.format("YARDSTICK's in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_yardsticks) do
        local tmp_string = string.format("%s -> Leader: %d <-> Wingman: %d (%s) \n", v[1], v[2], v[3], v[4])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function icls_text(general_icls)
    local tmp_table = {}
    local msg = string.format("ICLS/ILS in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_icls) do
        local tmp_string = string.format("Ch %s Code: %s -> %s \n", v[1], v[2], v[3])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local flight_freqs_info = freq_text(ordered_flight_freq)
local ground_freqs_info = freq_text(ordered_ground_freq)
local tacan_info = tacans_text(ordered_tacan_data)
local yardsticks_info = yardsticks_text(ordered_yardstick_data)
local icls_info = icls_text(ordered_icls_data)

local freqs_info = flight_freqs_info .. ground_freqs_info
local presets_f16 = info_preset_f16_164 .. info_preset_f16_222
local presets_f18 = info_preset_f18_210_1 .. info_preset_f18_210_2

MenuSeler = MENU_MISSION:New("Seler Menu")

if (menu_show_freqs) then
    MenuFreq = MENU_MISSION:New("Data", MenuSeler)
    MENU_MISSION_COMMAND:New("Flights", MenuFreq, Msg, {flight_freqs_info, 10})
    MENU_MISSION_COMMAND:New("Ground", MenuFreq, Msg, {ground_freqs_info, 10})
    MENU_MISSION_COMMAND:New("TACAN", MenuFreq, Msg, {tacan_info, 10})
    MENU_MISSION_COMMAND:New("YARDSTICK", MenuFreq, Msg, {yardsticks_info, 10})
    MENU_MISSION_COMMAND:New("ICLS", MenuFreq, Msg, {icls_info, 10})
end

if (menu_show_presets) then
    MenuPresets = MENU_MISSION:New("Presets", MenuSeler)
    MENU_MISSION_COMMAND:New("Presets F-16", MenuPresets, Msg, {presets_f16, 10})
    MENU_MISSION_COMMAND:New("Presets F-18", MenuPresets, Msg, {presets_f18, 10})
end

MenuFeatures = MENU_MISSION:New("Features", MenuSeler)

if (menu_dump_to_file) then
    save_to_file("presets_f16", presets_f16)
    save_to_file("presets_f18", presets_f18)
    save_to_file("freqs_info", freqs_info)
    save_to_file("tacan_info", tacan_info)
    save_to_file("yardstick_info", yardsticks_info)
    save_to_file("icls_info", icls_info)
end
