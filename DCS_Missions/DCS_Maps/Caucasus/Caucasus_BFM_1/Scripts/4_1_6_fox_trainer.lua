alpha_1 = ZONE_POLYGON:New("ALPHA ONE", GROUP:FindByName("zone-10")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Squid-1
alpha_2 = ZONE_POLYGON:New("ALPHA TWO", GROUP:FindByName("zone-8")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Devil-1
alpha_3 = ZONE_POLYGON:New("ALPHA THREE", GROUP:FindByName("zone-2")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Hawk-1
alpha_4 = ZONE_POLYGON:New("ALPHA FOUR", GROUP:FindByName("zone-1")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Joker-1
bravo_1 = ZONE_POLYGON:New("BRAVO ONE", GROUP:FindByName("zone-11")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Check-1
bravo_2 = ZONE_POLYGON:New("BRAVO TWO", GROUP:FindByName("zone-9")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)

bravo_3 = ZONE_POLYGON:New("BRAVO THREE", GROUP:FindByName("zone-4")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Ninja-1
bravo_4 = ZONE_POLYGON:New("BRAVO FOUR", GROUP:FindByName("zone-3")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Sting-1
charlie_1 = ZONE_POLYGON:New("CHARLIE ONE", GROUP:FindByName("zone-7")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Jedi-1
delta_1 = ZONE_POLYGON:New("DELTA ONE", GROUP:FindByName("zone-6")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
-- Venom-1
delta_2 = ZONE_POLYGON:New("DELTA0 TWO", GROUP:FindByName("zone-5")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
-- Viper-1

squid_1 = GROUP:FindByName("Squid-1")
devil_1 = GROUP:FindByName("Devil-1")
hawk_1 = GROUP:FindByName("Hawk-1")
joker_1 = GROUP:FindByName("Joker-1")
check_1 = GROUP:FindByName("Check-1")
ninja_1 = GROUP:FindByName("Ninja-1")
sting_1 = GROUP:FindByName("Sting-1")
jedi_1 = GROUP:FindByName("Jedi-1")
venom_1 = GROUP:FindByName("Venom-1")
viper_1 = GROUP:FindByName("Viper-1")

local zones_data = {
	{alpha_1, squid_1},
	{alpha_2, devil_1},
	{alpha_3, hawk_1},
	{alpha_4, joker_1},
	{bravo_1, check_1},
	{bravo_3, ninja_1},
	{bravo_4, sting_1},
	{charlie_1, jedi_1},
	{delta_1, venom_1},
	{delta_2, viper_1},
}

fox=FOX:New()

fox:AddSafeZone(alpha_1)
fox:AddSafeZone(alpha_2)
fox:AddSafeZone(alpha_3)
fox:AddSafeZone(alpha_4)
fox:AddSafeZone(bravo_1)
fox:AddSafeZone(bravo_2)
fox:AddSafeZone(bravo_3)
fox:AddSafeZone(bravo_4)
fox:AddSafeZone(delta_1)
fox:AddSafeZone(delta_2)
fox:Start()

FOX:SetDisableF10Menu(true)
FOX:SetDefaultLaunchAlerts(false)
FOX:SetDefaultLaunchMarks(false)

function get_coords(data)
	local zone_info = {}
	local msg = string.format("BFM ZONES's in use: \n")
	table.insert(zone_info, msg)
	for i, v in pairs(data) do
		local zone = v[1]
		local group = v[2]
		local coordinate = zone:GetCoordinate(0):ToStringLLDMS()
		local tmp_msg = string.format("%s / %s -> %s\n", zone:GetName(), group:GetName(), coordinate)
		table.insert(tmp_msg)
		zone:MarkToGroup("BFM ZONE", group, true)
	end
	local final_msg = table.concat(zone_info)
	return final_msg .. "\n"
end

local zones = get_coords(zones_data)

save_to_file("bfm_zones_data", zones)