math.randomseed = os.clock() * 100000000000

-- ###########################################################
-- ###                   RED GROUPS                        ###
-- ###########################################################

-- ###########################################################
-- ###                   RED EWRS                          ###
-- ###########################################################

local function spawn_ewr(template)
    local data = {}
    for k, v in pairs(template) do
        local zone = ZONE:New(v[2])
        local ewr = SPAWN
            :NewWithAlias(v[1], string.format("red-ewr-%s", k))
            :InitRandomizeZones({zone}) 
            :Spawn()
        data[k] = ewr
    end
    return data
end

local function spawn_awacs(template)
    local data = {}
    for k, v in pairs(template) do
        local awacs = SPAWN
            :NewWithAlias(v[1], string.format("red-awacs-%s", k))
            :Spawn()
        data[k] = awacs
    end
    return data
end

local templates_ewr = {
    e1 = {"ME-EWR-55G6U", "RED-EWR-1"},
    e2 = {"ME-EWR-117", "RED-EWR-2"},
    e3 = {"ME-EWR-117", "RED-EWR-3"},
}
-- local templates_awacs = {
--     a1 = {"te-red-awacs-1"}
-- }

-- ###########################################################
-- ###                   RED SAMS                          ###
-- ###########################################################

-- lorad 1-3
-- merad 1-8
-- shorad 1-3
-- 
local function spawn_sam(template)
    local data = {}
    for k, v in pairs(template) do
        local zone = ZONE:New(v[2])
        local sam = SPAWN
            :NewWithAlias(v[1], string.format("red-sam-%s", k))
            :InitRandomizeZones({zone}) 
            :Spawn()
        data[k] = sam
    end
    return data
end

-- local templates_sam_1 = {
--     sa10b_3 = {"te-red-sa10b", "lorad-3"},
--     sa20b_2 = {"te-red-sa20b", "lorad-2"},
--     sa5_1 = {"te-red-sa5", "lorad-1"},
--     sa2_1 = {"te-red-sa2", "merad-1"},
--     sa2_2 = {"te-red-sa2", "merad-2"},
--     sa2_3 = {"te-red-sa2", "merad-3"},
--     sa11_8 = {"te-red-sa11", "merad-4"},
--     sa2_5 = {"te-red-sa2", "merad-5"},
--     sa2_6 = {"te-red-sa2", "merad-6"},
--     sa2_7 = {"te-red-sa2", "merad-7"},
--     sa2_8 = {"te-red-sa2", "merad-8"},
--     sa3_1 = {"te-red-sa3", "shorad-1"},
--     sa3_2 = {"te-red-sa3", "shorad-2"},
--     sa3_3 = {"te-red-sa3", "shorad-3"},
--     sa9 = {"te-red-sa9", "sirri-sa9"}
-- }

-- ###########################################################
-- ###                   RED SPAWNING                      ###
-- ###########################################################
local function get_detection_structure(groups)
    BASE:E(groups)
    local data = {}
    for k, v in pairs(groups) do
        local group_name = v:GetName()
        data[group_name] = {}
        local units = v:GetUnits()
        for i, v in pairs(units) do
            table.insert(data[group_name], v:GetName())
        end
    end
    return data
end

local function get_detection_groups(structure)
    local groups = {}
    for k, v in pairs(structure) do
        table.insert(groups, k)
    end
    return groups
end

local function get_detection_units(structure)
    local units = {}
    for k, v in pairs(structure) do
        local group = v
        for i, v in pairs(group) do
            table.insert(units, v)
        end
    end
    return units
end

ewrs = spawn_ewr(templates_ewr)
-- awacs = spawn_awacs(templates_awacs)
-- sams = spawn_sam(templates_sam_1)

local ewrs_structure = get_detection_structure(ewrs)
-- local awacs_structure = get_detection_structure(awacs)
-- local sam_structure = get_detection_structure(sams)

ewr_groups = get_detection_groups(ewrs_structure)
-- awacs_groups = get_detection_groups(awacs_structure)
-- sam_groups = get_detection_groups(sam_structure)

ewr_units = get_detection_units(ewrs_structure)
-- awacs_units = get_detection_units(awacs_structure)
-- sam_units = get_detection_units(sam_structure)

-- env.info("SAM FORCES\n")
-- BASE:E(sam_structure)

-- env.info("SAM GROUPS\n")
-- BASE:E(sam_groups)

env.info("DETECTION FORCES\n")
BASE:E(ewrs_structure)
-- BASE:E(awacs_structure)

env.info("DETECTION GROUPS\n")
BASE:E(ewr_groups)
-- BASE:E(awacs_groups)

env.info("DETECTION UNITS\n")
BASE:E(ewr_units)
-- BASE:E(awacs_units)