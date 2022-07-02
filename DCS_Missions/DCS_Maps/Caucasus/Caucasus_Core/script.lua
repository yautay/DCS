
-- ### 1 VARIABLES ###
-- ###########################################################
-- ###                       VARIABLES                     ###
-- ###########################################################
FREQUENCIES = {
    ELINT = {
        vaziani_hi = {255.00, "Sector Vaziani UHF", "AM"},
        vaziani_lo = {123.00, "Sector Vaziani VHF", "AM"},
        vaziani_fm = {35.00, "Sector Vaziani HF", "FM"},
        atis_vaziani_hi = {255.50, "Sector Vaziani ATIS UHF", "AM"},
        atis_vaziani_lo = {123.50, "Sector Vaziani ATIS VHF", "AM"},
        atis_vaziani_fm = {35.50, "Sector Vaziani ATIS HF", "FM"},
        kutaisi_hi = {256.00, "Sector Kutaisi UHF", "AM"},
        kutaisi_lo = {124.00, "Sector Kutaisi VHF", "AM"},
        kutaisi_fm = {36.00, "Sector Kutaisi HF", "FM"},
        atis_kutaisi_hi = {256.50, "Sector Kutaisi ATIS UHF", "AM"},
        atis_kutaisi_lo = {124.50, "Sector Kutaisi ATIS VHF", "AM"},
        atis_kutaisi_fm = {36.50, "Sector Kutaisi ATIS HF", "FM"}
    },
    AWACS = {
        darkstar = {242.00, "AWACS Darkstar UHF", "AM"},
        overlord = {242.50, "AWACS Overlord UHF", "AM"},
        wizard = {247.70, "AWACS Wizard UHF", "AM"}
    },
    AAR = {
        common = {251.00, "TANKERS BIG BIRDS UHF", "AM"},
        arco = {243.50, "TANKER Arco UHF", "AM"}
    },
    FLIGHTS = {
		hornet_1 = {"MIDS 1", "SQUID MIDS", ""},
		hornet_1_1 = {"MIDS 11", "SQUID ONE MIDS", ""},
        hornet_1_2 = {"MIDS 12", "SQUID TWO MIDS", ""},
        hornet_2 = {"MIDS 2", "HAWK MIDS", ""},
		hornet_2_1 = {"MIDS 21", "HAWK ONE MIDS", ""},
		hornet_2_2 = {"MIDS 22", "HAWK TWO MIDS", ""},
		hornet_3 = {"MIDS 3", "SNAKE MIDS", ""},
		hornet_3_1 = {"MIDS 31", "SNAKE ONE MIDS", ""},
		hornet_3_2 = {"MIDS 32", "SNAKE TWO MIDS", ""},
		hornet_4 = {"MIDS 4", "CHECK MIDS", ""},
		hornet_4_1 = {"MIDS 41", "CHECK ONE MIDS", ""},
		hornet_4_2 = {"MIDS 42", "CHECK TWO MIDS", ""},
	    viper_1 = {271.00, "VIPER UHF", "AM"},
        viper_1_1 = {271.50, "VIPER ONE UHF", "AM"},
		viper_1_2 = {271.75, "VIPER TWO UHF", "AM"},
		viper_2 = {272.00, "JEDI UHF", "AM"},
		viper_2_1 = {272.50, "JEDI ONE UHF", "AM"},
		viper_2_2 = {272.75, "JEDI TWO UHF", "AM"},
        viper_3 = {273.00, "NINJA UHF", "AM"},
		viper_3_1 = {273.50, "NINJA ONE UHF", "AM"},
		viper_3_2 = {273.75, "NINJA TWO UHF", "AM"},
        pontiac_1 = {274.00, "PONTIAC UHF", "AM"},
        pontiac_1_1 = {274.25, "PONTIAC ONE UHF", "AM"},
        pontiac_1_2 = {274.50, "PONTIAC TWO UHF", "AM"},
        pontiac_1_3 = {274.75, "PONTIAC THREE UHF", "AM"},
        ford_1 = {275.25, "FORD ONE UHF", "AM"},
        ford_2 = {275.50, "FORD TWO UHF", "AM"},
        ford_1 = {275.25, "FORD ONE UHF", "AM"},
        ford_2 = {275.50, "FORD TWO UHF", "AM"},
        springfield_1 = {275.75, "SPRINGFIELD ONE UHF", "AM"},
        pig_1 = {274.00, "PIG ONE UHF", "AM"},
        ag_drone = {301.00, "AG DRONE UHF", "AM"}
    },
    CV = {
        lso = {260.00, "CV-75 LSO UHF", "AM"},
        marshal = {260.50, "CV-75 Marshal UHF", "AM"},
        sc = {127.50, "CV-75 Tower VHF", "AM"}
    },
    GROUND = {
        atis_vaziani = {118.75, "ATIS Vaziani VHF", "AM"},
        atis_kutaisi = {118.25, "ATIS Kutaisi VHF", "AM"},
        tower_vaziani = {269.00, "Tower Vaziani UHF", "AM"},
        tower_kutaisi = {263.00, "Tower Kutaisi UHF", "AM"},
    },
    SPECIAL = {
        guard_hi = {243.00, "Guard Freq UHF", "AM"},
        guard_lo = {121.5, "Guard Freq VHF", "AM"},
    }
}
ICLS = {
    sc = {1, "CV", "ICLS CVN-75"},
}
TACAN = {
    sc = {74, "X", "CVN", "CVN-75"},
    arco = {1, "Y", "RCV", "Recovery Tanker CVN-75"},
    shell_e = {51, "Y", "SHE", "Tanker Shell East Boom"},
    shell_w = {53, "Y", "SHW", "Tanker Shell West Boom"},
    texaco_e = {52, "Y", "TEE", "Tanker Texaco East Probe"},
    texaco_w = {54, "Y", "TEW", "Tanker Texaco West Probe"},
    pvp = {69, "X", "PVP", "PvP Training Zone (on request)"},
    ag = {88, "Y", "AG", "AG Training Zone (on request)"},
}
YARDSTICKS = {
    hornet_1_1 = {"SQUID ONE", 37, 100, "Y"},
    hornet_1_2 = {"SQUID TWO", 38, 101, "Y"},
    hornet_2_1 = {"HAWK ONE", 39, 102, "Y"},
    hornet_2_2 = {"HAWK TWO", 40, 103, "Y"},
    hornet_3_1 = {"SNAKE ONE", 41, 104, "Y"},
    hornet_3_2 = {"SNAKE TWO", 42, 105, "Y"},
    hornet_4_1 = {"CHECK ONE", 43, 106, "Y"},
    hornet_4_2 = {"CHECK TWO", 44, 107, "Y"},
    viper_1_1 = {"VIPER ONE", 45, 108, "Y"},
    viper_1_2 = {"VIPER TWO", 46, 109, "Y"},
    viper_2_1 = {"JEDI ONE", 47, 110, "Y"},
    viper_2_2 = {"JEDI TWO", 48, 111, "Y"},
    viper_3_1 = {"NINJA ONE", 49, 112, "Y"},
    viper_3_2 = {"NINJA TWO", 50, 113, "Y"},
    pig_1 = {"PIG ONE", 51, 114, "Y"},
}

_SETTINGS:SetPlayerMenuOff()

--AIRWINGS
-- Vaziani
aw_vaziani = true
aw_vaziani_cap = false
aw_vaziani_escort = false
debug_aw_vaziani = false

-- Vaziani
aw_kutaisi = true
aw_kutaisi_cap = false
aw_kutaisi_escort = false
debug_aw_kutaisi = false

-- Mozdok
aw_mozdok = true
debug_aw_mozdok = false

-- FEATURES
-- Airboss
airboss = true
debug_airbos = false
-- FOX Trainer
fox_trainer = true
-- AG Range
ag_range = true
-- ELINT
elint = true
debug_elint = false
-- ATIS
atis = true
-- CSAR
csar = true
debug_csar = false
-- AWACS
cvn_awacs = true
moose_awacs_rejection_red_zone = false
debug_awacs = false
-- IADS
skynet_lib = false
-- iads_blue = false
-- iads_red = false
-- debug_blueiads = false
-- debug_rediads = false

