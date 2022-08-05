
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

function random(x, y)
    if x ~= nil and y ~= nil then
		return math.floor(x +(math.random()*999999 %y))
    else
        return math.floor((math.random()*100))
    end
end

for i=1, random(100,1000) do
	random(1,3)
end

function sleep(n)  -- seconds
   local t0 = os.clock()
   while ((os.clock() - t0) <= n) do
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