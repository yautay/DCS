-- ZONES -----------------------------------------------------
local ZONE_TG_AG =
    ZONE_POLYGON:New("ZONE TG AG", GROUP:FindByName("ZONE AG")):DrawZone(
    -1,
    {.5, 0, 1},
    1.0,
    {.5, 0, 1},
    0.4,
    2
)

local TARGET_TANKS = SPAWN:New("TARGET-AG-TANKS"):InitLimit(10, 0):SpawnScheduled(UTILS.ClockToSeconds("00:30:00"), .25)

local TARGET_HARD_1 = STATIC:FindByName("AG TARGET HARD-1")
local TARGET_HARD_2 = STATIC:FindByName("AG TARGET HARD-2")
local TARGET_HARD_3 = STATIC:FindByName("AG TARGET HARD-3")
local TARGET_HARD_4 = STATIC:FindByName("AG TARGET HARD-4")
local TARGET_HARD_5 = STATIC:FindByName("AG TARGET HARD-5")
local TARGET_HARD_6 = STATIC:FindByName("AG TARGET HARD-6")
local TARGET_HARD_7 = STATIC:FindByName("AG TARGET HARD-7")
local TARGET_HARD_8 = STATIC:FindByName("AG TARGET HARD-8")

local TG_1_POS = {TARGET_HARD_1:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_1:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_1:GetCoordinate():GetLandHeight()}
local TG_2_POS = {TARGET_HARD_2:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_2:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_2:GetCoordinate():GetLandHeight()}
local TG_3_POS = {TARGET_HARD_3:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_3:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_3:GetCoordinate():GetLandHeight()}
local TG_4_POS = {TARGET_HARD_4:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_4:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_4:GetCoordinate():GetLandHeight()}
local TG_5_POS = {TARGET_HARD_5:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_5:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_5:GetCoordinate():GetLandHeight()}
local TG_6_POS = {TARGET_HARD_6:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_6:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_6:GetCoordinate():GetLandHeight()}
local TG_7_POS = {TARGET_HARD_7:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_7:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_7:GetCoordinate():GetLandHeight()}
local TG_8_POS = {TARGET_HARD_8:GetCoordinate():ToStringLLDMS(nil), TARGET_HARD_8:GetCoordinate():ToStringLLDDM(nil), TARGET_HARD_8:GetCoordinate():GetLandHeight()}

local targets = {TG_1_POS, 
TG_2_POS,
TG_3_POS,
TG_4_POS,
TG_5_POS,
TG_6_POS,
TG_7_POS,
TG_8_POS,}



local function Msg(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

local function hard_targets_text(targets)
    local tmp_table = {}
    local msg = string.format("Hard Targets Coordinates: \n")
    table.insert(tmp_table, msg)
    for i, v in ipairs(targets) do
        local tmp_string = string.format("T%d -> DMS %s\n       DDM %s\n       h= %d mtrs \n",i , v[1], v[2], v[3])
        table.insert(tmp_table, tmp_string)
    end
    local final_msg = table.concat(tmp_table)
    return final_msg .. "\n"
end

local hard_tgts_info = hard_targets_text(targets)

env.info(hard_tgts_info)

MenuAGGround = MENU_MISSION:New("AG Ground Menu") --Główny kontener
local HardTargets = MENU_MISSION_COMMAND:New("Hard Targets", MenuAGGround, Msg, {hard_tgts_info, 30})