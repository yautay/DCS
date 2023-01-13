ZONE_SPAWN_1 = ZONE:New("SPAWN-1")
ZONE_SPAWN_2 = ZONE:New("SPAWN-2")
ZONE_SPAWN_3 = ZONE:New("SPAWN-3")
ZONE_SPAWN_4 = ZONE:New("SPAWN-4")
ZONE_SPAWN_5 = ZONE:New("SPAWN-5")
ZONE_SPAWN_6 = ZONE:New("SPAWN-6")

SPAWN_ZONES = {ZONE_SPAWN_1, ZONE_SPAWN_2, ZONE_SPAWN_3, ZONE_SPAWN_4, ZONE_SPAWN_5, ZONE_SPAWN_6}

TEMPLATE_SU27 = "SPAWN-RED-BVR-SU27_"
TEMPLATE_MiG23 = "SPAWN-RED-BVR-M23_"
TEMPLATE_MiG29 = "SPAWN-RED-BVR-M29_"
TEMPLATE_SU30 = "SPAWN-RED-BVR-SU30_"

SUFFIX_ACE = "ACE"
SUFFIX_VET = "VET"
SUFFIX_TRN = "TRN"

MenuBvr = MENU_MISSION:New("BVR", MenuServer)
MenuBvr_Su27 = MENU_MISSION:New("Су-27", MenuBvr)
MenuBvr_Su30 = MENU_MISSION:New("Су-30", MenuBvr)
MenuBvr_Mig23 = MENU_MISSION:New("МиГ-23", MenuBvr)
MenuBvr_Mig29 = MENU_MISSION:New("МиГ-29", MenuBvr)

local function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

local function spawn(template_name)
    local spawned_group = SPAWN
            :New(template_name)
            :InitRandomizeZones( SPAWN_ZONES )
            :Spawn()
    //TODO
    spawned_group:RouteAirTo(ToCoordinate, AltType, Type, Action, Speed, DelaySeconds)
    return spawned_group
end

MENU_MISSION_COMMAND:New("Ace", MenuBvr_Su27, Msg, {spawn, TEMPLATE_SU27 .. SUFFIX_ACE})
MENU_MISSION_COMMAND:New("Veteran", MenuBvr_Su27, Msg, {spawn, TEMPLATE_SU27 .. SUFFIX_VET})
MENU_MISSION_COMMAND:New("Trained", MenuBvr_Su27, Msg, {spawn, TEMPLATE_SU27 .. SUFFIX_TRN})