menu_dump_to_file = true
menu_show_freqs = true
menu_show_presets = true

debug_menu = false
-- ### 2 COMMON ###
-- ###########################################################
-- ###            COMMON OBJECTS AND FUNCTIONS             ###
-- ###########################################################
borderRed = ZONE_POLYGON:New("Red Zone", GROUP:FindByName("ZONE-RED-BORDER"))
borderBlue = ZONE_POLYGON:New("Blue Zone", GROUP:FindByName("ZONE-BLUE-BORDER"))

zoneWarbirds = ZONE_POLYGON:New("Warbirds Sector", GROUP:FindByName("ZONE-Piston"))


function save_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"w")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end

function append_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"a")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end
-- ### 3 RADIO PRESETS ###
-- ###########################################################
-- ###                    RADIO PRESETS                    ###
-- ###########################################################

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
local ru_heli_863 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- CV
    {"7", FREQUENCIES.CV.marshal},
    {"9", FREQUENCIES.CV.sc},
    -- ELINT
    {"10", FREQUENCIES.ELINT.vaziani_hi},
    {"11", FREQUENCIES.ELINT.atis_vaziani_hi},
    {"12", FREQUENCIES.ELINT.kutaisi_hi},
    {"13", FREQUENCIES.ELINT.atis_kutaisi_hi},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
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
-- 225/399,97
local f14_159 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- CV
    {"7", FREQUENCIES.CV.marshal},
    {"8", FREQUENCIES.CV.lso},
    -- ELINT
    {"10", FREQUENCIES.ELINT.vaziani_hi},
    {"11", FREQUENCIES.ELINT.atis_vaziani_hi},
    {"12", FREQUENCIES.ELINT.kutaisi_hi},
    {"13", FREQUENCIES.ELINT.atis_kutaisi_hi},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    -- 19 -> SECTION
    -- 20 -> FLIGHT
}
-- 30/399,97
local f14_182 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- CV
    {"7", FREQUENCIES.CV.marshal},
    {"8", FREQUENCIES.CV.lso},
    {"9", FREQUENCIES.CV.sc},
    -- ELINT
    {"10", FREQUENCIES.ELINT.vaziani_hi},
    {"11", FREQUENCIES.ELINT.atis_vaziani_hi},
    {"12", FREQUENCIES.ELINT.kutaisi_hi},
    {"13", FREQUENCIES.ELINT.atis_kutaisi_hi},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
    -- 19 -> SECTION
    -- 20 -> FLIGHT
}
-- 225/399,97
local f16_164 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- ELINT
    {"10", FREQUENCIES.ELINT.vaziani_hi},
    {"11", FREQUENCIES.ELINT.atis_vaziani_hi},
    {"12", FREQUENCIES.ELINT.kutaisi_hi},
    {"13", FREQUENCIES.ELINT.atis_kutaisi_hi},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    -- 19 -> SECTION
    -- 20 -> FLIGHT
}
-- 30/155,97
local f16_222 = {
    -- ELINT
    {"10", FREQUENCIES.ELINT.vaziani_lo},
    {"11", FREQUENCIES.ELINT.atis_vaziani_lo},
    {"12", FREQUENCIES.ELINT.kutaisi_lo},
    {"13", FREQUENCIES.ELINT.atis_kutaisi_lo},
    -- GROUND
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
-- 30/399,97
local f18_210_1 = {
    -- AWACS
    {"1", FREQUENCIES.AWACS.darkstar},
    {"2", FREQUENCIES.AWACS.overlord},
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- CV
    {"7", FREQUENCIES.CV.marshal},
    {"8", FREQUENCIES.CV.lso},
    {"9", FREQUENCIES.CV.sc},
    -- ELINT
    {"10", FREQUENCIES.ELINT.vaziani_hi},
    {"11", FREQUENCIES.ELINT.atis_vaziani_hi},
    {"12", FREQUENCIES.ELINT.kutaisi_hi},
    {"13", FREQUENCIES.ELINT.atis_kutaisi_hi},
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
    {"3", FREQUENCIES.AWACS.wizard},
    -- AAR
    {"5", FREQUENCIES.AAR.common},
    {"6", FREQUENCIES.AAR.arco},
    -- CV
    {"7", FREQUENCIES.CV.marshal},
    {"8", FREQUENCIES.CV.lso},
    {"9", FREQUENCIES.CV.sc},
    -- ELINT
    {"10", FREQUENCIES.ELINT.vaziani_hi},
    {"11", FREQUENCIES.ELINT.atis_vaziani_hi},
    {"12", FREQUENCIES.ELINT.kutaisi_hi},
    {"13", FREQUENCIES.ELINT.atis_kutaisi_hi},
    -- GROUND
    {"15", FREQUENCIES.GROUND.tower_vaziani},
    {"16", FREQUENCIES.GROUND.atis_vaziani},
    {"17", FREQUENCIES.GROUND.tower_kutaisi},
    {"18", FREQUENCIES.GROUND.atis_kutaisi},
}
local presets_data = {
    preset_f14_159 = f14_159,
    preset_f14_182 = f14_182,
    preset_f16_164 = f16_164,
    preset_f16_222 = f16_222,
    preset_f18_210_1 = f18_210_1,
    preset_f18_210_2 = f18_210_2,
    -- preset_mig21_832 = mig21_832,
    -- preset_ru_heli_282 = ru_heli_828,
    preset_ru_heli_863 = ru_heli_863,
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

local function info_preset_f14_159()
    return info_preset(presets_data.preset_f14_159, "AN/ARC-159")
end

local function info_preset_f14_182()
    return info_preset(presets_data.preset_f14_182, "AN/ARC-182")
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

-- local function info_preset_mig21_832()
--     return info_preset(presets_data.preset_mig21_832, "R-832")
-- end

-- local function info_preset_ru_heli_828()
--     return info_preset(presets_data.preset_ru_heli_282, "R-828")
-- end

local function info_preset_ru_heli_863()
    return info_preset(presets_data.preset_ru_heli_863, "R-863")
end

-- ### 4 MENU ###
-- ###########################################################
-- ###                   SELER MENU                        ###
-- ###########################################################

local ordered_flight_freq = {
    FREQUENCIES.AWACS.darkstar,
    FREQUENCIES.AWACS.overlord,
    FREQUENCIES.AWACS.wizard,
    FREQUENCIES.AAR.common,
    FREQUENCIES.AAR.arco,
    FREQUENCIES.FLIGHTS.hornet_1,
	FREQUENCIES.FLIGHTS.hornet_1_1,
    FREQUENCIES.FLIGHTS.hornet_1_2,
    FREQUENCIES.FLIGHTS.hornet_2,
	FREQUENCIES.FLIGHTS.hornet_2_1,
    FREQUENCIES.FLIGHTS.hornet_2_2,
    FREQUENCIES.FLIGHTS.hornet_3,
	FREQUENCIES.FLIGHTS.hornet_3_1,
    FREQUENCIES.FLIGHTS.hornet_3_2,
	FREQUENCIES.FLIGHTS.hornet_4,
	FREQUENCIES.FLIGHTS.hornet_4_1,
    FREQUENCIES.FLIGHTS.hornet_4_2,
	FREQUENCIES.FLIGHTS.viper_1,
	FREQUENCIES.FLIGHTS.viper_1_1,
	FREQUENCIES.FLIGHTS.viper_1_2,
    FREQUENCIES.FLIGHTS.viper_2,
	FREQUENCIES.FLIGHTS.viper_2_1,
	FREQUENCIES.FLIGHTS.viper_2_1,
    FREQUENCIES.FLIGHTS.viper_3,
	FREQUENCIES.FLIGHTS.viper_3_1,
	FREQUENCIES.FLIGHTS.viper_3_2,
    FREQUENCIES.FLIGHTS.pontiac_1,
    FREQUENCIES.FLIGHTS.pontiac_1_1,
    FREQUENCIES.FLIGHTS.pontiac_1_2,
    FREQUENCIES.FLIGHTS.pontiac_1_3,
    FREQUENCIES.FLIGHTS.springfield_1,
    FREQUENCIES.FLIGHTS.springfield_2,
    FREQUENCIES.FLIGHTS.springfield_3,
    FREQUENCIES.FLIGHTS.pig_1,
    FREQUENCIES.FLIGHTS.ford_1,
    FREQUENCIES.FLIGHTS.ford_2,
	FREQUENCIES.FLIGHTS.ag_drone,
}
local ordered_elint_freq = {
    FREQUENCIES.ELINT.vaziani_hi,
    FREQUENCIES.ELINT.vaziani_lo,
    FREQUENCIES.ELINT.atis_vaziani_hi,
    FREQUENCIES.ELINT.atis_vaziani_lo,
    FREQUENCIES.ELINT.kutaisi_hi,
    FREQUENCIES.ELINT.kutaisi_lo,
    FREQUENCIES.ELINT.atis_kutaisi_hi,
    FREQUENCIES.ELINT.atis_kutaisi_lo,
}
local ordered_ground_freq = {
    FREQUENCIES.CV.sc,
    FREQUENCIES.CV.lso,
    FREQUENCIES.CV.marshal,
    FREQUENCIES.GROUND.tower_vaziani,
    FREQUENCIES.GROUND.atis_vaziani,
    FREQUENCIES.GROUND.tower_kutaisi,
    FREQUENCIES.GROUND.atis_kutaisi,
}
local ordered_tacan_data = {
    TACAN.sc,
    TACAN.arco,
    TACAN.shell_e,
    TACAN.shell_w,
    TACAN.texaco_e,
    TACAN.texaco_w,
    TACAN.pvp,
    TACAN.ag,
}
local ordered_yardstick_data = {
    YARDSTICKS.hornet_1_1,
    YARDSTICKS.hornet_1_2,
    YARDSTICKS.hornet_2_1,
    YARDSTICKS.hornet_2_2,
    YARDSTICKS.hornet_3_1,
    YARDSTICKS.hornet_3_2,
    YARDSTICKS.hornet_4_1,
    YARDSTICKS.hornet_4_2,
    YARDSTICKS.viper_1_1,
    YARDSTICKS.viper_1_2,
    YARDSTICKS.viper_2_1,
    YARDSTICKS.viper_2_2,
    YARDSTICKS.viper_3_1,
    YARDSTICKS.viper_3_2,
    YARDSTICKS.pig_1,
}
local ordered_icls_data = {
    ICLS.sc,
}

local info_preset_f14_159 = info_preset_f14_159()
local info_preset_f14_182 = info_preset_f14_182()

local info_preset_f16_164 = info_preset_f16_164()
local info_preset_f16_222 = info_preset_f16_222()

local info_preset_f18_210_1 = info_preset_f18_210_1()
local info_preset_f18_210_2 = info_preset_f18_210_2()

-- local info_preset_mig21_832 = info_preset_mig21_832()

-- local info_preset_ru_heli_828 = info_preset_ru_heli_828()
local info_preset_ru_heli_863 = info_preset_ru_heli_863()

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
local yardsticks_info = yardsticks_text(ordered_yardstick_data)
local icls_info = icls_text(ordered_icls_data)

local freqs_info = flight_freqs_info .. ground_freqs_info .. elint_freqs_info
local presets_f14 = info_preset_f14_159 .. info_preset_f14_182
local presets_f16 = info_preset_f16_164
local presets_f16 = info_preset_f16_164 .. info_preset_f16_222
local presets_f18 = info_preset_f18_210_1 .. info_preset_f18_210_2
-- local presets_mig21 = info_preset_mig21_832
-- local presets_ka50 = info_preset_ru_heli_828
-- local presets_mi24 = info_preset_ru_heli_828 .. info_preset_ru_heli_863
-- local presets_mi8 = info_preset_ru_heli_828 .. info_preset_ru_heli_863
local presets_ru_863 = info_preset_ru_heli_863

MenuSeler = MENU_MISSION:New("Seler Menu")

if (menu_show_freqs) then
    MenuFreq = MENU_MISSION:New("Data", MenuSeler)
    local freqInfo = MENU_MISSION_COMMAND:New("Flights", MenuFreq, Msg, {flight_freqs_info, 10})
    local freqInfo = MENU_MISSION_COMMAND:New("ELINT", MenuFreq, Msg, {elint_freqs_info, 10})
    local freqInfo = MENU_MISSION_COMMAND:New("Ground", MenuFreq, Msg, {ground_freqs_info, 10})
    local TacanInfo = MENU_MISSION_COMMAND:New("TACAN", MenuFreq, Msg, {tacan_info, 10})
    local YardstickInfo = MENU_MISSION_COMMAND:New("YARDSTICK", MenuFreq, Msg, {yardsticks_info, 10})
    local IclsInfo = MENU_MISSION_COMMAND:New("ICLS", MenuFreq, Msg, {icls_info, 10})
end

if (menu_show_presets) then
    MenuPresets = MENU_MISSION:New("Presets", MenuSeler)
    local PresetsInfoF14 = MENU_MISSION_COMMAND:New("Presets F-14", MenuPresets, Msg, {presets_f14, 10})
    local PresetsInfoF16 = MENU_MISSION_COMMAND:New("Presets F-16", MenuPresets, Msg, {presets_f16, 10})
    local PresetsInfoF18 = MENU_MISSION_COMMAND:New("Presets F-18", MenuPresets, Msg, {presets_f18, 10})
    -- local PresetsInfoMig21 = MENU_MISSION_COMMAND:New("Presets MiG-21", MenuPresets, Msg, {presets_mig21, 10})
    -- local PresetsInfoKa50 = MENU_MISSION_COMMAND:New("Presets Ka-50", MenuPresets, Msg, {presets_ka50, 10})
    -- local PresetsInfoMi24 = MENU_MISSION_COMMAND:New("Presets Mi-24", MenuPresets, Msg, {presets_mi24, 10})
    -- local PresetsInfoMi8 = MENU_MISSION_COMMAND:New("Presets Mi-8", MenuPresets, Msg, {presets_mi8, 10})
    local PresetsInfoRu863 = MENU_MISSION_COMMAND:New("Presets R-863", MenuPresets, Msg, {presets_ru_863, 10})
end

MenuFeatures = MENU_MISSION:New("Features", MenuSeler)

if (menu_dump_to_file) then
    save_to_file("presets_f14", presets_f14)
    save_to_file("presets_f16", presets_f16)
    save_to_file("presets_f18", presets_f18)
    -- save_to_file("presets_mig21", presets_mig21)
    -- save_to_file("presets_ka50", presets_ka50)
    -- save_to_file("presets_mi24", presets_mi24)
    -- save_to_file("presets_mi8", presets_mi8)
    save_to_file("presets_r863", presets_ru_863)
    save_to_file("freqs_info", freqs_info)
    save_to_file("tacan_info", tacan_info)
    save_to_file("yardstick_info", yardsticks_info)
    save_to_file("icls_info", icls_info)
end

-- ### 5 ATIS ###
-- ###########################################################
-- ###                      ATIS                           ###
-- ###########################################################

AtisVaziani = ATIS:New(AIRBASE.Caucasus.Vaziani, FREQUENCIES.GROUND.atis_vaziani[1])
AtisVaziani:SetRadioRelayUnitName("RELAY-VAZIANI")
AtisVaziani:SetTACAN(22)
AtisVaziani:SetTowerFrequencies({269.00})
AtisVaziani:AddILS(108.75, "13")
AtisVaziani:AddILS(108.75, "31")
AtisVaziani:AddNDBinner(368.00)
AtisVaziani:SetSRS(SRS_PATH, "female", "en-US")
AtisVaziani:SetMapMarks()
AtisVaziani:Start()

AtisKutaisi = ATIS:New(AIRBASE.Caucasus.Kutaisi, FREQUENCIES.GROUND.atis_kutaisi[1])
AtisKutaisi:SetRadioRelayUnitName("RELAY-VAZIANI")
AtisKutaisi:SetTACAN(44)
AtisKutaisi:SetVOR(113.60)
AtisKutaisi:SetTowerFrequencies({263.00})
AtisKutaisi:AddILS(109.75, "07")
AtisKutaisi:SetSRS(SRS_PATH, "female", "en-US")
AtisKutaisi:SetMapMarks()
AtisKutaisi:__Start(5)

-- ### 6 ELINT ###
-- ###########################################################
-- ###                      ELINT                          ###
-- ###########################################################

local function setup_sectors(template_sectors)
    for i, v in pairs(template_sectors) do
        HoundBlue:addSector(v[1])
        HoundBlue:setZone(v[1],v[2])
        HoundBlue:enableController(v[1],v[3])
        HoundBlue:enableAlerts(v[1])
        if (atis) then
            HoundBlue:enableAtis(v[1],v[4])
        end
        HoundBlue:reportEWR(v[1],true)
    end
end

local function create_radio(freq, mod, gender)
    local radio = {
        freq = freq,
        modulation = mod,
        gender = gender
    }
    return radio
end

local function create_atis_radio(freq, mod)
    local radio = {
        freq = freq,
        modulation = mod
    }
    return radio
end

  -- TTS SETTINGS
-- local vaziani_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.vaziani_hi[1],FREQUENCIES.ELINT.vaziani_lo[1],FREQUENCIES.ELINT.vaziani_fm[1])
-- local atis_vaziani_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_vaziani_hi[1],FREQUENCIES.ELINT.atis_vaziani_lo[1],FREQUENCIES.ELINT.atis_vaziani_fm[1])
-- local kutaisi_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.kutaisi_hi[1],FREQUENCIES.ELINT.kutaisi_lo[1],FREQUENCIES.ELINT.kutaisi_fm[1])
-- local atis_kutaisi_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_kutaisi_hi[1],FREQUENCIES.ELINT.atis_kutaisi_lo[1],FREQUENCIES.ELINT.atis_kutaisi_fm[1])
-- local vaziani_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.vaziani_hi[3],FREQUENCIES.ELINT.vaziani_lo[3],FREQUENCIES.ELINT.vaziani_fm[3])
-- local kutaisi_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.kutaisi_hi[3],FREQUENCIES.ELINT.kutaisi_lo[3],FREQUENCIES.ELINT.kutaisi_fm[3])

