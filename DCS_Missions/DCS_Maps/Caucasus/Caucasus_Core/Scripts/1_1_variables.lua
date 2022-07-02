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