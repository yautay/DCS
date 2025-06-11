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
            RED_AWACS = "Red EWR AWACS",
            RED_AAR = "TEMPLATE_Il78",
            RED_CAP = "TEMPLATE_RED_CAP",
            RED_ESCORT = "TEMPLATE_RED_ESCORT",
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

ZoneRedAccept=ZONE_POLYGON:NewFromGroupName("Red Accept Zone"):DrawZone()
ZoneRedReject=ZONE_POLYGON:NewFromGroupName("Red Reject Zone")
ZoneRedDefend=ZONE_POLYGON:NewFromGroupName("Red Defend Zone"):DrawZone()


ZoneRedTankers = ZONE:FindByName("Zone RED AAR")
ZoneRedAwacs = ZONE:FindByName("Zone RED AWACS")
ZoneRedCAP = ZONE:FindByName("Zone RED CAP")