local vaziani_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.vaziani_hi[1],FREQUENCIES.ELINT.vaziani_lo[1])
local atis_vaziani_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.atis_vaziani_hi[1],FREQUENCIES.ELINT.atis_vaziani_lo[1])
local kutaisi_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.kutaisi_hi[1],FREQUENCIES.ELINT.kutaisi_lo[1])
local atis_kutaisi_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.atis_kutaisi_hi[1],FREQUENCIES.ELINT.atis_kutaisi_lo[1])
local vaziani_modulation = string.format("%s,%s",FREQUENCIES.ELINT.vaziani_hi[3],FREQUENCIES.ELINT.vaziani_hi[3])
local kutaisi_modulation = string.format("%s,%s",FREQUENCIES.ELINT.kutaisi_hi[3],FREQUENCIES.ELINT.vaziani_hi[3])

local notifier_freq = string.format("%2f,%2f",FREQUENCIES.SPECIAL.guard_hi[1], FREQUENCIES.SPECIAL.guard_lo[1])
local notifier_modulation = string.format("%s,%s",FREQUENCIES.SPECIAL.guard_hi[3], FREQUENCIES.SPECIAL.guard_lo[3])

local controler_args = {
    vaziani = create_radio(vaziani_freq, vaziani_modulation, "male"),
    kutaisi = create_radio(kutaisi_freq, kutaisi_modulation, "male")

}
local atis_args = { 
    vaziani = create_atis_radio(atis_vaziani_freq, vaziani_modulation),
    kutaisi = create_atis_radio(atis_kutaisi_freq, kutaisi_modulation)
}

