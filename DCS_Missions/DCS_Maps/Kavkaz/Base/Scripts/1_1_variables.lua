FREQUENCIES_MAP = {
    GROUND = {
        atis_senaki = { 125.000, "ATIS Senaki", "AM" },
        twr_senaki_1 = { 40.600, "TOWER Senaki VHF/LOW", "AM" },
        twr_senaki_2 = { 132.000, "TOWER Senaki VHF", "AM" },
        twr_senaki_3 = { 261.000, "TOWER Senaki UHF", "AM" },
    },
    SPECIAL = {
        guard_hi = { 243.00, "Guard UHF", "AM" },
        guard_lo = { 121.50, "Guard VHF", "AM" },
        ch_16 = { 156.8, "Maritime Ch16 VHF", "FM" },
        lobby = { 251.00, "Lobby UHF", "FM" }
    },
}

FREQUENCIES = {
    AWACS = {
        wizard = { 250.00, "AWACS @ DCS Wizard UHF", "AM" },
        darkstar = { 249.00, "AWACS @ DCS Darkstar UHF", "AM" },
    },
    AAR = {
        arco = { 252.50, "Tanker Arco UHF", "AM" },
        shell_one = { 252.30, "Tanker Texaco One UHF", "AM" },
        texaco_one = { 252.30, "Tanker Texaco One UHF", "AM" },
        texaco_two = { 252.10, "Tanker Texaco Two UHF", "AM" },
    },
    CVN_75 = {
        dcs_sc = { 127.50, "DCS SC ATC VHF", "AM" },
        btn1 = { 260.00, "B-1 HUMAN Paddles/Tower C1 UHF", "AM" },
        btn2 = { 260.10, "B-2 HUMAN Departure C2/C3 UHF", "AM" },
        btn3 = { 249.10, "B-3 HUMAN Strike UHF", "AM" },
        btn4 = { 258.20, "B-4 HUMAN Red Crown UHF", "AM" },
        btn15 = { 260.20, "B-15 HUMAN CCA Fianal A", "AM" },
        btn16 = { 260.30, "B-16 AIRBOSS/HUMAN Marshal UHF", "AM" },
        btn17 = { 260.40, "B-17 HUMAN CCA Fianal B", "AM" },
    },
    SPECIAL = {
        guard_hi = { 243.00, "Guard UHF", "AM" },
        guard_lo = { 121.50, "Guard VHF", "AM" },
        ch_16 = { 156.8, "Maritime Ch16 VHF", "FM" }
    },
    ICLS = {
        sc_75 = { 11, "CVN", "ICLS CVN-75" },
    },
    TACAN = {
        sc_75 = { 75, "X", "CVN", "CVN-75" },
        arco = { 1, "Y", "RCV", "Recovery Tanker" },
        shell_one = { 51, "Y", "SH1", "Tanker Texaco One" },
        texaco_one = { 52, "Y", "TX1", "Tanker Texaco One" },
        texaco_two = { 54, "Y", "TX2", "Tanker Texaco One" },
    }
}
