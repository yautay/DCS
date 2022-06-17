zonePvP = ZONE_POLYGON:New("PvP Sector", GROUP:FindByName("ZONE-PvP"))

tacanPvP = STATIC:FindByName("PvP TACAN", false)
beaconPvP = BEACON:New(zonePvP)

local function start_fox()
	MESSAGE:New("PvP ZONE START"):ToAll()
	zonePvP:DrawZone(2, {0,.7,0}, 1, {0,.7,0}, 0.2, 0, true)
	StartFox:Remove()
	StopFox = MENU_MISSION_COMMAND:New("Stop PvP Training", MenuFox, stop_fox)
	fox:Start()
	beaconPvP:ActivateTACAN(TACAN.pvp[1], TACAN.pvp[2], TACAN.pvp[3], true)
end

local function stop_fox()
	MESSAGE:New("PvP ZONE STOP"):ToAll()
	zonePvP:UndrawZone(Delay)
	StopFox:Remove()
	StartFox = MENU_MISSION_COMMAND:New("Start PvP Training", MenuFox, start_fox)
	fox:Stop()
	beaconPvP:StopRadioBeacon()
end

if (fox_trainer) then
	

	-- Create a new missile trainer object.
	fox=FOX:New()

	-- Add training zones.
	fox:AddSafeZone(zone_PvP)
	fox:AddLaunchZone(zone_PvP)

	FOX:SetDefaultLaunchAlerts(false)
	FOX:SetDefaultLaunchMarks(false)

    MenuFox = MENU_MISSION:New("Features", MenuSeler)
	StartFox = MENU_MISSION_COMMAND:New("Start PvP Training", MenuFox, start_fox)
	StopFox = MENU_MISSION_COMMAND:New("Stop PvP Training", MenuFox, stop_fox)
end

