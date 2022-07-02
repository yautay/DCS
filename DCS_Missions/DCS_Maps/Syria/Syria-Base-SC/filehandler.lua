function loadScriptVariables(scripts_path)
	dofile(scripts_path .. "1_1_variables.lua")
end

function loadScriptCommonData(scripts_path)
	dofile(scripts_path .. "1_2_common.lua")
end

function loadScriptRadioPresets(scripts_path)
	dofile(scripts_path .. "2_1_radio_presets.lua")
end

function loadScriptMenu(scripts_path)
	dofile(scripts_path .. "3_1_menu.lua")
end

function loadAirboss(scripts_path)
	dofile(scripts_path .. "4_1_4_airbos.lua")
end

function loadCSAR(scripts_path)
	dofile(scripts_path .. "4_1_5_csar.lua")
end

function loadFOX(scripts_path)
	dofile(scripts_path .. "4_1_6_fox_trainer.lua")
end

function loadCyprusAGRange(scripts_path)
	dofile(scripts_path .. "4_1_7_training_ground_ag.lua")
end

function loadLarnacaAW(scripts_path)
	dofile(scripts_path .. "AW_Larnaca.lua")
end

function loadRamatAW(scripts_path)
	dofile(scripts_path .. "AW_RamatDavid.lua")
end

function loadCvnAW(scripts_path)
	dofile(scripts_path .. "AW_Cvn.lua")
end

function save_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"w")
	if not f then
		local errmsg = "Error: IO" 
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end
