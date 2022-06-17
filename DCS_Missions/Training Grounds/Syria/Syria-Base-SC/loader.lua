server = false

-- AIRWINGS
-- Larnaca
aw_larnaca = false
aw_larnaca_cap = false
aw_larnaca_escort = false
debug_aw_larnaca = false

-- Ramat David
aw_ramat = false
aw_ramat_cap = false
aw_ramat_escort = false
debug_aw_ramat = false

-- CVN
aw_cvn = true
aw_cvn_cap = true
aw_cvn_escort = true
debug_aw_cvn = true

-- FEATURES
awacs_moose = true
fox_trainer = true
ag_range = true
rat = false
csar = true
elint = true
atis = true
airboss = true


iads_blue = false
iads_red = false

dispatcher_blue = false
dispatcher_red = false

debug_blueiads = false
debug_rediads = false

debug_bluedispatcher = false
debug_reddispatcher = false

debug_awacs = true
debug_airbos = false
debug_elint = false
debug_csar = false

menu_dump_to_file = true
menu_show_freqs = true
menu_show_presets = true

if (server) then
	scripts_path = "C:\\Users\\yauta\\Saved Games\\DCS.openbeta_server\\Missions\\DCS_Missions\\Training Grounds\\Syria\\Syria-Base-SC\\Scripts\\"
else
	scripts_path = "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\Training Grounds\\Syria\\Syria-Base-SC\\Scripts\\"
end

loadScriptVariables(scripts_path)
loadScriptCommonData(scripts_path)

timer.scheduleFunction(loadScriptRadioPresets, scripts_path, timer.getTime() + 1)
timer.scheduleFunction(loadScriptMenu, scripts_path, timer.getTime() + 2)

if (aw_larnaca) then
	timer.scheduleFunction(loadLarnacaAW, scripts_path, timer.getTime() + 5)
end

if (aw_ramat) then
	timer.scheduleFunction(loadRamatAW, scripts_path, timer.getTime() + 5)
end

if (aw_cvn) then
	timer.scheduleFunction(loadCvnAW, scripts_path, timer.getTime() + 5)
end

if (airboss) then
	timer.scheduleFunction(loadAirboss, scripts_path, timer.getTime() + 3)
end

if (csar) then
	timer.scheduleFunction(loadCSAR, scripts_path, timer.getTime() + 6)
end

if (fox_trainer) then
	timer.scheduleFunction(loadFOX, scripts_path, timer.getTime() + 6)
end

if (ag_range) then
	timer.scheduleFunction(loadCyprusAGRange, scripts_path, timer.getTime() + 6)
end