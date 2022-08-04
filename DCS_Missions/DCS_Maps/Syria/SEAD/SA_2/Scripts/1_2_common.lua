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

u = 0 -- don't delete
function random(x, y)
    u = u + 1
    if x ~= nil and y ~= nil then
        return math.floor(x +(math.random(math.randomseed(os.time()+u))*999999 %y))
    else
        return math.floor((math.random(math.randomseed(os.time()+u))*100))
    end
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