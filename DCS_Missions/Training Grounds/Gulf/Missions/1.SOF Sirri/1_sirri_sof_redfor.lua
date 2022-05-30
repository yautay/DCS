local template_SOF_tr = "SOF-transport-mi8"
local template_SOF_es = "SOF-escort-ka50"
local template_SOF_operator = "SOF-operator"

local zone_SOF_pickup_OMDM = ZONE:New("SOF-PZ")
local zones_SOF_landing_Sirri = {alpha = ZONE:New("SOF-LZ-A"), bravo = ZONE:New("SOF-LZ-B"), charlie = ZONE:New("SOF-LZ-C")}
local zones_SOF_ingress_Sirri = {alpha = ZONE:New("SOF-IP-A"), bravo = ZONE:New("SOF-IP-B"), charlie = ZONE:New("SOF-IP-C")}
local zones_SOF_waiting_Sirri = {alpha = ZONE:New("SOF-WZ-A"), bravo = ZONE:New("SOF-WZ-B"), charlie = ZONE:New("SOF-WZ-C")}
local zone_SOF_spawn = ZONE:New("SOF-spawn")

local planned_SOF_teams = {
	{template_SOF_operator, "ALPHA"},
	{template_SOF_operator, "BRAVO"},
	{template_SOF_operator, "CHARLIE"}
}

local planned_SOF_tr_helos = {
	{template_SOF_tr, "LORRY ALPHA"},
	{template_SOF_tr, "LORRY BRAVO"},
	{template_SOF_tr, "LORRY CHARLIE"}
}

function spawn_sof_teams(teams_definition, spawn_zones)
	local sof_teams = {}
	for i, v in pairs(teams_definition) do
		local team = SPAWN
		:NewWithAlias(v[1], v[2])
		:InitRandomizeZones(spawn_zones)
		:OnSpawnGroup(
			function( SpawnGroup )
  			-- CARGO_GROUP:New( SpawnGroup, "Infantry", SpawnGroup:GetName(), 500, 25 )
  			local g_name = SpawnGroup:GetName()
  			local g_size = SpawnGroup:GetSize()
  			env.info(string.format("DEBUG -> Spawned group %s of %s elements", g_name, g_size))
			end)
		:Spawn()
		table.insert(sof_teams, team)
	end
	return sof_teams
end

function spawn_sof_delivery_helos(tr_helo_group_definition)
	local tr_helos = {}
	for i, v in pairs(tr_helo_group_definition) do
		local group = SPAWN
		:NewWithAlias(v[1], v[2])
		:OnSpawnGroup(
			function( SpawnGroup )
  			-- CARGO_GROUP:New( SpawnGroup, "Infantry", SpawnGroup:GetName(), 500, 25 )
  			local g_name = SpawnGroup:GetName()
  			local g_size = SpawnGroup:GetSize()
  			env.info(string.format("DEBUG -> Spawned helo group %s of %s elements", g_name, g_size))
			end)
		:Spawn()
		table.insert(tr_helos, group)
	end
	return tr_helos
end

sof_ground_elements = spawn_sof_teams(planned_SOF_teams, {zone_SOF_spawn})
sof_tr_helos = spawn_sof_delivery_helos(planned_SOF_tr_helos)




-- local InfantryGroup = GROUP:FindByName( "Infantry" )

-- local InfantryCargo = CARGO_GROUP:New( InfantryGroup, "Engineers", "Infantry Engineers", 2000 )

-- local CargoCarrier = UNIT:FindByName( "Carrier" )

-- -- This call will make the Cargo run to the CargoCarrier.
-- -- Upon arrival at the CargoCarrier, the Cargo will be Loaded into the Carrier.
-- -- This process is now fully automated.
-- InfantryCargo:Board( CargoCarrier, 25 ) 
