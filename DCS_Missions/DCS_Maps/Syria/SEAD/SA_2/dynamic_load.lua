env.info( '*** DYNAMIC LOAD SCRIPTS *** ' )
local base = _G

local FRAMEWORKS = {"E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\paths.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\Moose.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\mist_4_5_107.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\DCS-SimpleTextToSpeech.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\skynet-iads_3_0_3.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\HoundElint.lua", }
local SCRIPTS = {"E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\0_1_const.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\1_1_variables.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\1_2_common.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\2_1_menu.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\3_1_atis.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\3_2_airboss.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\4_2_csar.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\AW_Ramat_David.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\AW_Akrotiri.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\Red_IADS.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\Scorring.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\SEAD\\SA_2\\Scripts\\5_1_schedulers.lua", }

__Script = {}
__Script.Include = function(IncludeFile)
	if not __Script.Includes[IncludeFile] then
		__Script.Includes[IncludeFile] = IncludeFile
		local f = assert(base.loadfile(IncludeFile))
		if f == nil then
			error ("Could not load Script file " .. IncludeFile )
		else
			env.info( IncludeFile .. " dynamically loaded." )
			return f()
		end
	end
end

__Script.Includes = {}

for i, v in pairs(FRAMEWORKS) do
	__Script.Include(v)
end

for i, v in pairs(SCRIPTS) do
	__Script.Include(v)
end

BASE:TraceOnOff(true)
env.info( '*** DYNAMIC LOAD END *** ' )