-- ###########################################################
-- ###                  COMMON OBJECTS                     ###
-- ###########################################################

zoneWarbirds = ZONE_POLYGON:New("Warbirds Sector", GROUP:FindByName("ZONE-Piston")):DrawZone(2, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.6, 0, true)
zoneSyria = ZONE_POLYGON:New("Syria Zone", GROUP:FindByName("Syria Border"))