local notifier_args = {
    freq = notifier_freq,
    modulation = notifier_modulation,
    gender = "male"
}

local sector_templates = {
    {"Vaziani", "Sector Vaziani", controler_args.vaziani, atis_args.vaziani},
    {"Kutaisi", "Sector Kutaisi", controler_args.kutaisi, atis_args.kutaisi}
}

local zone_vaziani = ZONE_POLYGON:New("Sector Vaziani", GROUP:FindByName("ELINT VAZIANI")):DrawZone(2, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.2, 0, true)
local zone_kutaisi = ZONE_POLYGON:New("Sector Kutaisi", GROUP:FindByName("ELINT KUTAISI")):DrawZone(2, {1,0,0}, 1, {1,0,0}, 0.2, 0, true)


HoundBlue = HoundElint:create(coalition.side.BLUE)

setup_sectors(sector_templates)

-- MISC
HOUND.setMgrsPresicion(3)
HOUND.showExtendedInfo(false)
HoundBlue:setTimerInterval("scan",10)
HoundBlue:setTimerInterval("process",10)
HoundBlue:setTimerInterval("menus",20)
HoundBlue:setTimerInterval("markers",20)
HoundBlue:setTimerInterval("display",20)

-- ATIS
HoundBlue:setAtisUpdateInterval(2*60)

-- NOTIFIER
HoundBlue:enableNotifier()

-- FUNCTIONAL CONFIG
HoundBlue:setMarkerType(HOUND.MARKER.OCTAGON)
HoundBlue:enableMarkers()
HoundBlue:enableBDA()
HoundBlue:enableText("all")

-- PRE BRIEFED
-- HoundBlue:preBriefedContact("red-sa5-1-sr")
-- HoundBlue:preBriefedContact("red-sa5-1-tr")
-- HoundBlue:preBriefedContact("red-sa2-1-tr")
-- HoundBlue:preBriefedContact("red-sa2-1-sr")

-- ON
HoundBlue:systemOn()

if (debug_elint) then
    HoundBlue:onScreenDebug (true)
end
-- ### 7 AIRBOSS ###
-- ###########################################################
-- ###                        AIRBOSS                      ###
-- ###########################################################

-- F10 Map Markings

ZONE:New("CV-1"):GetCoordinate(0):LineToAll(ZONE:New("CV-2"):GetCoordinate(0), -1, {0, 0, 1}, 1, 4, true)

-- S-3B Recovery Tanker
tanker = RECOVERYTANKER:New(UNIT:FindByName("CVN"), "ME CVN AAR")
tanker:SetRacetrackDistances(15, 5)
tanker:SetRadio(FREQUENCIES.AAR.arco[1])
tanker:SetCallsign(CALLSIGN.Tanker.Arco)
tanker:SetTACAN(TACAN.arco[1], TACAN.arco[3])
tanker:Start()

-- E-2D AWACS_cv
if (cvn_awacs) then
    awacs_cv = RECOVERYTANKER:New("CVN", "ME CVN AWACS")
    awacs_cv:SetAWACS()
    awacs_cv:SetRadio(FREQUENCIES.AWACS.wizard[1])
    awacs_cv:SetAltitude(22000)
    awacs_cv:SetCallsign(CALLSIGN.AWACS.Wizard)
    awacs_cv:SetRacetrackDistances(20, 10)
    awacs_cv:SetTACANoff()
    awacs_cv:Start()
end

-- Rescue Helo
rescuehelo = RESCUEHELO:New(UNIT:FindByName("CVN"), "ME CVN SAR")
rescuehelo:Start()

-- AIRBOSS object.
Airboss = AIRBOSS:New("CVN")
Airboss:SetTACAN(TACAN.sc[1], TACAN.sc[2], TACAN.sc[3])
Airboss:SetICLS(ICLS.sc[1], ICLS.sc[2])
Airboss:SetMarshalRadio(FREQUENCIES.CV.marshal[1], FREQUENCIES.CV.marshal[3])
Airboss:SetLSORadio(FREQUENCIES.CV.lso[1])
Airboss:SetQueueUpdateTime(10)

Airboss:AddRecoveryWindow("00:01", "06:30", 3, -30, true, 25)
Airboss:AddRecoveryWindow("07:00", "20:30", 1, nil, true, 25)
Airboss:AddRecoveryWindow("21:00", "23:59", 3, -30, true, 25)
Airboss:AddRecoveryWindow("00:01+1", "06:30+1", 3, -30, true, 25)

