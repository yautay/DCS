CONST = {
    RGB = {
        range = { 1, .5, 0 },
        farp = { .5, .5, 1 },
        zone_red = { 1, 0, 0 },
        zone_patrol = { 1, 1, 0 },
        zone_bvr = { 1, .5, 1 }
    }
}
HELPERS = {
    SOCKET_NOTAM = "custom_notam"
}
TEMPLATE = {
    SEA = {
        CVN_75 = "CVN-75",
        LHA_1 = "LHA-1"
    },
    OTHERS = {
        CVN_RELAY_MARSHAL = "CVN-75-RELAY-MARSHAL",
        CVN_RELAY_LSO = "CVN-75-RELAY-LSO",
        LHA_RELAY_MARSHAL = "LHA-1-RELAY-MARSHAL",
        LHA_RELAY_LSO = "LHA-1-RELAY-LSO"
    },
    AIR = {
        CVN = {
            CVN_AWACS = "CVN-AWACS",
            CVN_SAR = "CVN-SAR",
            CVN_TANKER = "CVN-TANKER"
        },
        LHA = {
            LHA_SAR = "LHA-SAR",
        },
        ADVERSARY = {
            F16_SINGLETON = { "TEMPLATE_F16", "BVR", 80, "F-16x1" },
            F5_SINGLETON = { "TEMPLATE_F5", "VVR", 15, "F-5x1" },
            F86_SINGLETON = { "TEMPLATE_F86", "VVR", 10, "F-86x1" },
            JAS39_SINGLETON = { "TEMPLATE_JAS39", "BVR", 100, "JAS-39x1" },
            MIG15_SINGLETON = { "TEMPLATE_MiG15", "DOG", 10, "MiG-15x1" },
            MIG19_SINGLETON = { "TEMPLATE_MiG19", "VVR", 15, "MiG-19x1" },
            MIG21_SINGLETON = { "TEMPLATE_MiG21", "VVR", 30, "MiG-21x1" },
            MIG29_SINGLETON = { "TEMPLATE_MiG-29-GUNS", "DOG", 10, "MiG-29x1" },
            MIG31_SINGLETON = { "TEMPLATE_MiG31", "BVR", 200, "MiG-31x1" },
            F16_PAIR = { "TEMPLATE_F16-2", "BVR", 80, "F-16x2" },
            F5_PAIR = { "TEMPLATE_F5-2", "VVR", 15, "F-5x2" },
            F86_PAIR = { "TEMPLATE_F86-2", "VVR", 10, "F-86x2" },
            JAS39_PAIR = { "TEMPLATE_JAS39-2", "BVR", 100, "JAS-39x2" },
            MIG15_PAIR = { "TEMPLATE_MiG15-2", "DOG", 10, "MiG-15x2" },
            MIG19_PAIR = { "TEMPLATE_MiG19-2", "VVR", 15, "MiG-19x2" },
            MIG21_PAIR = { "TEMPLATE_MiG21-2", "VVR", 30, "MiG-21x2" },
            MIG31_PAIR = { "TEMPLATE_MiG31-2", "BVR", 200, "MiG-31x2" },
            MIG29_PAIR = { "TEMPLATE_MiG-29-GUNS-2", "DOG", 10, "MiG-29x2" },
            RED_AWACS = "TEMPLATE_A50",
            RED_AAR = "TEMPLATE_Il78",
            RED_CAP = "TEMPLATE_RED_CAP",
            RED_INTERCEPT = "TEMPLATE_RED_INTERCEPT"

        },
        AAR = {
            SHELL = "TEMPLATE-SHELL",
            TEXACO = "TEMPLATE-TEXACO",
        },
        AWACS = {
            DARKSTAR = "TEMPLATE-DARKSTAR"
        },
        AI = {
            F15C_ESCORTS = "TEMPLATE-ESCORT-F15"
        }
    }
}


