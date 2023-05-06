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
TEMPLATE_TU22 = "SPAWN-RED-BVR-TU22_"

SUFFIX_ACE = "ACE"
SUFFIX_VET = "VET"
SUFFIX_TRN = "TRN"

SUFFIX_PAIR = "-2"


MenuBvr = MENU_COALITION:New(coalition.side.BLUE, "BVR Trainer", MenuCoalitionBlue)
MenuBvr_Su27 = MENU_COALITION:New(coalition.side.BLUE, "Cy-27", MenuBvr)
MenuBvr_Su30 = MENU_COALITION:New(coalition.side.BLUE, "Су-30", MenuBvr)
MenuBvr_Mig23 = MENU_COALITION:New(coalition.side.BLUE, "МиГ-23", MenuBvr)
MenuBvr_Mig29 = MENU_COALITION:New(coalition.side.BLUE, "МиГ-29", MenuBvr)
MenuBvr_Tu22 = MENU_COALITION:New(coalition.side.BLUE, "Ту-22М", MenuBvr)

MenuBvr_Su27_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Su27)
MenuBvr_Su27_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Su27)
MenuBvr_Su27_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Su27)

MenuBvr_Su30_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Su30)
MenuBvr_Su30_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Su30)
MenuBvr_Su30_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Su30)

MenuBvr_Mig23_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Mig23)
MenuBvr_Mig23_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Mig23)
MenuBvr_Mig23_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Mig23)

MenuBvr_Mig29_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Mig29)
MenuBvr_Mig29_vet = MENU_COALITION:New(coalition.side.BLUE, "Vet", MenuBvr_Mig29)
MenuBvr_Mig29_trn = MENU_COALITION:New(coalition.side.BLUE, "Trn", MenuBvr_Mig29)

MenuBvr_Tu22_ace = MENU_COALITION:New(coalition.side.BLUE, "Ace", MenuBvr_Tu22)


local function Spawn_Group(template_name)
    local spawned_group = SPAWN
           :New(template_name)
           :InitRandomizeZones( SPAWN_ZONES )
           :Spawn()
    local dest = ZONE_DARKSTAR_1_ENGAGE:GetVec2()
    local coord_dest = COORDINATE:NewFromVec2(dest, UTILS.FeetToMeters(30000))
    spawned_group:RouteAirTo(coord_dest, COORDINATE.WaypointAltType.BARO, COORDINATE.WaypointType.TurningPoint, COORDINATE.WaypointAction.FlyoverPoint, UTILS.KnotsToKmph(750))
    spawned_group:EnRouteTaskEngageTargetsInZone(dest, UTILS.NMToMeters(60))
    local msg = template_name .. " SPAWNED!"
    msgToAll({msg, 3})
end

local function Spawn_Backfires_Strike()
    SPAWN:New(TEMPLATE_TU22 .. SUFFIX_ACE .. "-1"):Spawn()
    SPAWN:New(TEMPLATE_TU22 .. SUFFIX_ACE .. "-2"):Spawn()
    SPAWN:New(TEMPLATE_TU22 .. SUFFIX_ACE .. "-3"):Spawn()
    msgToAll({"Backfires strike spawned!", 3})
end

local function Spawn_Set(set_group)
    set_group:Activate()
end

-- SU-27
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su27_ace, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su27_ace, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su27_vet, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su27_vet, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su27_trn, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su27_trn, Spawn_Group, TEMPLATE_SU27 .. SUFFIX_TRN .. SUFFIX_PAIR)
-- SU-30
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su30_ace, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su30_ace, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su30_vet, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su30_vet, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Su30_trn, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Su30_trn, Spawn_Group, TEMPLATE_SU30 .. SUFFIX_TRN .. SUFFIX_PAIR)
-- MiG-23
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig23_ace, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig23_ace, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig23_vet, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig23_vet, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig23_trn, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig23_trn, Spawn_Group, TEMPLATE_MiG23 .. SUFFIX_TRN .. SUFFIX_PAIR)
-- MiG-29
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig29_ace, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_ACE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig29_ace, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_ACE .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig29_vet, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_VET)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig29_vet, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_VET .. SUFFIX_PAIR)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Singleton", MenuBvr_Mig29_trn, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_TRN)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Pair", MenuBvr_Mig29_trn, Spawn_Group, TEMPLATE_MiG29 .. SUFFIX_TRN .. SUFFIX_PAIR)
-- Tu-22
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Four-Ship", MenuBvr_Tu22_ace, Spawn_Backfires_Strike)
