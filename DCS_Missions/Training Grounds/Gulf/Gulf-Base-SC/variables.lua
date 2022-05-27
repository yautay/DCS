function frequencies()
    local frequencies_data = {
        freq_flight = {242.00, "FLIGHTS Hi AM"},
        freq_flight_lo = {128.5, "FLIGHTS Lo AM"},
        freq_flight_fm = {41.9, "FLIGHTS FM"},
        freq_awacs = {247.50, "AWACS"},
        freq_aar = {243.25, "TANKERS"},
        freq_lso = {270.00, "Airbos LSO"},
        freq_marshal = {305.00, "Airbos Marshal"},
        freq_al_minhad = {250.10, "Al Minhad Tower"},
        freq_al_minhad_lo = {118.55, "Al Minhad Tower"},
        freq_al_minhad_fm = {38.5, "Al Minhad Tower"},
        freq_khasab = {250.00, "Khasab Tower"},
        freq_sc = {127.50, "CVN71 Tower"},
        freq_elint_hi = {255.50, "ELINT Hi"},
        freq_elint_lo = {121.75, "ELINT Lo"},
        freq_elint_fm = {35.00, "ELINT Fm"},
        freq_atis_hi = {256.50, "ATIS Hi"},
        freq_atis_lo = {122.75, "ATIS Lo"},
        freq_heli_flights_ru = {128.50, "RU Heli"},
        freq_sc = {127.50, "CVN71 Tower"}

    }
    return frequencies_data
end

function manual_ordered_frequencies()
    local freqs = frequencies()
    local ordered_frequencies_data = {
        freqs.freq_flight,
        freqs.freq_flight_lo,
        freqs.freq_flight_fm,
        freqs.freq_aar,
        freqs.freq_awacs,
        freqs.freq_sc,
        freqs.freq_al_minhad,
        freqs.freq_khasab,
        freqs.freq_lso,
        freqs.freq_marshal,
        freqs.freq_atis_hi,
        freqs.freq_atis_lo,
        freqs.freq_elint_hi,
        freqs.freq_elint_lo,
        freqs.freq_elint_fm
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