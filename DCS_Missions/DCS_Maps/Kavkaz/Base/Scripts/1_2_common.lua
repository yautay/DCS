function save_to_file(filename, content)
    local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
    local f, err = io.open(fdir, "w")
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
    local f, err = io.open(fdir, "a")
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
        return math.floor(x + (math.random() * 999999 % y))
    else
        return math.floor((math.random() * 100))
    end
end

for i = 1, random(100, 1000) do
    random(1, 3)
end

function sleep(n)
    -- seconds
    local t0 = os.clock()
    while ((os.clock() - t0) <= n) do
    end
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function calculateCoordinateFromRoute(startCoordObject, course, distance)
    return startCoordObject:Translate(UTILS.NMToMeters(distance), course, false, false)
end

function tableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

function msgToAll(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

function debugObject(o)
    for key, value in pairs(o) do
        print("found member " .. key);
    end
end