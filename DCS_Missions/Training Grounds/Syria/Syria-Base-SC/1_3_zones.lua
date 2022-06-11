zoneWarbirds = ZONE_POLYGON:New("Warbirds Sector", GROUP:FindByName("ZONE-Piston")):DrawZone(2, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.6, 0, true)
zonePvP = ZONE_POLYGON:New("PvP Sector", GROUP:FindByName("ZONE-PvP"))
zoneCAP_cv = ZONE_POLYGON:New("ZONE-CV-CAP", GROUP:FindByName("ZONE-CV-CAP"))
zoneAG_trgt = ZONE_POLYGON:New("AtG Sector", GROUP:FindByName("AG-TRG")):DrawZone(2, {.5, 0, 1}, 1, {.5, 0, 1}, 0.6, 0, true)

zoneRedEwr1 = ZONE:New("RED-EWR-1")
zoneRedEwr2 = ZONE:New("RED-EWR-2")
zoneRedEwr3 = ZONE:New("RED-EWR-3")
