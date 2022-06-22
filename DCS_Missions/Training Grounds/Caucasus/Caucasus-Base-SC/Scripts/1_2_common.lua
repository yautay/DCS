-- ###########################################################
-- ###                  COMMON OBJECTS                     ###
-- ###########################################################
borderRed = ZONE_POLYGON:New("Red Zone", GROUP:FindByName("ZONE-RED-BORDER"))
borderBlue = ZONE_POLYGON:New("Blue Zone", GROUP:FindByName("ZONE-BLUE-BORDER"))

zoneConflict1 = ZONE_POLYGON:New("Conflict 1", GROUP:FindByName("ZONE-CON-1"))
zoneConflict2 = ZONE_POLYGON:New("Conflict 2", GROUP:FindByName("ZONE-CON-2"))

zoneVaziani = ZONE:New("VAZIANI")

zoneWarbirds = ZONE_POLYGON:New("Warbirds Sector", GROUP:FindByName("ZONE-Piston"))