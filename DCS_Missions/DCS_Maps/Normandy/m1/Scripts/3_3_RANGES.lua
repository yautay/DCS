RangeAG = RANGE:New("Range AG")
ZoneRangeAG = ZONE:New("RANGE AG"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
RangeAG:SetRangeZone(ZoneRangeAG)

BombTargets = { "BMB_GP_UNT" }
-- StrafeTargets = { "Range AG Strafe" }

RangeAG:AddBombingTargets(BombTargets, 25, false)

-- local boxlength = UTILS.NMToMeters(3)
-- local boxwidth = UTILS.NMToMeters(1)
-- local heading = 150
-- local foulline = 150

--Base:AddStrafePit(targetnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)
-- RangeAG:AddStrafePit(StrafeTargets, boxlength, boxwidth, heading, false, 10, foulline)

-- Start range.
RangeAG:SetDefaultPlayerSmokeBomb(false)
RangeAG:SetTargetSheet(SHEET_PATH, "Range-")
RangeAG:SetAutosaveOn()
RangeAG:SetMessageTimeDuration(5)
RangeAG:Start()
RangeAG:SetFunkManOn(10042, "127.0.0.1")

-- function targets_coordinates(list_targets_names)
--     local tgts_tbl = {}
--     for index, value in ipairs(list_targets_names) do
--         local unit = STATIC:FindByName(value)
--         local unit_type = unit:GetTypeName()
--         local coords = unit:GetCoordinate()
--         local mgrs = coords:ToStringMGRS()
--         local lldm = coords:ToStringLLDDM()
--         table.insert(tgts_tbl, lldm .. "   " .. mgrs .. "\n")
--     end
--     return tgts_tbl
-- end
--
-- function range_report(range_object, table_bomb_targets, table_strafe_targets)
--     local name = range_object.rangename
--     local bomb_tgts = targets_coordinates(table_bomb_targets)
--     local strafe_tgts = targets_coordinates(table_strafe_targets)
--
--     local range_report = {}
--     table.insert(range_report, os.date('%Y-%m-%d/%H%ML') .. "\n")
--     table.insert(range_report, name .. "\n")
--     table.insert(range_report, "BOMB TARGETS\n")
--     for index, value in ipairs(bomb_tgts) do
--         table.insert(range_report, value)
--     end
--     table.insert(range_report, "STRAFE TARGETS\n")
--     for index, value in ipairs(strafe_tgts) do
--         table.insert(range_report, value)
--     end
--     saveToFile(SHEET_PATH .. "\\NOTAM-RANGE-" .. string.upper(name), table.concat(range_report))
-- end
--
-- range_report(RangeAG, BombTargets, StrafeTargets)
TanksSet = SET_GROUP:New():FilterPrefixes("TANK"):FilterStart()
UbootSet = SET_GROUP:New():FilterPrefixes("UBOOT"):FilterStart()
LocoSet = SET_GROUP:New():FilterPrefixes("LOCO"):FilterStart()
BunkersSet = SET_GROUP:New():FilterPrefixes("BUNKERS"):FilterStart()
RonaiZone = ZONE:New("SCR1")

Tigers = SPAWN
    :NewWithAlias( "TANKS", "TANKS" )
    :InitLimit( 6, 99 )
    :InitRandomizePosition( true, 50, 20 )
    :SpawnScheduled( 60, .1 )

Uboot = SPAWN
    :NewWithAlias( "UBOOT", "UBOOT" )
    :InitLimit( 1, 99 )
    :InitRandomizePosition( true, 300, 50 )
    :SpawnScheduled( 60, .1 )

Scoring = SCORING
    :New("Scoring")
    :SetScaleDestroyScore(2)
    :AddZoneScore( RonaiZone, 10 )

--     :AddScoreSetGroup( TanksSet, 100)
--     :AddScoreSetGroup( UbootSet, 500)
--     :AddScoreSetGroup( LocoSet, 50)
--     :AddScoreSetGroup( BunkersSet, 200)