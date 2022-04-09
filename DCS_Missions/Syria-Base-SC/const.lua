function frequencies()
    local frequencies_data = {
        freq_flight = 242.00,
        freq_awacs = 247.50,
        freq_aar = 243.25,
        freq_lso = 270.00,
        freq_marshal = 305.00,
        freq_incirlik_1 = 122.1,
        freq_incirlik_2 = 360.1,
        freq_sc = 127.5
    }
    return frequencies_data
end

function frequencies_type()
    local frequencies_type_data = {
        freq_flight = "flights",
        freq_awacs = "awacs",
        freq_aar = "tanker",
        freq_lso = "Airbos Lso",
        freq_marshal = "Airbos Marshal",
        freq_incirlik_1 = "Incirlik Tower",
        freq_incirlik_2 = "Incirlik Tower",
        freq_sc = "USS Theodore Roosevelt Tower"
    }
    return frequencies_data
end