-- Airboss:SetSoundfilesFolder("Airboss Soundfiles")
Airboss:SetMenuSingleCarrier()
Airboss:SetDefaultPlayerSkill(AIRBOSS.Difficulty.Normal)
Airboss:SetDespawnOnEngineShutdown()
Airboss:Load()
Airboss:SetAutoSave()
Airboss:SetTrapSheet()
Airboss:Start()

if (debug_airbos) then
    env.info("CUSTOM Airboss DEBUG ON!")
    BASE:TraceOnOff(true)
    BASE:TraceLevel(3)
    BASE:TraceClass("AIRBOSS")
    Airboss:SetDebugModeON()
end

--- Function called when a player gets graded by the LSO.
function Airboss:OnAfterLSOGrade(From, Event, To, playerData, grade)
    local PlayerData = playerData --Ops.Airboss#AIRBOSS.PlayerData
    local Grade = grade --Ops.Airboss#AIRBOSS.LSOgrade
    local score = tonumber(Grade.points)
    local gradeLso = tostring(Grade.grade)
    local timeInGrove = tonumber(Grade.Tgroove)
    local wire = tonumber(Grade.wire)
    local name = tostring(PlayerData.name)

    ----------------------------------------
    --- Interface your Discord bot here! ---
    ----------------------------------------

    -- BotSay(string.format("Player %s scored %.1f \n", name, score))
    -- BotSay(string.format("details: \n wire: %d \n time in Grove: %d \n LSO grade: %s", wire, timeInGrove, gradeLso))

    -- Report LSO grade to dcs.log file.
    env.info(string.format("CUSTOM: Player %s scored %.1f", name, score))
end
-- ### 8 CSAR ###
-- ###########################################################
-- ###                      CSAR MENU                      ###
-- ###########################################################

-- Instantiate and start a CSAR for the blue side, with template "Downed Pilot" and alias "Luftrettung"
mycsar = CSAR:New(coalition.side.BLUE,"Downed Pilot","MIA")
-- options
mycsar.immortalcrew = true -- downed pilot spawn is immortal
mycsar.invisiblecrew = false -- downed pilot spawn is visible
-- start the FSM
mycsar:__Start(5)
mycsar.allowDownedPilotCAcontrol = false -- Set to false if you don\'t want to allow control by Combined Arms.
mycsar.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
mycsar.FARPRescueDistance = 1000 -- you need to be this close to a FARP or Airport for the pilot to be rescued.
mycsar.autosmoke = false -- automatically smoke a downed pilot\'s location when a heli is near.
mycsar.autosmokedistance = 1000 -- distance for autosmoke
mycsar.coordtype = 2 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
mycsar.csarOncrash = true -- (WIP) If set to true, will generate a downed pilot when a plane crashes as well.
mycsar.enableForAI = true -- set to false to disable AI pilots from being rescued.
mycsar.pilotRuntoExtractPoint = true -- Downed pilot will run to the rescue helicopter up to mycsar.extractDistance in meters.
mycsar.extractDistance = 500 -- Distance the downed pilot will start to run to the rescue helicopter.
mycsar.immortalcrew = true -- Set to true to make wounded crew immortal.
mycsar.invisiblecrew = false -- Set to true to make wounded crew insvisible.
mycsar.loadDistance = 75 -- configure distance for pilots to get into helicopter in meters.
mycsar.mashprefix = {"MASH"} -- prefixes of #GROUP objects used as MASHes.
mycsar.max_units = 6 -- max number of pilots that can be carried if #CSAR.AircraftType is undefined.
mycsar.messageTime = 30 -- Time to show messages for in seconds. Doubled for long messages.
mycsar.radioSound = "beacon.ogg" -- the name of the sound file to use for the pilots\' radio beacons.
mycsar.smokecolor = 4 -- Color of smokemarker, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue.
mycsar.useprefix = true  -- Requires CSAR helicopter #GROUP names to have the prefix(es) defined below.
mycsar.csarPrefix = { "helicargo", "MEDEVAC"} -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor!
if (debug_csar) then
	mycsar.verbose = 2 -- set to > 1 for stats output for debugging.
	-- (added 0.1.4) limit amount of downed pilots spawned by **ejection** events
else
	mycsar.verbose = 0
end
mycsar.limitmaxdownedpilots = true
mycsar.maxdownedpilots = 10
-- (added 0.1.8) - allow to set far/near distance for approach and optionally pilot must open doors
mycsar.approachdist_far = 5000 -- switch do 10 sec interval approach mode, meters
mycsar.approachdist_near = 3000 -- switch to 5 sec interval approach mode, meters
mycsar.pilotmustopendoors = false -- switch to true to enable check of open doors
-- (added 0.1.9)
mycsar.suppressmessages = false -- switch off all messaging if you want to do your own
-- (added 0.1.11)
mycsar.rescuehoverheight = 20 -- max height for a hovering rescue in meters
mycsar.rescuehoverdistance = 10 -- max distance for a hovering rescue in meters
-- (added 0.1.12)
-- Country codes for spawned pilots
mycsar.countryblue= country.id.USA
mycsar.countryred = country.id.RUSSIA
mycsar.countryneutral = country.id.UN_PEACEKEEPERS


mycsar.useSRS = true -- Set true to use FF\'s SRS integration
mycsar.SRSPath = "C:\\DCS-SimpleRadio-Standalone" -- adjust your own path in your SRS installation -- server(!)
mycsar.SRSchannel = 242 -- radio channel
mycsar.SRSModulation = radio.modulation.AM -- modulation
mycsar.SRSport = 5002  -- and SRS Server port
mycsar.SRSCulture = "en-GB" -- SRS voice culture
mycsar.SRSVoice = nil -- SRS voice, relevant for Google TTS
mycsar.SRSGPathToCredentials = nil -- Path to your Google credentials json file, set this if you want to use Google TTS
mycsar.SRSVolume = 1 -- Volume, between 0 and 1
--
mycsar.csarUsePara = false -- If set to true, will use the LandingAfterEjection Event instead of Ejection --shagrat
-- mycsar.wetfeettemplate = "man in floating thingy" -- if you use a mod to have a pilot in a rescue float, put the template name in here for wet feet spawns. Note: in conjunction with csarUsePara this might create dual ejected pilots in edge cases.


-- ### 9 FOX ###
-- ###########################################################
-- ###                          FOX                        ###
-- ###########################################################

zonePvP_trgt = ZONE:New("PVP-RANGE")

function spawn_cc()
    pvpcc = SPAWN:New("PvP TACAN"):OnSpawnGroup(
        function(cc)
            beaconPvP = cc:GetBeacon()
            beaconPvP:ActivateTACAN(TACAN.pvp[1], TACAN.pvp[2], TACAN.pvp[3], true)
        end)
    :Spawn()
end

local function start_fox()
	zonePvP_trgt:DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
	spawn_cc()
	fox:Start()
	MESSAGE:New("PvP ZONE START"):ToBlue()
	StartFox:Remove()
	StopFox:Refresh()
end

local function stop_fox()
	zonePvP_trgt:UndrawZone(1)
	beaconPvP:StopRadioBeacon()
	fox:Stop()
	pvpcc:Destroy()
	MESSAGE:New("PvP ZONE STOP"):ToBlue()
	StopFox:Remove()
	StartFox:Refresh()
end

fox=FOX:New()

fox:AddSafeZone(zonePvP_trgt)
fox:AddLaunchZone(zonePvP_trgt)

FOX:SetDefaultLaunchAlerts(false)
FOX:SetDefaultLaunchMarks(false)

StartFox = MENU_MISSION_COMMAND:New("Start PvP Training", MenuFeatures, start_fox)
StopFox = MENU_MISSION_COMMAND:New("Stop PvP Training", MenuFeatures, stop_fox)
StopFox:Remove()
-- ### 10 AG GROUND ###
-- ###########################################################
-- ###                      AG GROUND                      ###
-- ###########################################################

zoneAG_trgt = ZONE:New("AG-RANGE")

