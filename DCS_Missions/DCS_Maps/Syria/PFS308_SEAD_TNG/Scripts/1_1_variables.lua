FREQUENCIES_MAP = {
    GROUND = {
        twr_hattay = { 250.300, "Hatay TWR UHF", "AM" }
    }
}

FREQUENCIES = {
    AWACS = {
        wizard = { 250.00, "AWACS @DCS Wizard UHF", "AM" },
    --    darkstar = { 249.00, "AWACS @ DCS Darkstar UHF", "AM" },
    },
    AAR = {
        arco = { 252.50, "Tanker Arco UHF", "AM" },
        shell_one = { 252.20, "Tanker Shell One UHF", "AM" },
        texaco_one = { 252.30, "Tanker Texaco One UHF", "AM" },
    },
    CVN_75 = {
        dcs_sc = { 127.50, "DCS SC ATC VHF", "AM" },
        btn1 = { 260.00, "B-1 HUMAN Paddles/Tower C1 UHF", "AM" },
        btn2 = { 260.10, "B-2 HUMAN Departure C2/C3 UHF", "AM" },
        btn3 = { 249.10, "B-3 HUMAN Strike UHF", "AM" },
        btn4 = { 258.20, "B-4 HUMAN Red Crown UHF", "AM" },
        btn15 = { 260.20, "B-15 HUMAN CCA Final A", "AM" },
        btn16 = { 260.30, "B-16 AIRBOSS/HUMAN Marshal UHF", "AM" },
        btn17 = { 260.40, "B-17 HUMAN CCA Final B", "AM" },
    },
    SPECIAL = {
        guard_hi = { 243.00, "Guard UHF", "AM" },
        guard_lo = { 121.50, "Guard VHF", "AM" },
        ch_16 = { 156.8, "Maritime Ch16 VHF", "FM" },
        cvn_l4 = {366.0}
    },
    ICLS = {
        sc_75 = { 11, "CVN", "ICLS CVN-75" },
    },
    TACAN = {
        sc_75 = { 75, "X", "CVN", "CVN-75" },
        arco = { 1, "Y", "RCV", "Recovery Tanker" },
        shell_one = { 52, "Y", "SH1", "Tanker Shell One" },
        texaco_one = { 53, "Y", "TX1", "Tanker Texaco One" },
    }
}
