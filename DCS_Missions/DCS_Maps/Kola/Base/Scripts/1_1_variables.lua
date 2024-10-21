VAR_KOLA = {
    FREQUENCIES = {
        MAP = {
            EFRO = {
                atis = { 126.700, "ATIS EFRO", "AM" },
                twr_1 = { 38.700, "TOWER EFRO VHF/LOW", "AM" },
                twr_2 = { 118.700, "25TOWER EFRO VHF", "AM" },
                twr_3 = { 250.250, "TOWER EFRO UHF", "AM" },
            },
            ENBO = {
                atis = { 126.900, "ATIS ENBO", "AM" },
                twr_1 = { 38.950, "TOWER ENBO VHF/LOW", "AM" },
                twr_2 = { 118.300, "25TOWER ENBO VHF", "AM" },
                twr_3 = { 250.450, "TOWER ENBO UHF", "AM" },
            },
            BAS100 = {
                atis = { 126.250, "ATIS BAS100", "AM" },
                twr_1 = { 38.800, "TOWER BAS100 VHF/LOW", "AM" },
                twr_2 = { 118.250, "TOWER BAS100 VHF", "AM" },
                twr_3 = { 257.100, "TOWER BAS100 UHF", "AM" },
                farp_warsaw = { 256.000, "TOWER FARP WARSAW UHF", "AM" },
            },
        },
        AWACS = {
            wizard = { 250.00, "AWACS @ DCS Wizard UHF", "AM" },
            darkstar = { 249.00, "AWACS @ Darkstar C3i UHF", "AM" },
        },
        AAR = {
            navy_one = { 252.50, "Tanker Navy One UHF", "AM" },
            texaco_one = {252.30, "Tanker Texaco One UHF", "AM" },
            texaco_two = {252.30, "Tanker Texaco Two UHF", "AM" },
            shell_one = {252.10, "Tanker Shell One UHF", "AM" },
            shell_two = {252.10, "Tanker Shell Two UHF", "AM" }
        },
        FLIGHTS = {
            vfma212_1_u = { 266.20, "SQUADRON VFMA-212 UHF", "AM" },
            vfma212_2_u = { 266.25, "SQUADRON VFMA-212 UHF", "AM" },
            vfma212_3_u = { 266.80, "SQUADRON VFMA-212 UHF", "AM" },
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
        }
    },
    ICLS = {
        sc_75 = { 11, "CV5", "ICLS CVN-75" },
    },
    TACAN = {
        sc_75 = { 75, "X", "CVN", "CVN-75" },
        navy_one = { 1, "Y", "RCV", "Recovery Tanker CVN-75", true },
        texaco_one = { 52, "Y", "TX1", "Tanker Texaco One", true },
        texaco_two = { 54, "Y", "TX2", "Tanker Texaco Two", true },
        shell_one = { 51, "Y", "SH1", "Tanker Shell One", true },
        shell_two = { 53, "Y", "SH2", "Tanker Shell Two", true },
    }
}


