math.randomseed = os.clock() * 100000000000

-- ###########################################################
-- ###                   RED GROUPS                        ###
-- ###########################################################
function spawn_siri_base()
    siri_aaa_60 = SPAWN:New("siri-aaa"):Spawn()
    siri_aaa_23 = SPAWN:New("siri-aaa-1"):Spawn()
    siri_planes = SPAWN:New("siri-planes"):Spawn()
    siri_helo = SPAWN:New("siri-helo"):Spawn()
    siri_scuds = SPAWN:New("siri-scuds"):Spawn()
    siri_silkworm = SPAWN:New("siri-silkworm"):Spawn()
    siri_sa9 = SPAWN:NewWithAlias("te-red-sa9", "red-sam-sa9"):InitRandomizeZones({ZONE:New("sirri-sa9")}):Spawn()
end

-- ###########################################################
-- ###                   RED EWRS                          ###
-- ###########################################################
function spawn_ewr(template)
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

function spawn_awacs(template)
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
    e1 = {"te-red-ewr-wd", "ewr-1"},
    e2 = {"te-red-ewr-nd", "ewr-2"},
    e3 = {"te-red-ewr-wd", "ewr-3"},
    e4 = {"te-red-ewr-nd", "ewr-4"}
}
local templates_awacs = {
    a1 = {"te-red-awacs-1"}
}

-- ###########################################################
-- ###                   RED SAMS                          ###
-- ###########################################################
function spawn_sam(template)
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

-- randomize sam positions
local s300_random = math.random(1, 8)
local s200_random = math.random(1, 7)
local s125_random = math.random(1, 10)
local s75_random = math.random(1, 10)

local s300zone = string.format("s300-%d", s300_random)
local s200zone = string.format("s200-%d", s200_random)
local s125zone = string.format("s125-%d", s125_random)
local s75zone = string.format("s75-%d", s75_random)

local s300_type_random = math.random(1, 100)

local templates_sam = {
    sa2 = {"te-red-sa2", s75zone},
    sa3 = {"te-red-sa3", s125zone},
    sa5 = {"te-red-sa5", s200zone},
    sa9 = {"te-red-sa9", "sirri-sa9"}
}

-- randomise s300 type
if (s300_type_random >= 75) then
    templates_sam["sa20b"] = {"te-red-sa20b", s300zone}
else
    templates_sam["sa11"] = {"te-red-sa11", s300zone}
end

env.info(string.format("SAMS SEED RANDOMIZED %s %s %s %s",s75zone, s125zone, s200zone, s300zone))

-- ###########################################################
-- ###                   RED SPAWNING                      ###
-- ###########################################################
function get_detection_structure(groups)
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

function get_detection_groups(structure)
    local groups = {}
    for k, v in pairs(structure) do
        table.insert(groups, k)
    end
    return groups
end

function get_detection_units(structure)
    local units = {}
    for k, v in pairs(structure) do
        local group = v
        for i, v in pairs(group) do
            table.insert(units, v)
        end
    end
    return units
end
 
spawn_siri_base()

ewrs = spawn_ewr(templates_ewr)
awacs = spawn_awacs(templates_awacs)
sams = spawn_sam(templates_sam)

local ewrs_structure = get_detection_structure(ewrs)
local awacs_structure = get_detection_structure(awacs)
local sam_structure = get_detection_structure(sams)

ewr_groups = get_detection_groups(ewrs_structure)
awacs_groups = get_detection_groups(awacs_structure)
sam_groups = get_detection_groups(sam_structure)

ewr_units = get_detection_units(ewrs_structure)
awacs_units = get_detection_units(awacs_structure)
sam_units = get_detection_units(sam_structure)

env.info("SAM FORCES\n")
BASE:E(sam_structure)

env.info("SAM GROUPS\n")
BASE:E(sam_groups)

env.info("DETECTION FORCES\n")
BASE:E(ewrs_structure)
BASE:E(awacs_structure)

env.info("DETECTION GROUPS\n")
BASE:E(ewr_groups)
BASE:E(awacs_groups)

env.info("DETECTION UNITS\n")
BASE:E(ewr_units)
BASE:E(awacs_units)