function getUnits()
	BASE:E(DATABASE.UNITS)
end
function getGroups()
	BASE:E(DATABASE.GROUPS)
end

MenuDebug = MENU_MISSION:New("DEBUG", MenuSeler)
local UnitsInfo = MENU_MISSION_COMMAND:New("DB Units", MenuDebug, getUnits, {})
local GroupsInfo = MENU_MISSION_COMMAND:New("DB Groups", MenuDebug, getGroups, {})

