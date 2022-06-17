SERVER = false

SERVER_PATH = "C:\\Users\\yauta\\Saved Games\\DCS.openbeta_server\\Missions\\DCS_Missions\\Training Grounds\\Caucasus\\Caucasus-Base-SC\\Scripts\\"
LOCAL_PATH = "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\Training Grounds\\Caucasus\\Caucasus-Base-SC\\Scripts\\"

if (server) then
	scripts_path = SERVER_PATH
else
	scripts_path = LOCAL_PATH
end


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

function loadElint(scripts_path)
	dofile(scripts_path .. "4_1_3_elint.lua")
end

function loadCSAR(scripts_path)
	dofile(scripts_path .. "4_1_5_csar.lua")
end

function loadFOX(scripts_path)
	dofile(scripts_path .. "4_1_6_fox_trainer.lua")
end

function loadAtis(scripts_path)
	dofile(scripts_path .. "3_2_atis.lua")
end

function loadVazianiAW(scripts_path)
	dofile(scripts_path .. "AW_Vaziani.lua")
end

function loadKutaisiAW(scripts_path)
	dofile(scripts_path .. "AW_Kutaisi.lua")
end

function loadScheduler(scripts_path)
	dofile(scripts_path .. "5_1_1_schedulers.lua")
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

function append_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"a")
	if not f then
		local errmsg = "Error: IO" 
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end

