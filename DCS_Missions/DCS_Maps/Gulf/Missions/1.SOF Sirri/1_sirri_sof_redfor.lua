local template_SOF_tr = "SOF-transport-mi8"
local template_SOF_es = "SOF-escort-ka50"
local template_SOF_operator = "SOF-operator"

local zone_SOF_pickup_OMDM = ZONE:New("SOF-PZ")
local zones_SOF_landing_Sirri = {alpha = ZONE:New("SOF-LZ-A"), bravo = ZONE:New("SOF-LZ-B"), charlie = ZONE:New("SOF-LZ-C")}
local zones_SOF_ingress_Sirri = {alpha = ZONE:New("SOF-IP-A"), bravo = ZONE:New("SOF-IP-B"), charlie = ZONE:New("SOF-IP-C")}
local zones_SOF_waiting_Sirri = {alpha = ZONE:New("SOF-WZ-A"), bravo = ZONE:New("SOF-WZ-B"), charlie = ZONE:New("SOF-WZ-C")}
local zone_SOF_spawn = ZONE:New("SOF-spawn")

local planned_SOF_teams = {
	alpha = {template_SOF_operator, "ALPHA"},
	bravo = {template_SOF_operator, "BRAVO"},
	charlie = {template_SOF_operator, "CHARLIE"}
}

local planned_SOF_tr_helos = {
	alpha = {template_SOF_tr, "LORRY ALPHA"},
	bravo = {template_SOF_tr, "LORRY BRAVO"},
	charlie = {template_SOF_tr, "LORRY CHARLIE"}
}


function spawn_sof_team(team_definition, spawn_zones)
	local team = SPAWN
	:NewWithAlias(team_definition[1], team_definition[2])
	:InitRandomizeZones(spawn_zones)
	:OnSpawnGroup(
		function( SpawnGroup )
			local g_name = SpawnGroup:GetName()
			local g_elements = SpawnGroup:GetSize()
			if (g_elements == nil) then
				g_elements = 0
			end 
			env.info(string.format("DEBUG -> sof group %s contains %s elements", g_name, g_elements))
		end)
	:Spawn()
	return team
end

function spawn_sof_delivery_helo_group(tr_helo_group_definition)
	local group = SPAWN
	:NewWithAlias(tr_helo_group_definition[1], tr_helo_group_definition[2])
	:OnSpawnGroup(
		function( SpawnGroup )
			local g_name = SpawnGroup:GetName()
			local g_size = SpawnGroup:GetSize()
			env.info(string.format("DEBUG -> Spawned helo group %s of %s elements", g_name, g_size))
		end)
	:Spawn()
	return group
end

function create_sof_cargo_group(group_element, cg_name, load_radius, board_radius)
	local sof_cargo = CARGO_GROUP:New( group_element, cg_name, group_element:GetName(), load_radius, board_radius)
	local cg_count = sof_cargo:GetCount()
	env.info(string.format("DEBUG -> Spawned cargo group %s of %s elements", group_element:GetName(), cg_count))
	return sof_cargo
end

local sof_ground_elements = {
	alpha = spawn_sof_team(planned_SOF_teams.alpha, {zone_SOF_spawn}),
	bravo = spawn_sof_team(planned_SOF_teams.bravo, {zone_SOF_spawn}),
	charlie = spawn_sof_team(planned_SOF_teams.charlie, {zone_SOF_spawn})
}

local sof_tr_helos = {
	alpha = spawn_sof_delivery_helo_group(planned_SOF_tr_helos.alpha),
	bravo = spawn_sof_delivery_helo_group(planned_SOF_tr_helos.bravo),
	charlie = spawn_sof_delivery_helo_group(planned_SOF_tr_helos.charlie)
}

local sof_cargo_groups = {
	alpha = create_sof_cargo_group(sof_ground_elements.alpha, "Infantry", "SOF-operator", 250, 10),
	bravo = create_sof_cargo_group(sof_ground_elements.bravo, "Infantry", "SOF-operator", 250, 10),
	charlie = create_sof_cargo_group(sof_ground_elements.charlie, "Infantry", "SOF-operator", 250, 10)
}


local test_units = sof_tr_helos.alpha:GetUnits()
local heli = test_units[1]
local squad = sof_cargo_groups.alpha
env.info("KUTAS")
env.info(heli:GetName())
if (squad:CanBoard() == true) then
	env.info("SQ CAN BOARD")
else
	env.info("SQ CAN NOT BOARD")
end

-- squad:Smoke(SMOKECOLOR.Red, 50)
squad:Board(heli, 500)

-- sof_cargo_groups.alpha:Board(sof_tr_helos.alpha:GetFirstUnitAlive(), 25)

-- local InfantryGroup = GROUP:FindByName( "Infantry" )

-- local InfantryCargo = CARGO_GROUP:New( InfantryGroup, "Engineers", "Infantry Engineers", 2000 )

-- local CargoCarrier = UNIT:FindByName( "Carrier" )

-- -- This call will make the Cargo run to the CargoCarrier.
-- -- Upon arrival at the CargoCarrier, the Cargo will be Loaded into the Carrier.
-- -- This process is now fully automated.
-- InfantryCargo:Board( CargoCarrier, 25 ) 
