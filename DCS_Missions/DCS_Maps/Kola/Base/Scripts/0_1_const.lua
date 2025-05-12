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
            F16_SINGLETON = { "TEMPLATE_F16", "BVR", 80, "F-16 1-ship" },
            F5_SINGLETON = { "TEMPLATE_F5", "VVR", 10, "F-5 1-ship" },
            F86_SINGLETON = { "TEMPLATE_F86", "VVR", 5, "F-86 1-ship" },
            JAS39_SINGLETON = { "TEMPLATE_JAS39", "BVR", 100, "JAS-39 1-ship" },
            MIG15_SINGLETON = { "TEMPLATE_MiG15", "GUNS ONLY", 5, "MiG-15 1-ship" },
            MIG19_SINGLETON = { "TEMPLATE_MiG19", "VVR", 10, "MiG-19 1-ship" },
            MIG21_SINGLETON = { "TEMPLATE_MiG21", "VVR", 30, "MiG-21 1-ship" },
            MIG29_SINGLETON = { "TEMPLATE_MiG-29-GUNS", "GUNS ONLY", 5, "MiG-29 1-ship" },
            MIG31_SINGLETON = { "TEMPLATE_MiG31", "BVR", 200, "MiG-31 1-ship" },
            F16_PAIR = { "TEMPLATE_F16-2", "BVR", 80, "F-16 2-ship" },
            F5_PAIR = { "TEMPLATE_F5-2", "VVR", 10, "F-5 2-ship" },
            F86_PAIR = { "TEMPLATE_F86-2", "VVR", 5, "F-86 2-ship" },
            JAS39_PAIR = { "TEMPLATE_JAS39-2", "BVR", 100, "JAS-39 2-ship" },
            MIG15_PAIR = { "TEMPLATE_MiG15-2", "GUNS ONLY", 5, "MiG-15 2-ship" },
            MIG19_PAIR = { "TEMPLATE_MiG19-2", "VVR", 10, "MiG-19 2-ship" },
            MIG21_PAIR = { "TEMPLATE_MiG21-2", "VVR", 30, "MiG-21 2-ship" },
            MIG31_PAIR = { "TEMPLATE_MiG31-2", "BVR", 200, "MiG-31 2-ship" },
            MIG29_PAIR = { "TEMPLATE_MiG-29-GUNS-2", "GUNS ONLY", 5, "MiG-29 2-ship" },
        }
    }
}


