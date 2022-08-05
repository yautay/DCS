_SETTINGS:SetImperial()
_SETTINGS:SetPlayerMenuOff()

FREQUENCIES = {
    AWACS = {
        darkstar = {244.25, "AWACS Darkstar UHF", "AM"},
    },
    AAR = {
        shell_1 = {251.00, "Tanker Shell One UHF", "AM"},
        shell_2 = {251.25, "Tanker Shell Two UHF", "AM"},
        shell_3 = {251.50, "Tanker Shell Three UHF", "AM"},
        texaco_1 = {252.00, "Tanker Texaco One UHF", "AM"},
        texaco_2 = {252.25, "Tanker Texaco Two UHF", "AM"},
    },
    FLIGHTS = {
		--apache_1_uhf = {255.00, "APACHE ONE UHF", "AM"},
        --apache_1_vhf = {115.00, "APACHE ONE VHF", "AM"},
        --apache_1_fm = {30.01, "APACHE ONE FM", "FM"},
        --colt_1_fm = {25.70, "COLT ONE FM", "FM"},
        --colt_2_uhf = {255.50, "COLT TWO UHF", "FM"},
        --colt_2_vhf = {113.00, "COLT TWO VHF", "FM"},
        --colt_2_fm = {25.30, "COLT TWO FM", "FM"},
        --roman_1_uhf = {256.10, "ROMAN ONE UHF", "AM"},
        --roman_1_vhf = {129.25, "ROMAN ONE VHF", "AM"},
        --enfield_1_uhf = {257.10, "ROMAN ONE UHF", "AM"},
        --enfield_1_vhf = {130.25, "ROMAN ONE VHF", "AM"},
    },
    ELEMENTS = {
	    --killer_uhf = {230.00, "KILLER UHF", "AM"},
        --killer_vhf = {120.00, "KILLER VHF", "AM"},
        --killer_fm = {30.015, "KILLER FM", "FM"},
        --prayer_uhf = {230.00, "PRAYER UHF", "AM"},
        --prayer_vhf = {231.75, "PRAYER VHF", "AM"},
    },

    CV = {
        --sc = {127.50, "CV-75 Tower VHF", "AM"}
    },
    GROUND = {
        atis_ramat_david_vhf = {121.75, "ATIS Ramat David VHF", "AM"},
        tower_ramat_david_uhf = {251.05, "Tower Ramat David UHF", "AM"},
        tower_ramat_david_vhf = {118.60, "Tower Ramat David VHF", "AM"},

    },
    SPECIAL = {
        guard_hi = {243.00, "Guard Freq UHF", "AM"},
        guard_lo = {121.50, "Guard Freq VHF", "AM"},
        unicom =  {242.00, "Unicom UHF", "AM"},
    }
}
ICLS = {
    --sc = {1, "CV", "ICLS CVN-75"},
}
TACAN = {
    --sc = {74, "X", "CVN", "CVN-75"},
    shell_1 = {51, "Y", "SHE", "Tanker Shell One", false},
    shell_2 = {52, "Y", "SHE", "Tanker Shell Two", false},
    shell_3 = {53, "Y", "SHW", "Tanker Shell Three", false},
    texaco_1 = {61, "Y", "TEE", "Tanker Texaco One", false},
    texaco_2 = {62, "Y", "TEW", "Tanker Texaco Two", false},
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



--AIRWINGS
aw_ramat_david = true
debug_aw_ramat_david = true

-- FEATURES
debug_csar = false
debug_awacs = false
--
menu_dump_to_file = true
menu_show_freqs = false

--MISSION SPECIFIC

sam_ahmed = false
sam_fakir = false
sam_shamir = false