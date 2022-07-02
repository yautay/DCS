-- ###########################################################
-- ###            COMMON OBJECTS AND FUNCTIONS             ###
-- ###########################################################
borderRed = ZONE_POLYGON:New("Red Zone", GROUP:FindByName("ZONE-RED-BORDER"))
borderBlue = ZONE_POLYGON:New("Blue Zone", GROUP:FindByName("ZONE-BLUE-BORDER"))

zoneWarbirds = ZONE_POLYGON:New("Warbirds Sector", GROUP:FindByName("ZONE-Piston"))


function save_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"w")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end

function append_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"a")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end