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


function data_extractor_static_object(static_object)
    local name = static_object:GetName()
    local coordinate = static_object:GetCoordinate()
    local lldms = coordinate:ToStringLLDMS()
    local llddm = coordinate:ToStringLLDMS()
    local mgrs = coordinate:ToStringMGRS()
    local height = coordinate:GetLandHeight()
    local msg = string.format("Target: %s\n   LLDMS -> %s\n   LLDDM -> %s\n   MGRS -> %s\n   HEIGHT[Ft] -> %d\n", name, lldms, llddm, mgrs, height)
    env.info(msg)
	return msg
end