local ordered_elements_freq = {
    --FREQUENCIES.ELEMENTS.killer_uhf,
    --FREQUENCIES.ELEMENTS.killer_vhf,
    --FREQUENCIES.ELEMENTS.killer_fm,
    --FREQUENCIES.ELEMENTS.prayer_uhf,
    --FREQUENCIES.ELEMENTS.prayer_vhf,
}
local ordered_flight_freq = {
    FREQUENCIES.AWACS.darkstar,
    --FREQUENCIES.FLIGHTS.apache_1_uhf,
    --FREQUENCIES.FLIGHTS.apache_1_vhf,
    --FREQUENCIES.FLIGHTS.apache_1_fm,
    --FREQUENCIES.FLIGHTS.colt_1_fm,
	--FREQUENCIES.FLIGHTS.colt_2_uhf,
    --FREQUENCIES.FLIGHTS.colt_2_vhf,
    --FREQUENCIES.FLIGHTS.colt_2_fm,
	--FREQUENCIES.FLIGHTS.roman_1_uhf,
    --FREQUENCIES.FLIGHTS.roman_1_vhf,
	--FREQUENCIES.FLIGHTS.enfield_1_uhf,
    --FREQUENCIES.FLIGHTS.enfield_1_vhf,
}
local ordered_ground_freq = {
    FREQUENCIES.GROUND.atis_lcra,
    FREQUENCIES.GROUND.gnd_lcra_v,
    FREQUENCIES.GROUND.gnd_lcra_u,
    FREQUENCIES.GROUND.twr_lcra_v,
    FREQUENCIES.GROUND.twr_lcra_u,
    FREQUENCIES.GROUND.app_lcra_v,
    FREQUENCIES.GROUND.app_lcra_u
}
local ordered_special_freq = {
    FREQUENCIES.SPECIAL.guard_hi,
    FREQUENCIES.SPECIAL.guard_lo,
    FREQUENCIES.SPECIAL.ch_16
}
local ordered_tacan_data = {
    TACAN.sc,
    TACAN.arco,
    TACAN.shell_1,
}
local ordered_yardstick_data = {
    --ARDSTICKS.ninja_1,
}
local ordered_icls_data = {
    ICLS.sc,
}

function Msg(arg)
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

local elements_freqs_info = freq_text(ordered_elements_freq)
local flight_freqs_info = freq_text(ordered_flight_freq)
local ground_freqs_info = freq_text(ordered_ground_freq)
local special_freqs_info = freq_text(ordered_special_freq)
local tacan_info = tacans_text(ordered_tacan_data)
local yardsticks_info = yardsticks_text(ordered_yardstick_data)
local icls_info = icls_text(ordered_icls_data)

local freqs_info = elements_freqs_info .. flight_freqs_info .. ground_freqs_info .. special_freqs_info

MenuSeler = MENU_MISSION:New("Server Menu")

if (menu_show_freqs) then
    MenuFreq = MENU_MISSION:New("DATA", MenuSeler)
    MENU_MISSION_COMMAND:New("SPECIAL", MenuFreq, Msg, {special_freqs_info, 10})
    MENU_MISSION_COMMAND:New("ELEMENTS", MenuFreq, Msg, {elements_freqs_info, 10})
    MENU_MISSION_COMMAND:New("FLIGHTS", MenuFreq, Msg, {flight_freqs_info, 10})
    MENU_MISSION_COMMAND:New("GROUND", MenuFreq, Msg, {ground_freqs_info, 10})
    MENU_MISSION_COMMAND:New("TACAN", MenuFreq, Msg, {tacan_info, 10})
    MENU_MISSION_COMMAND:New("YARDSTICK", MenuFreq, Msg, {yardsticks_info, 10})
    MENU_MISSION_COMMAND:New("ICLS", MenuFreq, Msg, {icls_info, 10})
end

MenuFeatures = MENU_MISSION:New("Features", MenuSeler)

if (menu_dump_to_file) then
    save_to_file("freqs_info", freqs_info)
    save_to_file("tacan_info", tacan_info)
    save_to_file("yardstick_info", yardsticks_info)
    save_to_file("icls_info", icls_info)
end
