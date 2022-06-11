local function start_fox()
	MESSAGE:New("TOP GUN START"):ToAll()
	zonePvP:DrawZone(2, {0,.7,0}, 1, {0,.7,0}, 0.2, 0, true)
	StartFox:Remove()
	StopFox = MENU_MISSION_COMMAND:New("Stop PvP Training", MenuFox, stop_fox)
	fox:Start()
end

local function stop_fox()
	MESSAGE:New("TOP GUN STOP"):ToAll()
	zonePvP:UndrawZone(Delay)
	StopFox:Remove()
	StartFox = MENU_MISSION_COMMAND:New("Start PvP Training", MenuFox, start_fox)
	fox:Stop()
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

