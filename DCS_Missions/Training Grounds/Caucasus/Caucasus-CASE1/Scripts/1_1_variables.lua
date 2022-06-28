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
        hornet_1 = {"MIDS 1", "HORNET MIDS", "AM"},
        hornet_2 = {"MIDS 2", "SQUID MIDS", "AM"},
        hornet_3 = {"MIDS 3", "DEVIL MIDS", "AM"},
        hornet_4 = {"MIDS 4", "CHECK MIDS", "AM"},
        viper_1 = {271.00, "VIPER UHF", "AM"},
        viper_2 = {272.00, "PYTHON UHF", "AM"},
        viper_3 = {273.00, "NINJA UHF", "AM"},
        viper_4 = {274.00, "JEDI UHF", "AM"},
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
    hornet_1 = {"HORNET", 37, 100, "Y"},
    hornet_2 = {"SQUID", 38, 101, "Y"},
    hornet_3 = {"DEVIL", 39, 102, "Y"},
    hornet_4 = {"CHECK", 40, 103, "Y"},
    viper_1 = {"VIPER", 41, 104, "Y"},
    viper_2 = {"PYTHON", 42, 105, "Y"},
    viper_3 = {"NINJA", 43, 106, "Y"},
    viper_4 = {"JEDI", 44, 107, "Y"},
}

--AIRWINGS
-- Vaziani
aw_vaziani = false
aw_vaziani_cap = false
aw_vaziani_escort = false
debug_aw_vaziani = false

-- Vaziani
aw_kutaisi = false
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
fox_trainer = false
-- AG Range
ag_range = false
-- ELINT
elint = false
debug_elint = false
-- ATIS
atis = true
-- CSAR
csar = true
debug_csar = false
-- RAT
rat = false
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