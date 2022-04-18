function frequencies()
    local frequencies_data = {
        freq_flight = {242.00, "FLIGHTS"},
        freq_awacs = {247.50, "AWACS"},
        freq_aar = {243.25, "TANKERS"},
        freq_lso = {270.00, "Airbos LSO"},
        freq_marshal = {305.00, "Airbos Marshal"},
        freq_incirlik_1 = {122.10, "Incirlik Tower"},
        freq_incirlik_2 = {360.10, "Incirlik Tower"},
        freq_paphos_1 = {119.90, "Paphos Tower"},
        freq_paphos_2 = {251.80, "Paphos Tower"},
        freq_larnaca_1 = {121.20, "Larnaca Tower"},
        freq_larnaca_2 = {251.85, "Larnaca Tower"},
        freq_sc = {127.50, "CVN71 Tower"}
    }
    return frequencies_data
end

function manual_ordered_frequencies()
    local freqs = frequencies()
    local ordered_frequencies_data = {
        freqs.freq_flight,
        freqs.freq_aar,
        freqs.freq_awacs,
        freqs.freq_sc,
        freqs.freq_paphos_1,
        freqs.freq_paphos_2,
        freqs.freq_larnaca_1,
        freqs.freq_larnaca_2,
        freqs.freq_incirlik_1,
        freqs.freq_incirlik_2,
        freqs.freq_lso,
        freqs.freq_marshal
    }
    return ordered_frequencies_data
end

function icls()
    local icls_data = {
        icls_sc = {1, "CVN", "ICLS CVN-71"},
        icls_akrotiri287 = {109.70, "n/a", "ILS Akrotiri rwy 287"},
        icls_larnaca224 = {110.30, "n/a", "ILS Larnaca rwy 224"},
        icls_paphos290 = {108.90, "n/a", "ILS Paphos rwy 290"},
        icls_incirlik050 = {109.30, "n/a", "ILS Incirlik rwy 050"},
        icls_incirlik230 = {111.70, "n/a", "ILS Incirlik rwy 230"},
        icls_ramat_david323 = {111.10, "n/a", "ILS Incirlik rwy 323"}
    }
    return icls_data
end

function manual_ordered_icls()
    local icls = icls()
    local ordered_icls = {
        icls.icls_sc,
        icls.icls_paphos290,
        icls.icls_akrotiri287,
        icls.icls_incirlik050,
        icls.icls_incirlik230,
        icls.icls_ramat_david323
    }
    return ordered_icls
end

function tacans()
    local tacans_data = {
        tacan_sc = {74, "X", "CVN", "CVN-71"},
        tacan_arco = {1, "Y", "TA", "Recovery Tanker CVN-71"},
        tacan_shell = {70, "Y", "SHL", "Tanker Shell - SE of CYP"},
        tacan_texaco = {71, "Y", "TEX", "Tanker Texaco - off Iskenderun Bay"},
        tacan_be = {13, "X", "BE", "Cape Apostolos"},
        tacan_incirlik = {21, "X", "DAN", "Incirlik Air Base"},
        tacan_paphos = {79, "X", "n/a", "Paphos Air Base"},
        tacan_akrotiri = {107, "X", "n/a", "Akrotiri Air Base"},
        tacan_ramat_david = {84, "X", "n/a", "Ramat David Air Base"}
    }
    return tacans_data
end

function manual_ordered_tacans()
    local tcs = tacans()
    local ordered_tcs = {
        tcs.tacan_sc,
        tcs.tacan_arco,
        tcs.tacan_shell,
        tcs.tacan_texaco,
        tcs.tacan_be,
        tcs.tacan_paphos,
        tcs.tacan_akrotiri,
        tcs.tacan_incirlik,
        tcs.tacan_ramat_david
    }
    return ordered_tcs
end

function air_routes()
    local routes_data = {
        {"BE", 108, 68, "Al-Assad"},
        {"Incirlik", 167, 100, "Al-Assad"},
        {"Paphos", 79, 176, "Al-Assad"},
        {"Paphos", 113, 132, "Beirut"},
        {"Akrotiri", 74, 155, "Al-Assad"},
        {"Ramat David", 15, 169, "Al-Assad"}
    }
    return routes_data
end