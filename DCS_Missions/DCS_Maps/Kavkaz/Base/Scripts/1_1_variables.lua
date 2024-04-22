BASES = {
  ["Gelendzhik"] = "Gelendzhik",
  ["Krasnodar_Pashkovsky"] = "Krasnodar-Pashkovsky",
  ["Sukhumi_Babushara"] = "Sukhumi-Babushara",
  ["Gudauta"] = "Gudauta",
  ["Batumi"] = "Batumi",
  ["Senaki_Kolkhi"] = "Senaki-Kolkhi",
  ["Kobuleti"] = "Kobuleti",
  ["Kutaisi"] = "Kutaisi",
  ["Tbilisi_Lochini"] = "Tbilisi-Lochini",
  ["Soganlug"] = "Soganlug",
  ["Vaziani"] = "Vaziani",
  ["Anapa_Vityazevo"] = "Anapa-Vityazevo",
  ["Krasnodar_Center"] = "Krasnodar-Center",
  ["Novorossiysk"] = "Novorossiysk",
  ["Krymsk"] = "Krymsk",
  ["Maykop_Khanskaya"] = "Maykop-Khanskaya",
  ["Sochi_Adler"] = "Sochi-Adler",
  ["Mineralnye_Vody"] = "Mineralnye Vody",
  ["Nalchik"] = "Nalchik",
  ["Mozdok"] = "Mozdok",
  ["Beslan"] = "Beslan",
}

FREQUENCIES_MAP = {
    GROUND = {
            atis_ag1651 = {125.000, "ATIS Senaki", "AM"},
            twr_ag1651_1 = {40.600, "TOWER Senaki VHF/LOW", "AM"},
            twr_ag1651_2 = {132.000, "TOWER Senaki VHF", "AM"},
            twr_ag1651_3 = {261.000, "TOWER Senaki UHF", "AM"},
        },
    SPECIAL = {
        guard_hi = {243.00, "Guard UHF", "AM"},
        guard_lo = {121.50, "Guard VHF", "AM"},
        ch_16 = {156.8, "Maritime Ch16 VHF", "FM"},
        lobby = {251.00, "Lobby UHF", "FM"}
    },
}
FREQUENCIES = {
     GCI = {
        GCI_SENAKI = {249.00, "GCI @MOOSE Darkstar UHF", "AM"},
    },
    RANGE = {
            CONTROL_KOBULETI = {258.00, "RANGE CONTROL VHF", "AM"},
            INSTRUCTOR_KOBULETI = {255.00, "RANGE INSTRUCTOR VHF", "AM"}
            },
    FLIGHTS = {
        JG52_1 = {45, "JG52 Ch1", "AM"},
        JG52_2 = {40.6, "JG52 Ch2", "AM"},
        JG52_3 = {41, "JG52 Ch3", "AM"},
        JG52_4 = {42, "JG52 Ch4", "AM"},
        COALITION_1 = {132, "COALITION #1", "AM"},
        COALITION_2 = {101, "COALITION #2", "AM"},
        COALITION_3 = {102, "COALITION #3", "AM"},
        COALITION_4 = {103, "COALITION #4", "AM"},
    },
}
