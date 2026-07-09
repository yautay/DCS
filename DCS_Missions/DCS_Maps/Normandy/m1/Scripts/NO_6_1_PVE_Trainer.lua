TEMPLATE_JU88 = "TEMPLATE JU88"

MenuPVE_Blue = MENU_COALITION:New(coalition.side.BLUE, "PVE Trainer")

MenuPVE_Aspect = MENU_COALITION:New(coalition.side.BLUE, "Aspect", MenuPVE_Blue)

MenuPVE_Altitude = MENU_COALITION:New(coalition.side.BLUE, "Altitude", MenuPVE_Blue)

MenuPVE_Bearing = MENU_COALITION:New(coalition.side.BLUE, "Bearing", MenuPVE_Blue)


MenuPVE_Ju88 = MENU_COALITION:New(coalition.side.BLUE, "Ju-88", MenuPVE)

local function set_altitude()
    local spawned_group = SPAWN
        :New(template_name)
        :InitRandomizeZones( SPAWN_ZONES )
        :Spawn()
    local dest = ZONE_ENGAGE:GetVec2()
    local coord_dest = COORDINATE:NewFromVec2(dest, UTILS.FeetToMeters(15000))
    spawned_group:RouteAirTo(coord_dest, COORDINATE.WaypointAltType.BARO, COORDINATE.WaypointType.TurningPoint, COORDINATE.WaypointAction.FlyoverPoint, UTILS.KnotsToKmph(250))
    spawned_group:EnRouteTaskEngageTargetsInZone(dest, UTILS.NMToMeters(60))
    local msg = template_name .. " SPAWNED!"
    msgToAll({msg, 3})
end

local function Spawn_Group(template_name)
    local spawned_group = SPAWN
        :New(template_name)
        :InitRandomizeZones( SPAWN_ZONES )
        :Spawn()
    local dest = ZONE_ENGAGE:GetVec2()
    local coord_dest = COORDINATE:NewFromVec2(dest, UTILS.FeetToMeters(15000))
    spawned_group:RouteAirTo(coord_dest, COORDINATE.WaypointAltType.BARO, COORDINATE.WaypointType.TurningPoint, COORDINATE.WaypointAction.FlyoverPoint, UTILS.KnotsToKmph(250))
    spawned_group:EnRouteTaskEngageTargetsInZone(dest, UTILS.NMToMeters(60))
    local msg = template_name .. " SPAWNED!"
    msgToAll({msg, 3})
end


-- SU-27
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Spawn", MenuPVE_A20, Spawn_Group, TEMPLATE_A20)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Spawn", MenuPVE_P51, Spawn_Group, TEMPLATE_MUSTANG)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Spawn", MenuPVE_SPIT, Spawn_Group, TEMPLATE_SPITFIRE)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Spawn", MenuPVE_MOSIE, Spawn_Group, TEMPLATE_MOSQUITO)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Spawn", MenuPVE_YAK, Spawn_Group, TEMPLATE_YAK)
