SERVER = false

SERVER_PATH = "C:\\Users\\yauta\\Saved Games\\DCS.openbeta_server\\Missions\\DCS_Missions\\Training Grounds\\South Atlantic\\South-Atlantic-Base\\Scripts\\"
LOCAL_PATH = "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\Training Grounds\\South Atlantic\\South-Atlantic-Base\\Scripts\\"

SRS_PATH = nil
SRS_PORT = nil

SRS_SERVER_PATH = "C:\\DCS-SimpleRadio-Standalone"
SRS_SERVER_PORT = 5002
SRS_LOCAL_PATH = "E:\\Software\\DCS-SimpleRadio-Standalone"
SRS_LOCAL_PORT = 5002

if (SERVER) then
	scripts_path = SERVER_PATH
	SRS_PATH = SRS_SERVER_PATH
	SRS_PORT = SRS_SERVER_PORT
else
	scripts_path = LOCAL_PATH
	SRS_PATH = SRS_LOCAL_PATH
	SRS_PORT = SRS_LOCAL_PORT
end
env.info("PATH SETUP START")
env.info(string.format("SERVER->%s", tostring(SERVER)))
env.info(string.format("SCRIPTS PATH->%s", scripts_path))
env.info(string.format("SRS PATH->%s", SRS_PATH))
env.info(string.format("SRS PORT->%s", SRS_PORT))
env.info("PATH SETUP COMPLETED")

function loadLibSTTS(scripts_path)
	env.info("loading -> DCS-SimpleTextToSpeech.lua")
	dofile(scripts_path .. "DCS-SimpleTextToSpeech.lua")
end

function loadLibHound(scripts_path)
	env.info("loading -> HoundElint.lua")
	dofile(scripts_path .. "HoundElint.lua")
end

function LoadLibSkynet(scripts_path)
	env.info("loading -> skynet-iads-compiled.lua")
	dofile(scripts_path .. "skynet-iads-compiled.lua")
end

function loadScriptVariables(scripts_path)
	env.info("loading -> 1_1_variables.lua")
	dofile(scripts_path .. "1_1_variables.lua")
end

function loadScriptCommonData(scripts_path)
	env.info("loading -> 1_2_common.lua")
	dofile(scripts_path .. "1_2_common.lua")
end

function loadScriptRadioPresets(scripts_path)
	env.info("loading -> 2_1_radio_presets.lua")
	dofile(scripts_path .. "2_1_radio_presets.lua")
end

function loadScriptMenu(scripts_path)
	env.info("loading -> 3_1_menu.lua")
	dofile(scripts_path .. "3_1_menu.lua")
end

function loadAirboss(scripts_path)
	env.info("loading -> 4_1_4_airbos.lua")
	dofile(scripts_path .. "4_1_4_airbos.lua")
end

function loadElint(scripts_path)
	env.info("loading -> 4_1_3_elint.lua")
	dofile(scripts_path .. "4_1_3_elint.lua")
end

function loadCSAR(scripts_path)
	env.info("loading -> 4_1_5_csar.lua")
	dofile(scripts_path .. "4_1_5_csar.lua")
end

function loadFOX(scripts_path)
	env.info("loading -> 4_1_6_fox_trainer.lua")
	dofile(scripts_path .. "4_1_6_fox_trainer.lua")
end

function loadRedChief(scripts_path)
	env.info("loading -> 4_2_2_redchief.lua")
	dofile(scripts_path .. "4_2_2_redchief.lua")
end

function loadAtis(scripts_path)
	env.info("loading -> 3_2_atis.lua")
	dofile(scripts_path .. "3_2_atis.lua")
end

function loadAGRange(scripts_path)
	env.info("loading -> 4_1_7_training_ground_ag.lua")
	dofile(scripts_path .. "4_1_7_training_ground_ag.lua")
end

function loadVazianiAW(scripts_path)
	env.info("loading -> AW_Vaziani.lua")
	dofile(scripts_path .. "AW_Vaziani.lua")
end

function loadKutaisiAW(scripts_path)
	env.info("loading -> AW_Kutaisi.lua")
	dofile(scripts_path .. "AW_Kutaisi.lua")
end

function loadMozdokAW(scripts_path)
	env.info("loading -> AW_Mozdok.lua")
	dofile(scripts_path .. "AW_Mozdok.lua")
end

function loadScheduler(scripts_path)
	env.info("loading -> 5_1_1_schedulers.lua")
	dofile(scripts_path .. "5_1_1_schedulers.lua")
end

function loadDebuger(scripts_path)
	env.info("loading -> debuger.lua")
	dofile(scripts_path .. "debuger.lua")
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

