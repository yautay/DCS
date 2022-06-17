zoneAG_trgt = ZONE_POLYGON:New("AtG Sector", GROUP:FindByName("AG-TRG")):DrawZone(2, {.5, 0, 1}, 1, {.5, 0, 1}, 0.6, 0, true)

local function get_group_units_type_and_coords(group)
    local units = group:GetUnits()
    local coords = {}
    for key, value in pairs(units) do
        env.info(value:GetName())
        local type = value:GetTypeName()
        local coordinates = value:GetCoordinate()
        table.insert(coords, {type, coordinates})
    end
    return coords
end

local function coord_to_LLDMS_H(coord)
    return {coord:ToStringLLDMS(nil), coord:GetLandHeight()}
end

local function targets_to_JDAM_text(targets)
    local tmp_table = {}
    local msg = string.format("Targets Coordinates: \n")
    table.insert(tmp_table, msg)
    for i, v in ipairs(targets) do
        local tmp_string = string.format("T%s-> DMS %s\n        h= %d mtrs \n",v[1] , v[2], v[3])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

function spawn_train_sector()
    local target_urban = SPAWN:New("TGT-STORES"):Spawn()
    local target_circles = SPAWN:New("TGT-CIRCLE"):Spawn()
    local target_sam = SPAWN:New("TGT-SAM"):Spawn()
    local target_tanks = SPAWN:New("TGT-TANKS"):Spawn()

    local targets = {}
    for i, v in pairs(target_circles, target_urban, target_tanks, target_sam) do
        local units_types_and_coordinates = get_group_units_coords(v)
        for i, v in pairs(units_types_and_coordinates) do
            local unit_data = {}
            local unit_type = v[1]
            local unit_coordinate_JDAM_friendly = coord_to_LLDMS_H(v[2])
            for i, v in pairs(unit_coordinate_JDAM_friendly) do 
                local pos = v[1]
                local hgt = v[2]
                table.insert(unit_data, {unit_type, pos, hgt})
            end
            table.insert(targets, unit_data)
        end
    end
    local message = targets_to_JDAM_text(targets)
    if (menu_dump_to_file) then
        save_to_file("training ground coordinates", message)
    end
    MESSAGE:New("Grount Training Range spawned on Cyprus"):ToAll()
    StartAGGround:Remove()
    DisplayAGTRData = MENU_MISSION_COMMAND:New("Targets data", MenuAGGround, Msg, {message, 30})
end

MenuAGGround = MENU_MISSION:New("AG Ground Menu", MenuSeler) --Główny kontener
StartAGGround = MENU_MISSION_COMMAND:New("Start Ground Range", MenuAGGround, spawn_train_sector)

"Static Ammunition depot-1-1"
"Static Ammunition depot-2-1"
"Static Ammunition depot-3-1"
"Static Ammunition depot-4-1"
"Static Tank 1-1-1"
"Static Tank 1-2-1"
"Static Tank 1-3-1"
"Static Tank 1-4-1"
"Static Tank 1-5-1"
"Static Tank 1-6-1"
"Static Tank 2-1-1"
"Static Tank 2-2-1"
"Static Tank 2-3-1"
"Static Tank 2-4-1"
"Static Tank 2-5-1"
"Static Tank 2-6-1"
"Static Tank 2-7-1"
"Static Warehouse-1-1"
"Static Warehouse-2-1"
"Static Warehouse-3-1"
"Static Warehouse-4-1"
"Static Workshop A-1"