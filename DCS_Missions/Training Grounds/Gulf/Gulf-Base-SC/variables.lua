function frequencies()
    local frequencies_data = {
        freq_flight = {242.00, "FLIGHTS"},
        freq_awacs = {247.50, "AWACS"},
        freq_aar = {243.25, "TANKERS"},
        freq_lso = {270.00, "Airbos LSO"},
        freq_marshal = {305.00, "Airbos Marshal"},
        freq_al_minhad = {250.10, "Al Minhad Tower"},
        freq_khasab = {250.00, "Khasab Tower"},
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
        freqs.freq_al_minhad,
        freqs.freq_khasab,
        freqs.freq_lso,
        freqs.freq_marshal
    }
    return ordered_frequencies_data
end

function icls()
    local icls_data = {
        icls_sc = {1, "CVN", "ICLS CVN-71"},
        ils_al_minhad090 = {110.70, "n/a", "ILS Al Minhad rwy 09"},
        ils_al_minhad270 = {110.75, "n/a", "ILS Al Minhad rwy 27"},
        ils_khasab194 = {110.75, "n/a", "ILS Khasab rwy 19"}
    }
    return icls_data
end

function manual_ordered_icls()
    local icls = icls()
    local ordered_icls = {
        icls.icls_sc,
        icls.ils_al_minhad090,
        icls.ils_al_minhad270,
        icls.ils_khasab194
    }
    return ordered_icls
end

function tacans()
    local tacans_data = {
        tacan_sc = {74, "X", "CVN", "CVN-71"},
        tacan_arco = {1, "X", "RCV", "Recovery Tanker CVN-71"},
        tacan_shell = {70, "X", "SHL", "Tanker Shell"},
        tacan_al_minhad = {99, "X", "MIN", "Al Minhad AFB"}
    }
    return tacans_data
end

function manual_ordered_tacans()
    local tcs = tacans()
    local ordered_tcs = {
        tcs.tacan_sc,
        tcs.tacan_arco,
        tcs.tacan_shell,
        tcs.tacan_al_minhad,
    }
    return ordered_tcs
end

function air_routes()
    local routes_data = {
        {"Incirlik", 167, 100, "Al-Assad"},
        {"Paphos", 79, 176, "Al-Assad"},
        {"Paphos", 113, 132, "Beirut"},
        {"Akrotiri", 74, 155, "Al-Assad"},
        {"Ramat David", 15, 169, "Al-Assad"}
    }
    return routes_data
end