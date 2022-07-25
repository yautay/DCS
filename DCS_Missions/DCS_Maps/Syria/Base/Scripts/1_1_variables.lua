FREQUENCIES = {
    AWACS = {
        darkstar = {244.25, "AWACS Darkstar UHF", "AM"},
    },
    AAR = {
        --shell_e = {251.00, "Tanker Shell East UHF", "AM"},
        --shell_c = {251.25, "Tanker Shell Center UHF", "AM"},
        --shell_w = {251.50, "Tanker Shell West UHF", "AM"},
        --texaco_e = {252.00, "Tanker Texaco East UHF", "AM"},
        --texaco_w = {252.25, "Tanker Texaco West UHF", "AM"},
    },
    FLIGHTS = {
		apache_1_uhf = {255.00, "APACHE ONE UHF", "AM"},
        apache_1_vhf = {115.00, "APACHE ONE VHF", "AM"},
        apache_1_fm = {30.01, "APACHE ONE FM", "FM"},
    },
    ELEMENTS = {
	    killer_uhf = {230.00, "KILLER UHF", "AM"},
        killer_vhf = {120.00, "KILLER VHF", "AM"},
        killer_fm = {30.015, "KILLER FM", "FM"},
    },

    CV = {
        --sc = {127.50, "CV-75 Tower VHF", "AM"}
    },
    GROUND = {
        atis_hatay_vhf = {121.25, "ATIS Hatay VHF", "AM"},
        tower_hatay_uhf = {250.25, "Tower Hatay UHF", "AM"},
        tower_hatay_vhf = {128.50, "Tower Hatay VHF", "AM"},
    },
    SPECIAL = {
        guard_hi = {243.00, "Guard Freq UHF", "AM"},
        guard_lo = {121.50, "Guard Freq VHF", "AM"},
        unicom =  {240.00, "Unicom UHF", "AM"},
    }
}
ICLS = {
    --sc = {1, "CV", "ICLS CVN-75"},
}
TACAN = {
    --sc = {74, "X", "CVN", "CVN-75"},
    --shell_e = {51, "Y", "SHE", "Tanker Shell East"},
    --shell_c = {52, "Y", "SHE", "Tanker Shell Center"},
    --shell_w = {53, "Y", "SHW", "Tanker Shell West"},
    --texaco_e = {61, "Y", "TEE", "Tanker Texaco East"},
    --texaco_w = {62, "Y", "TEW", "Tanker Texaco West"},
}
YARDSTICKS = {
    --sting_1 = {"STING ONE", 37, 100, "Y"},
    --joker_1 = {"JOKER TWO", 38, 101, "Y"},
    --hawk_1 = {"HAWK ONE", 39, 102, "Y"},
    --devil_1 = {"DEVIL TWO", 40, 103, "Y"},
    --squid_1 = {"SQUID ONE", 41, 104, "Y"},
    --check_1 = {"CHECK TWO", 42, 105, "Y"},
    --viper_1 = {"VIPER ONE", 43, 106, "Y"},
    --venom_1 = {"VENOM TWO", 44, 107, "Y"},
    --jedi_1 = {"JEDI ONE", 45, 108, "Y"},
    --ninja_1 = {"NINJA TWO", 46, 109, "Y"},
}

_SETTINGS:SetPlayerMenuOff()

--AIRWINGS
-- Vaziani
--aw_vaziani_cap = false
--aw_vaziani_escort = false
--debug_aw_vaziani = false

-- Vaziani
--aw_kutaisi_cap = false
--aw_kutaisi_escort = false
--debug_aw_kutaisi = false

-- FEATURES
-- CSAR
debug_csar = false
-- AWACS
--moose_awacs_rejection_red_zone = false
--debug_awacs = false
--
menu_dump_to_file = true
menu_show_freqs = false