if (menu_dump_to_file) then
    local targets_hard = {
        "Static Ammunition depot-1-1",
        "Static Ammunition depot-2-1",
        "Static Ammunition depot-3-1",
        "Static Ammunition depot-4-1",
    }
    local targets_medium = {
        "Static Warehouse-1-1",
        "Static Warehouse-2-1",
        "Static Warehouse-3-1",
        "Static Warehouse-4-1",
        "Static Workshop A-1",
    }
    local targets_soft = {
        "Static Tank 1-1-1",
        "Static Tank 1-2-1",
        "Static Tank 1-3-1",
        "Static Tank 1-4-1",
        "Static Tank 1-5-1",
        "Static Tank 1-6-1",
        "Static Tank 2-1-1",
        "Static Tank 2-2-1",
        "Static Tank 2-3-1",
        "Static Tank 2-4-1",
        "Static Tank 2-5-1",
        "Static Tank 2-6-1",
        "Static Tank 2-7-1",
    }

    local function coord_to_LLDMS_H(coord)
        return {coord:ToStringLLDMS(nil), UTILS.MetersToFeet(coord:GetLandHeight())}
    end

    local function targets_to_JDAM_text(targets_coords, prefix)
        local tmp_table = {}
        local msg = string.format("%s Targets Coordinates: \n", prefix)
        table.insert(tmp_table, msg)
        for i, v in ipairs(targets_coords) do
            local human_coords = coord_to_LLDMS_H(v)
            local tmp_string = string.format("DMS %s\n        h= %d fts \n",human_coords[1], human_coords[2])
            table.insert(tmp_table, tmp_string)
        end
        local final_msg = table.concat(tmp_table)
        return final_msg .. "\n"
    end

    function get_statics_coords(statics_table)
        local table_coords = {}
        for i, v in pairs(statics_table) do
            local static_target = STATIC:FindByName(v, false)
            local coords = static_target:GetCoordinate()
            table.insert(table_coords, coords)
        end
        return table_coords
    end

    local hard_statics = targets_to_JDAM_text(get_statics_coords(targets_hard), "Hard Targets")
    local medium_statics = targets_to_JDAM_text(get_statics_coords(targets_medium), "Medium Targets")
    local soft_statics = targets_to_JDAM_text(get_statics_coords(targets_soft), "Soft Targets")
    local concat_targets = hard_statics .. medium_statics .. soft_statics
    save_to_file("ag_statics", concat_targets)
end

function spawn_drone()
    agDrone = SPAWN:New("AG-DRONE"):OnSpawnGroup(
        function(drone)
            agDrone:CommandSetCallsign(CALLSIGN.Aircraft.Uzi, 1, 1)
            agDrone:CommandSetFrequency(FREQUENCIES.FLIGHTS.ag_drone[1])
            local beacon = agDrone:GetBeacon()
            beacon:ActivateTACAN(TACAN.ag[1], TACAN.ag[2], TACAN.ag[3], false)
        end)
    :Spawn()
end

function spawn_train_sector()
    zoneAG_trgt:DrawZone(-1,{0.5,0.25,0},1,{0.5,0.25,0},0.4,1,true)
    target_moving = SPAWN:New("Moving-Target-1"):Spawn()
    spawn_drone()
    MESSAGE:New("AG Range Spawned"):ToBlue()
    StartAGGround:Remove()
    StopAGGround:Refresh()
end

function kill_train_sector()
    zoneAG_trgt:UndrawZone(1)
    target_moving:Destroy()
    agDrone:Destroy()
    MESSAGE:New("AG Range Removed"):ToBlue()
    StartAGGround:Refresh()
    StopAGGround:Remove()
end

StartAGGround = MENU_MISSION_COMMAND:New("Start Ground Range", MenuFeatures, spawn_train_sector)
StopAGGround = MENU_MISSION_COMMAND:New("Stop Ground Range", MenuFeatures, kill_train_sector)
StopAGGround:Remove()
-- ### 11 AW VAZ ###

-- ###########################################################
-- ###                  Vaziani Air Wing                   ###
-- ###########################################################
ZONE_VAZIANI_CAP = ZONE:New("CORN FLAKES")
ZONE_VAZIANI_FEZ = ZONE:New("GUADALCANAL")
ZONE_VAZIANI_AWACS = ZONE:New("DARKSTAR")
ZONE_SHELL_EAST_AAR = ZONE:New("SHELL EAST")
ZONE_TEXACO_EAST_AAR = ZONE:New("TEXACO EAST")

AWVaziani = AIRWING:New("WH VAZIANI", "Vaziani Air Wing")

if (debug_aw_vaziani) then
	function AWVaziani:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWVaziani:SetMarker(false)
AWVaziani:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Vaziani))
AWVaziani:SetRespawnAfterDestroyed(600)


Vaziani_AWACS = SQUADRON:New("ME AWACS E3",2,"AWACS Vaziani")
Vaziani_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Vaziani_AWACS:SetTakeoffAir()
Vaziani_AWACS:SetFuelLowRefuel(false)
Vaziani_AWACS:SetFuelLowThreshold(0.25)
Vaziani_AWACS:SetTurnoverTime(30,180)
Vaziani_AWACS:SetCallsign(CALLSIGN.Aircraft.Darkstar, 1)
Vaziani_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_AWACS)
AWVaziani:NewPayload("ME AWACS E3" ,-1,{AUFTRAG.Type.ORBIT},100)

Vaziani_MPRS = SQUADRON:New("ME TANKER KC135MPRS",2,"AAR MPRS Vaziani")
Vaziani_MPRS:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Vaziani_MPRS:SetTakeoffAir()
Vaziani_MPRS:SetFuelLowRefuel(false)
Vaziani_MPRS:SetFuelLowThreshold(0.25)
Vaziani_MPRS:SetTurnoverTime(15,60)
Vaziani_MPRS:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_MPRS)
AWVaziani:NewPayload("ME TANKER KC135MPRS", -1, {AUFTRAG.Type.TANKER},100)

Vaziani_135 = SQUADRON:New("ME AAR KC135",2,"AAR 135 Vaziani")
Vaziani_135:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Vaziani_135:SetTakeoffAir()
Vaziani_135:SetFuelLowRefuel(false)
Vaziani_135:SetFuelLowThreshold(0.25)
Vaziani_135:SetTurnoverTime(15,60)
Vaziani_135:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWVaziani:AddSquadron(Vaziani_135)
AWVaziani:NewPayload("ME AAR KC135", -1, {AUFTRAG.Type.TANKER},100)

TankerShellEast = AUFTRAG:NewTANKER(ZONE_SHELL_EAST_AAR:GetCoordinate(), 25000, 320, 100, 40, 0)
TankerShellEast:AssignSquadrons({Vaziani_135})
TankerShellEast:SetTACAN(TACAN.shell_e[1], TACAN.shell_e[3], TACAN.shell_e[2])
TankerShellEast:SetRadio(FREQUENCIES.AAR.common[1])
TankerShellEast:SetName("Shell East")
AWVaziani:AddMission(TankerShellEast)

TankerTexacoEast = AUFTRAG:NewTANKER(ZONE_TEXACO_EAST_AAR:GetCoordinate(), 22000, 310, 100, 40, 1)
TankerTexacoEast:AssignSquadrons({Vaziani_MPRS})
TankerTexacoEast:SetTACAN(TACAN.texaco_e[1], TACAN.texaco_e[3], TACAN.texaco_e[2])
TankerTexacoEast:SetRadio(FREQUENCIES.AAR.common[1])
TankerTexacoEast:SetName("Texaco East")
AWVaziani:AddMission(TankerTexacoEast)


