-- ###########################################################
-- ###                      AG GROUND                      ###
-- ###########################################################

zoneAG_trgt = ZONE:New("AG-RANGE")

if (menu_dump_to_file) then
    local targets_hard = {
        "Static Ammunition depot-1-1",
        "Static Ammunition depot-2-1",
        "Static Ammunition depot-3-1",
        "Static Ammunition depot-4-1",
    }
    local targets_medium = {
        "Static Warehouse-1-1",
        "Static Warehouse-2-1",
        "Static Warehouse-3-1",
        "Static Warehouse-4-1",
        "Static Workshop A-1",
    }
    local targets_soft = {
        "Static Tank 1-1-1",
        "Static Tank 1-2-1",
        "Static Tank 1-3-1",
        "Static Tank 1-4-1",
        "Static Tank 1-5-1",
        "Static Tank 1-6-1",
        "Static Tank 2-1-1",
        "Static Tank 2-2-1",
        "Static Tank 2-3-1",
        "Static Tank 2-4-1",
        "Static Tank 2-5-1",
        "Static Tank 2-6-1",
        "Static Tank 2-7-1",
    }

    local function coord_to_LLDMS_H(coord)
        return {coord:ToStringLLDMS(nil), UTILS.MetersToFeet(coord:GetLandHeight())}
    end

    local function targets_to_JDAM_text(targets_coords, prefix)
        local tmp_table = {}
        local msg = string.format("%s Targets Coordinates: \n", prefix)
        table.insert(tmp_table, msg)
        for i, v in ipairs(targets_coords) do
            local human_coords = coord_to_LLDMS_H(v)
            local tmp_string = string.format("DMS %s\n        h= %d fts \n",human_coords[1], human_coords[2])
            table.insert(tmp_table, tmp_string)
        end
        local final_msg = table.concat(tmp_table)
        return final_msg .. "\n"
    end

    function get_statics_coords(statics_table)
        local table_coords = {}
        for i, v in pairs(statics_table) do
            local static_target = STATIC:FindByName(v, false)
            local coords = static_target:GetCoordinate()
            table.insert(table_coords, coords)
        end
        return table_coords
    end

    local hard_statics = targets_to_JDAM_text(get_statics_coords(targets_hard), "Hard Targets")
    local medium_statics = targets_to_JDAM_text(get_statics_coords(targets_medium), "Medium Targets")
    local soft_statics = targets_to_JDAM_text(get_statics_coords(targets_soft), "Soft Targets")
    local concat_targets = hard_statics .. medium_statics .. soft_statics
    save_to_file("ag_statics", concat_targets)
end

function spawn_drone()
    agDrone = SPAWN:New("AG-DRONE"):OnSpawnGroup(
        function(drone)
            agDrone:CommandSetCallsign(CALLSIGN.Aircraft.Uzi, 1, 1)
            agDrone:CommandSetFrequency(FREQUENCIES.FLIGHTS.ag_drone[1])
            local beacon = agDrone:GetBeacon()
            beacon:ActivateTACAN(TACAN.ag[1], TACAN.ag[2], TACAN.ag[3], false)
        end)
    :Spawn()
end

function spawn_train_sector()
    zoneAG_trgt:DrawZone(-1,{0.5,0.25,0},1,{0.5,0.25,0},0.4,1,true)
    target_moving = SPAWN:New("Moving-Target-1"):Spawn()
    spawn_drone()
    MESSAGE:New("AG Range Spawned"):ToBlue()
    StartAGGround:Remove()
    StopAGGround:Refresh()
end

function kill_train_sector()
    zoneAG_trgt:UndrawZone(1)
    target_moving:Destroy()
    agDrone:Destroy()
    MESSAGE:New("AG Range Removed"):ToBlue()
    StartAGGround:Refresh()
    StopAGGround:Remove()
end

StartAGGround = MENU_MISSION_COMMAND:New("Start Ground Range", MenuFeatures, spawn_train_sector)
StopAGGround = MENU_MISSION_COMMAND:New("Stop Ground Range", MenuFeatures, kill_train_sector)
StopAGGround:Remove()