
local function freq_text(general_freqs)
    local tmp_table = {}
    local msg = string.format("General freq in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_freqs) do
        local tmp_string = "empty"
        if (type(v[1]) == "string") then
            tmp_string = string.format("%s -> %s \n", v[1], v[2])
        else    
            tmp_string = string.format("%.2f -> %s %s \n", v[1], v[2], v[3])
        end
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function tacans_text(general_tacans)
    local tmp_table = {}
    local msg = string.format("TACANs in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_tacans) do
        local tmp_string = string.format("Ch %d %s Code: %s -> %s \n", v[1], v[2], v[3], v[4])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function yardsticks_text(general_yardsticks)
    local tmp_table = {}
    local msg = string.format("YARDSTICK's in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_yardsticks) do
        local tmp_string = string.format("%s -> Leader: %d <-> Wingman: %d (%s) \n", v[1], v[2], v[3], v[4])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function icls_text(general_icls)
    local tmp_table = {}
    local msg = string.format("ICLS/ILS in use: \n")
    table.insert(tmp_table, msg)
    for i, v in pairs(general_icls) do
        local tmp_string = string.format("Ch %s Code: %s -> %s \n", v[1], v[2], v[3])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

MenuSeler = MENU_MISSION:New("Seler Menu")
MenuFeatures = MENU_MISSION:New("Features", MenuSeler)