if (aw_vaziani_cap or aw_vaziani_escort) then
	Vaziani_F5 = SQUADRON:New("ME F5",12,"F5 Vaziani")
	Vaziani_F5:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
	Vaziani_F5:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 50)
	Vaziani_F5:SetTakeoffHot()
	Vaziani_F5:SetFuelLowRefuel(true)
	Vaziani_F5:SetFuelLowThreshold(0.3)
	Vaziani_F5:SetTurnoverTime(10,60)
	Vaziani_F5:SetCallsign(CALLSIGN.Aircraft.Ford, 1)
	Vaziani_F5:SetTakeoffHot()
	Vaziani_F5:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
	AWVaziani:AddSquadron(Vaziani_F5)
	if (aw_vaziani_cap) then
		AWVaziani:NewPayload("ME F5", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
	end
	if (aw_vaziani_escort) then
		AWVaziani:NewPayload("ME F5", -1, {AUFTRAG.Type.ESCORT},100)
	end
end

AWVaziani:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AwacsDarkstar = AWACS:New("Darkstar", AWVaziani, "blue", AIRBASE.Caucasus.Vaziani, "DARKSTAR", "GUADALCANAL", "CORN FLAKES", FREQUENCIES.AWACS.darkstar[1] ,radio.modulation.AM)
if (aw_vaziani_escort) then
	AwacsDarkstar:SetEscort(1)
end
AwacsDarkstar:SetBullsEyeAlias("TEXAS")
AwacsDarkstar:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, 30000, 220, 120, 20)
AwacsDarkstar:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
if (moose_awacs_rejection_red_zone) then
	AwacsDarkstar:SetRejectionZone(borderRed)
end
AwacsDarkstar:SetAdditionalZone(borderBlue, true)
AwacsDarkstar:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 2, 300)
AwacsDarkstar:SetModernEraAgressive()

AwacsDarkstar.PlayerGuidance = true -- allow missile warning call-outs.
AwacsDarkstar.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AwacsDarkstar.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AwacsDarkstar.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AwacsDarkstar.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AwacsDarkstar.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AwacsDarkstar.NoMissileCalls = false -- suppress missile callouts
AwacsDarkstar.PlayerCapAssigment = true -- no task assignment for players
AwacsDarkstar.invisible = true -- set AWACS to be invisible to hostiles
AwacsDarkstar.immortal = true -- set AWACS to be immortal
AwacsDarkstar.GoogleTTSPadding = 1 -- seconds
AwacsDarkstar.WindowsTTSPadding = 2.5 -- seconds

AwacsDarkstar:SuppressScreenMessages(true)

AwacsDarkstar:__Start(5)

if (debug_awacs) then
	AwacsDarkstar.debug = true -- set to true to produce more log output.
else
  	AwacsDarkstar.debug = false
end
-- ### 12 AW KUT ###

-- ###########################################################
-- ###                  Kutaisi Air Wing                   ###
-- ###########################################################
ZONE_KUTAISI_CAP = ZONE:New("PANCAKE")
ZONE_KUTAISI_FEZ = ZONE:New("MIDWAY")
ZONE_KUTAISI_AWACS = ZONE:New("OVERLORD")
ZONE_SHELL_WEST_AAR = ZONE:New("SHELL WEST")
ZONE_TEXACO_WEST_AAR = ZONE:New("TEXACO WEST")

AWKutaisi = AIRWING:New("WH KUTAISI", "Kutaisi Air Wing")

if (debug_aw_kutaisi) then
	function AWKutaisi:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWKutaisi:SetMarker(false)
AWKutaisi:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
AWKutaisi:SetRespawnAfterDestroyed(600)


Kutaisi_AWACS = SQUADRON:New("ME AWACS E3",2,"AWACS Kutaisi")
Kutaisi_AWACS:AddMissionCapability({AUFTRAG.Type.ORBIT},100)
Kutaisi_AWACS:SetTakeoffAir()
Kutaisi_AWACS:SetFuelLowRefuel(false)
Kutaisi_AWACS:SetFuelLowThreshold(0.25)
Kutaisi_AWACS:SetTurnoverTime(30,180)
Kutaisi_AWACS:SetCallsign(CALLSIGN.Aircraft.Overlord, 1)
Kutaisi_AWACS:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_AWACS)
AWKutaisi:NewPayload("ME AWACS E3" ,-1,{AUFTRAG.Type.ORBIT},100)

Kutaisi_MPRS = SQUADRON:New("ME TANKER KC135MPRS",2,"AAR MPRS Kutaisi")
Kutaisi_MPRS:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Kutaisi_MPRS:SetTakeoffAir()
Kutaisi_MPRS:SetFuelLowRefuel(false)
Kutaisi_MPRS:SetFuelLowThreshold(0.25)
Kutaisi_MPRS:SetTurnoverTime(15,60)
Kutaisi_MPRS:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_MPRS)
AWKutaisi:NewPayload("ME TANKER KC135MPRS", -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

Kutaisi_135 = SQUADRON:New("ME AAR KC135",2,"AAR 135 Kutaisi")
Kutaisi_135:AddMissionCapability({AUFTRAG.Type.TANKER},100)
Kutaisi_135:SetTakeoffAir()
Kutaisi_135:SetFuelLowRefuel(false)
Kutaisi_135:SetFuelLowThreshold(0.25)
Kutaisi_135:SetTurnoverTime(15,60)
Kutaisi_135:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AWKutaisi:AddSquadron(Kutaisi_135)
AWKutaisi:NewPayload("ME AAR KC135", -1, {AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT},100)

TankerShellWest = AUFTRAG:NewTANKER(ZONE_SHELL_WEST_AAR:GetCoordinate(), 25000, 320, 100, 40, 0)
TankerShellWest:AssignSquadrons({Kutaisi_135})
TankerShellWest:SetTACAN(TACAN.shell_w[1], TACAN.shell_w[3], TACAN.shell_w[2])
TankerShellWest:SetRadio(FREQUENCIES.AAR.common[1])
TankerShellWest:SetName("Shell West")
AWKutaisi:AddMission(TankerShellWest)

TankerTexacoWest = AUFTRAG:NewTANKER(ZONE_TEXACO_WEST_AAR:GetCoordinate(), 22000, 310, 100, 40, 1)
TankerTexacoWest:AssignSquadrons({Kutaisi_MPRS})
TankerTexacoWest:SetTACAN(TACAN.texaco_w[1], TACAN.texaco_w[3], TACAN.texaco_w[2])
TankerTexacoWest:SetRadio(FREQUENCIES.AAR.common[1])
TankerTexacoWest:SetName("Texaco West")
AWKutaisi:AddMission(TankerTexacoWest)


if (aw_kutaisi_cap or aw_kutaisi_escort) then
	Kutaisi_SU27 = SQUADRON:New("ME SU27",12,"SU27 Vaziani")
	Kutaisi_SU27:AddMissionCapability({AUFTRAG.Type.ESCORT}, 60)
	Kutaisi_SU27:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 50)
	Kutaisi_SU27:SetTakeoffHot()
	Kutaisi_SU27:SetFuelLowRefuel(true)
	Kutaisi_SU27:SetFuelLowThreshold(0.3)
	Kutaisi_SU27:SetTurnoverTime(10,60)
	Kutaisi_SU27:SetCallsign(CALLSIGN.Aircraft.Ford, 2)
	Kutaisi_SU27:SetTakeoffHot()
	Kutaisi_SU27:SetRadio(FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)
	AWKutaisi:AddSquadron(Kutaisi_SU27)
	if (aw_kutaisi_cap) then
		AWKutaisi:NewPayload("ME SU27", -1, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},100)
	end
	if (aw_kutaisi_escort) then
		AWKutaisi:NewPayload("ME SU27", -1, {AUFTRAG.Type.ESCORT},100)
	end
end

AWKutaisi:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AwacsOverlord = AWACS:New("Overlord", AWKutaisi, "blue", AIRBASE.Caucasus.Kutaisi, "OVERLORD", "MIDWAY", "PANCAKE", FREQUENCIES.AWACS.overlord[1] ,radio.modulation.AM)
if (aw_kutaisi_escort) then
	AwacsOverlord:SetEscort(1)
end
AwacsOverlord:SetBullsEyeAlias("TEXAS")
AwacsOverlord:SetAwacsDetails(CALLSIGN.AWACS.Overlord, 1, 30000, 220, 120, 20)
AwacsOverlord:SetSRS(SRS_PATH, "female","en-GB", SRS_PORT)
if (moose_awacs_rejection_red_zone) then
	AwacsOverlord:SetRejectionZone(borderRed)
