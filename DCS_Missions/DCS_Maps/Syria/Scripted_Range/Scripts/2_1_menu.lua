local ordered_flight_freq = {
    FREQUENCIES.AWACS.darkstar,
    FREQUENCIES.AWACS.wizard,
    FREQUENCIES.AWACS.focus,
    FREQUENCIES.AAR.shell_1,
    FREQUENCIES.AAR.shell_2,
    FREQUENCIES.AAR.texaco_1,
    FREQUENCIES.AAR.arco,
}
local ordered_cvn = {
    FREQUENCIES.CV.dcs_sc,
    FREQUENCIES.CV.btn1,
    FREQUENCIES.CV.btn2,
    FREQUENCIES.CV.btn3,
    FREQUENCIES.CV.btn4,
    FREQUENCIES.CV.btn15,
    FREQUENCIES.CV.btn16,
    FREQUENCIES.CV.btn17,

}
local ordered_lha = {
    FREQUENCIES.LHA.dcs_sc,
    FREQUENCIES.LHA.tower,
    FREQUENCIES.LHA.radar,
}
local ordered_ground_freq = {
    FREQUENCIES.GROUND.atis_lcra,
    FREQUENCIES.GROUND.gnd_lcra_v,
    FREQUENCIES.GROUND.twr_lcra_v,
    FREQUENCIES.GROUND.app_lcra_v,
    FREQUENCIES.GROUND.gnd_lcra_u,
    FREQUENCIES.GROUND.twr_lcra_u,
    FREQUENCIES.GROUND.app_lcra_u,
}
local ordered_special_freq = {
    FREQUENCIES.SPECIAL.guard_hi,
    FREQUENCIES.SPECIAL.guard_lo,
    FREQUENCIES.SPECIAL.ch_16,
    FREQUENCIES.RANGE.bluewater_con,
    FREQUENCIES.RANGE.bluewater_inst,
}
local ordered_tacan_data = {
    TACAN.sc,
    TACAN.lha,
    TACAN.arco,
    TACAN.shell_1,
    TACAN.shell_2,
    TACAN.texaco_1
}

local ordered_icls_data = {
    ICLS.sc,
    ICLS.lha
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

local cvn_freqs_info = freq_text(ordered_cvn)
local lha_freqs_info = freq_text(ordered_lha)

local flight_freqs_info = freq_text(ordered_flight_freq)
local ground_freqs_info = freq_text(ordered_ground_freq)
local special_freqs_info = freq_text(ordered_special_freq)
local tacan_info = tacans_text(ordered_tacan_data)
local icls_info = icls_text(ordered_icls_data)

local freqs_info = flight_freqs_info .. ground_freqs_info .. cvn_freqs_info .. lha_freqs_info .. special_freqs_info

MenuSrver = MENU_MISSION:New("Server Menu")

if (menu_dump_to_file) then
    save_to_file("freqs_info", freqs_info)
    save_to_file("tacan_info", tacan_info)
    save_to_file("icls_info", icls_info)
end

info_msg=SOCKET:New()
info_msg:SendText(tacan_info)
info_msg:SendText(icls_info)
info_msg:SendText(freqs_info)
