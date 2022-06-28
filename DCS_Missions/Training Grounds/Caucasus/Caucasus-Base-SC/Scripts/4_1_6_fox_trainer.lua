zonePvP_trgt = ZONE:New("PVP-RANGE")

function spawn_cc()
    pvpcc = SPAWN:New("PvP TACAN"):OnSpawnGroup(
        function(cc)
            beaconPvP = cc:GetBeacon()
            beaconPvP:ActivateTACAN(TACAN.pvp[1], TACAN.pvp[2], TACAN.pvp[3], true)
        end)
    :Spawn()
end

local function start_fox()
	zonePvP_trgt:DrawZone(-1,{0,0.5,1},1,{0,0.5,1},0.4,1,true)
	spawn_cc()
	fox:Start()
	MESSAGE:New("PvP ZONE START"):ToBlue()
	StartFox:Remove()
	StopFox:Refresh()
end

local function stop_fox()
	zonePvP_trgt:UndrawZone(1)
	beaconPvP:StopRadioBeacon()
	fox:Stop()
	pvpcc:Destroy()
	MESSAGE:New("PvP ZONE STOP"):ToBlue()
	StopFox:Remove()
	StartFox:Refresh()
end

fox=FOX:New()

fox:AddSafeZone(zonePvP_trgt)
fox:AddLaunchZone(zonePvP_trgt)

FOX:SetDefaultLaunchAlerts(false)
FOX:SetDefaultLaunchMarks(false)

StartFox = MENU_MISSION_COMMAND:New("Start PvP Training", MenuFeatures, start_fox)
StopFox = MENU_MISSION_COMMAND:New("Stop PvP Training", MenuFeatures, stop_fox)
StopFox:Remove()