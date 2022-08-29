_SETTINGS:SetImperial()
_SETTINGS:SetPlayerMenuOff()

FREQUENCIES = {
    AWACS = {
        magic = {241.50, "AWACS HUMAN Magic UHF", "AM"},
        darkstar = {244.00, "AWACS MOOSE Darkstar UHF", "AM"},
        wizard = {241.80, "AWACS DCS Wizard UHF", "AM"},
    },
    AAR = {
        shell_1 = {250.20, "Tanker Shell One UHF", "AM"},
        shell_2 = {250.40, "Tanker Shell Two UHF", "AM"},
        shell_3 = {250.60, "Tanker Shell Three UHF", "AM"},
        arco = {250.80, "CVN 73 Recovery Tanker UHF", "AM"},
    },
    FLIGHTS = {
        wombats_u = {255.50, "SQUADRON UHF", "AM"},
        hornet_1_u = {251.30, "HORNET ONE UHF", "AM"},
        hornet_2_u = {251.60, "HORNET TWO UHF", "AM"},
        squid_1_u = {252.30, "SQUID ONE UHF", "AM"},
        squid_2_u = {252.60, "SQUID TWO VHF", "AM"},
        joker_1_u = {253.30, "JOKER ONE UHF", "AM"},
        joker_2_u = {253.60, "JOKER TWO VHF", "AM"},
        hornet_1_m = {"MIDS 11", "HORNET ONE MIDS", ""},
		hornet_2_m = {"MIDS 12", "HORNET TWO MIDS", ""},
        squid_1_m = {"MIDS 21", "SQUID ONE MIDS", ""},
        squid_2_m = {"MIDS 22", "SQUID TWO MIDS", ""},
		joker_1_m = {"MIDS 31", "JOKER ONE MIDS", ""},
		joker_1_m = {"MIDS 32", "JOKER TWO MIDS", ""},
    },
    ELEMENTS = {
	    shamir_u = {251.00, "SHAMIR UHF", "AM"},
        shamir_m = {"MIDS 1", "SHAMIR MIDS", ""},
        ahmed_u = {252.00, "SHAMIR UHF", "AM"},
        ahmed_m = {"MIDS 2", "SHAMIR MIDS", ""},
        fakir_u = {253.00, "SHAMIR UHF", "AM"},
        fakir_m = {"MIDS 3", "SHAMIR MIDS", ""},
    },

    CV = {
        dcs_sc = {127.50, "CV 73 DCS VHF", "AM"},
        paddles = {260.00, "CV 73 HUMAN Paddles UHF", "AM"},
        marshal = {262.00, "CV 73 AIRBOSS/HUMAN Marshal/Stack UHF", "AM"},
        red_crown = {258.20, "TF 73 HUMAN Red Crown UHF", "AM"},
        strike = {257.70, "TF 73 HUMAN Strike UHF", "AM"},
        catcc = {258.00, "TF 73 HUMAN CATCC UHF", "AM"},
        departure = {258.30, "TF 73 HUMAN CATCC UHF", "AM"},
        approach_1 = {258.50, "TF 73 HUMAN Approach 1 UHF", "AM"},
        approach_2 = {258.70, "TF 73 HUMAN Approach 2 UHF", "AM"},
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
    sc = {11, "CV", "ICLS CVN-73"},
}
TACAN = {
    sc = {74, "X", "CVN", "CVN-73"},
    shell_1 = {51, "Y", "SHE", "Tanker Shell One", false},
    shell_2 = {52, "Y", "SHE", "Tanker Shell Two", false},
    shell_3 = {53, "Y", "SHW", "Tanker Shell Three", false},
    arco = {69, "Y", "RCV", "Recovery Tanker CVN 73", false},
}
YARDSTICKS = {
    hornet_1 = {"HORNET ONE", 37, 100, "Y"},
    hornet_2 = {"HORNET TWO", 38, 101, "Y"},
    squid_1 = {"SQUID ONE", 39, 102, "Y"},
    squid_2 = {"SQUID TWO", 40, 103, "Y"},
    joker_1 = {"JOKER ONE", 41, 104, "Y"},
    joker_2 = {"JOKER TWO", 42, 105, "Y"},
}



--AIRWINGS
aw_ramat_david = true

-- FEATURES
debug_csar = false
debug_awacs = false
--
menu_dump_to_file = true
menu_show_freqs = false

--MISSION SPECIFIC

sam_ahmed = true
sam_fakir = true
sam_shamir = true