end
AwacsOverlord:SetAdditionalZone(borderBlue, true)
AwacsOverlord:SetAICAPDetails(CALLSIGN.Aircraft.Ford, 2, 2, 300)
AwacsOverlord:SetModernEraAgressive()

AwacsOverlord.PlayerGuidance = true -- allow missile warning call-outs.
AwacsOverlord.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AwacsOverlord.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AwacsOverlord.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AwacsOverlord.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AwacsOverlord.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AwacsOverlord.NoMissileCalls = false -- suppress missile callouts
AwacsOverlord.PlayerCapAssigment = true -- no task assignment for players
AwacsOverlord.invisible = true -- set AWACS to be invisible to hostiles
AwacsOverlord.immortal = true -- set AWACS to be immortal
AwacsOverlord.GoogleTTSPadding = 1 -- seconds
AwacsOverlord.WindowsTTSPadding = 2.5 -- seconds

AwacsOverlord:SuppressScreenMessages(true)

AwacsOverlord:__Start(5)

if (debug_awacs) then
	AwacsOverlord.debug = true -- set to true to produce more log output.
else
  	AwacsOverlord.debug = false
end
-- ### 13 AW MOZ ###
-- ###########################################################
-- ###                  Mozdok Air Wing                   ###
-- ###########################################################

AWMozdok = AIRWING:New("WH MOZDOK", "Mozdok Air Wing")

if (debug_aw_mozdok) then
	function AWMozdok:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
	  local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
	  local mission=Mission         --Ops.Auftrag#AUFTRAG
	  
	  -- Info message.
	  local text=string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
	  env.info(text)
	  MESSAGE:New(text, 300):ToAll()
	end
end

AWMozdok:SetMarker(false)
AWMozdok:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Mozdok))
AWMozdok:SetRespawnAfterDestroyed(600)

Mozdok_AWACS = SQUADRON:New("ME RED AWACS",2,"AWACS Mozdok")
Mozdok_AWACS:AddMissionCapability({AUFTRAG.Type.AWACS},100)
Mozdok_AWACS:SetTakeoffAir()
Mozdok_AWACS:SetFuelLowRefuel(false)
Mozdok_AWACS:SetFuelLowThreshold(0.25)
Mozdok_AWACS:SetTurnoverTime(30,180)
AWMozdok:AddSquadron(Mozdok_AWACS)
AWMozdok:NewPayload("ME RED AWACS" ,-1,{AUFTRAG.Type.AWACS},100)

Mozdok_27 = SQUADRON:New("ME RED 27 27ER",6,"SU27 Mozdok")
Mozdok_27:AddMissionCapability({AUFTRAG.Type.ESCORT}, 100)
Mozdok_27:AddMissionCapability({AUFTRAG.Type.CAP}, 100)
Mozdok_27:SetTakeoffHot()
Mozdok_27:SetFuelLowRefuel(true)
Mozdok_27:SetFuelLowThreshold(0.3)
Mozdok_27:SetTurnoverTime(10,60)
Mozdok_27:SetGrouping(2)
Mozdok_27:SetTakeoffHot()

Mozdok_29 = SQUADRON:New("ME RED 29 R77",12,"MiG29 Mozdok")
Mozdok_29:AddMissionCapability({AUFTRAG.Type.ESCORT}, 50)
Mozdok_29:AddMissionCapability({AUFTRAG.Type.ALERT5, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 100)
Mozdok_29:AddMissionCapability({AUFTRAG.Type.CAP}, 80)
Mozdok_29:SetTakeoffHot()
Mozdok_29:SetFuelLowRefuel(true)
Mozdok_29:SetFuelLowThreshold(0.3)
Mozdok_29:SetTurnoverTime(10,60)
Mozdok_29:SetTakeoffHot()

AWMozdok:AddSquadron(Mozdok_27)
AWMozdok:NewPayload("ME RED 27 27ER", -1, {AUFTRAG.Type.ESCORT, AUFTRAG.Type.CAP}, 100)

AWMozdok:AddSquadron(Mozdok_29)
AWMozdok:NewPayload("ME RED 29 R77", 4, {AUFTRAG.Type.ALERT5, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 100)
AWMozdok:NewPayload("ME RED 29 R27R", -1, {AUFTRAG.Type.ESCORT, AUFTRAG.Type.CAP, AUFTRAG.Type.ALERT5, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT}, 80)

AWMozdok:__Start(2)

-- ### 14 RED CHIEF ###
-- ###########################################################
-- ###                      RED CHIEF                      ###
-- ###########################################################

local VazianiZone = ZONE:New("TARGET VAZIANI")

local RedAgentSet = SET_GROUP:New()

local RedBorderZoneSet = SET_ZONE:New()
RedBorderZoneSet:AddZone(borderRed)

local ConflictZoneSet = SET_ZONE:New()
-- ConflictZoneSet:AddZone(zoneConflict1)
-- ConflictZoneSet:AddZone(zoneConflict2)

local AtackZoneSet = SET_ZONE:New()
AtackZoneSet:AddZone(VazianiZone)

RedChief = CHIEF:New("red", RedAgentSet, "Comrade RedChief")
-- ZONES
RedChief:SetBorderZones(RedBorderZoneSet)
-- RedChief:AddConflictZone(ConflictZoneSet)
RedChief:SetAttackZones(AtackZoneSet)
-- STRATEGY
RedChief:SetStrategy(CHIEF.Strategy.DEFENSIVE)
-- RESOURCES
if (aw_mozdok) then
    RedChief:AddAirwing(AWMozdok)
    RedChief:AddAwacsZone(ZONE:New("RED AWACS"), 35000, 320, 225, 20)
    RedChief:AddCapZone(ZONE:New("RED CAP"), 30000, 350, 180, 20)
    RedChief:AddGciCapZone(ZONE:New("RED GCICAP"), 30000, 350, 180, 30)    
end

RedChief:SetTacticalOverviewOn()
RedChief:__Start(5)

-- ### 15 SCHEDULER ###
-- ###########################################################
-- ###                      SCHEDULER                      ###
-- ###########################################################

function elint_platform_updater(hound_object, airwing, sector_name)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission=Mission --Ops.Auftrag#AUFTRAG
        if (mission:GetType() == AUFTRAG.Type.ORBIT) then
            env.info("ELINT PLATFORM UPDATE")
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive():GetName()
            env.info(string.format("Adding platform %s", unit_alive))
            hound_object:addPlatform(unit_alive)
            hound_object:setTransmitter(sector_name, unit_alive)
            function flightgroup:OnAfterFuelLow(From, Event, To)
                env.info(string.format("Removing platform %s", unit_alive))
                hound_object:removePlatform (unit_alive)  
            end
        end
    end
end
function tanker_platform_updater(airwing)
    function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup=FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission=Mission --Ops.Auftrag#AUFTRAG
        local callsign = "nil"
        local index = 99
        if (mission:GetType() == AUFTRAG.Type.TANKER) then
            local unit_alive = flightgroup:GetGroup():GetFirstUnitAlive()
            if (mission.refuelSystem == 1) then --probe
                callsign = CALLSIGN.Tanker.Shell
            elseif (mission.refuelSystem == 0) then --boom
                callsign = CALLSIGN.Tanker.Texaco
            end
            if (string.find(mission:GetName(), "East")) then
                index = 1
            elseif (string.find(mission:GetName(), "West")) then
                index = 2
            end
            env.info(string.format("TANKER PLATFORM UPDATE %s -> %s-%d", unit_alive:GetName(), callsign, index))
            unit_alive:CommandSetCallsign(callsign, index, 1)
        end
    end
end

if (elint) then
    if (aw_vaziani) then
        elint_platform_updater(HoundBlue, AWVaziani, "Vaziani")
    end
    if (aw_kutaisi) then
        elint_platform_updater(HoundBlue, AWKutaisi, "Kutaisi")
    end
end
if (aw_vaziani) then
    tanker_platform_updater(AWVaziani)
end
if (aw_kutaisi) then
    tanker_platform_updater(AWKutaisi)
end

-- HoundScheduler = SCHEDULER:New(nil, platform_update,{}, 10, 10)
