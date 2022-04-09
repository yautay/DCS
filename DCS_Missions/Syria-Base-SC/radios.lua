local frequencies = frequencies()

function presets()
    local f14_1 = {
        c1 = frequencies.freq_marshal,
        c2 = frequencies.freq_lso,
        c3 = frequencies.freq_awacs,
        c4 = frequencies.freq_aar,
        c7 = frequencies.freq_flight
    }
    local f14_2 = {
        c1 = frequencies.freq_marshal,
        c2 = frequencies.freq_lso,
        c3 = frequencies.freq_awacs,
        c4 = frequencies.freq_aar,
        c7 = frequencies.freq_flight,
        c10 = frequencies.freq_sc
    }
    local f16_1 = {
        c1 = frequencies.freq_incirlik_2,
        c3 = frequencies.freq_awacs,
        c4 = frequencies.freq_aar,
        c7 = frequencies.freq_flight,
        c10 = frequencies.freq_incirlik_2
    }
    local f16_2 = {
        c1 = frequencies.freq_incirlik_1,
        c10 = frequencies.freq_incirlik_1
    }
    local f18_1 = {
        c1 = frequencies.freq_marshal,
        c2 = frequencies.freq_lso,
        c3 = frequencies.freq_awacs,
        c4 = frequencies.freq_aar,
        c7 = frequencies.freq_flight,
        c10 = frequencies.freq_sc
    }
    local f18_2 = {
        c1 = frequencies.freq_marshal,
        c2 = frequencies.freq_lso,
        c3 = frequencies.freq_awacs,
        c4 = frequencies.freq_aar,
        c7 = frequencies.freq_flight,
        c10 = frequencies.freq_sc
    }
    local presets_data = {
        preset_f14_1 = f14_1,
        preset_f14_2 = f14_2,
        preset_f16_1 = f16_1,
        preset_f16_2 = f16_2,
        preset_f18_1 = f18_1,
        preset_f18_2 = f18_2
    }
    return presets_data
end
