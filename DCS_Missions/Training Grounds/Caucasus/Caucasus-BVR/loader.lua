-- if (SERVER) then
-- 	scripts_path = SERVER_PATH
-- else
-- 	scripts_path = LOCAL_PATH
-- end

loadScriptVariables(scripts_path)
loadScriptCommonData(scripts_path)

timer.scheduleFunction(loadScriptRadioPresets, scripts_path, timer.getTime() + 1)
timer.scheduleFunction(loadScriptMenu, scripts_path, timer.getTime() + 2)
timer.scheduleFunction(loadScheduler, scripts_path, timer.getTime() + 10)

if (atis) then
	timer.scheduleFunction(loadAtis, scripts_path, timer.getTime() + 3)
end

if (airboss) then
	timer.scheduleFunction(loadAirboss, scripts_path, timer.getTime() + 3)
end

if (elint) then
	timer.scheduleFunction(loadElint, scripts_path, timer.getTime() + 3)
end

if (aw_vaziani) then
	timer.scheduleFunction(loadVazianiAW, scripts_path, timer.getTime() + 5)
end

if (aw_kutaisi) then
	timer.scheduleFunction(loadKutaisiAW, scripts_path, timer.getTime() + 5)
end

if (aw_mozdok) then
	timer.scheduleFunction(loadMozdokAW, scripts_path, timer.getTime() + 5)
end

if (csar) then
	timer.scheduleFunction(loadCSAR, scripts_path, timer.getTime() + 6)
end

if (fox_trainer) then
	timer.scheduleFunction(loadFOX, scripts_path, timer.getTime() + 6)
end

if (aw_mozdok) then
	timer.scheduleFunction(loadRedChief, scripts_path, timer.getTime() + 10)
end

if (ag_range) then
	timer.scheduleFunction(loadCyprusAGRange, scripts_path, timer.getTime() + 6)
end
