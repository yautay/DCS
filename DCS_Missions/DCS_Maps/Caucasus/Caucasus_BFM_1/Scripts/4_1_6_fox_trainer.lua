
navy_1 = ZONE_POLYGON:New("NAVY ONE", GROUP:FindByName("navy-1")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
navy_2 = ZONE_POLYGON:New("NAVY TWO", GROUP:FindByName("navy-2")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
navy_3 = ZONE_POLYGON:New("NAVY THREE", GROUP:FindByName("navy-3")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
zone_1 = ZONE_POLYGON:New("ZONE ONE", GROUP:FindByName("zone-1")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
zone_2 = ZONE_POLYGON:New("ZONE TWO", GROUP:FindByName("zone-2")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
zone_3 = ZONE_POLYGON:New("ZONE THREE", GROUP:FindByName("zone-3")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
zone_4 = ZONE_POLYGON:New("ZONE FOUR", GROUP:FindByName("zone-4")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
zone_5 = ZONE_POLYGON:New("ZONE FIVE", GROUP:FindByName("zone-5")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
zone_6 = ZONE_POLYGON:New("ZONE SIX", GROUP:FindByName("zone-6")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)
zone_7 = ZONE_POLYGON:New("ZONE SEVEN", GROUP:FindByName("zone-7")):DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
zone_8 = ZONE_POLYGON:New("ZONE EIGHT", GROUP:FindByName("zone-8")):DrawZone(-1,{0,0.75,1},1,{0,0.75,1},0.4,1,true)

fox_zones = {navy_1, navy_2, navy_3, zone_1, zone_2, zone_3, zone_4, zone_5, zone_6, zone_7, zone_8}

local zones_data = {
	{navy_2, "squid-1"},
	{navy_3, "check_1"},
	{zone_1, "devil_1"},
	{zone_2, "joker_1"},
	{zone_3, "check_1"},
	{zone_4, "ninja_1"},
	{zone_5, "viper_1"},
	{zone_6, "venom_1"},
	{zone_7, "jedi_1"},
	{zone_8, "sting_1"},
}

fox=FOX:New()

for i, v in pairs(fox_zones) do
	fox:AddSafeZone(v)
end

FOX:SetDisableF10Menu(true)
FOX:SetDefaultLaunchAlerts(false)
FOX:SetDefaultLaunchMarks(false)
FOX:SetDefaultMissileDestruction(true)

fox:Start()

function get_coords(data)
	local zone_info = {}
	local msg = string.format("BFM ZONES's in use: \n")
	table.insert(zone_info, msg)
	for i, v in pairs(data) do
		local zone = v[1]
		local group = v[2]
		local coordinate = zone:GetCoordinate(0):ToStringLLDMS()
		local tmp_msg = string.format("%s / %s -> %s\n", zone:GetName(), group, coordinate)
		table.insert(tmp_msg)
	end
	local final_msg = table.concat(zone_info)
	return final_msg .. "\n"
end

local zones = get_coords(zones_data)

save_to_file("bfm_zones_data", zones)