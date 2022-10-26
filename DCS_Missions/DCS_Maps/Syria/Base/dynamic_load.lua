env.info( 'CUSTOM *** DYNAMIC LOAD SCRIPTS *** ' )
local base = _G

local FRAMEWORKS = {"E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\paths.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\Moose.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\DCS-SimpleTextToSpeech.lua", }
local SCRIPTS = {"E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\0_1_const.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_1_variables.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_2_common.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\2_1_menu.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\2_2_clients.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_1_atis.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_2_airboss.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_3_range.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\AW_Akrotiri.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\AW_Larnaca.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\AW_Assad.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\CHIEF Red.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\RAT.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\MANTIS_Red.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\5_1_schedulers.lua", }

__Script = {}
__Script.Include = function(IncludeFile)
	if not __Script.Includes[IncludeFile] then
		__Script.Includes[IncludeFile] = IncludeFile
		local f = assert(base.loadfile(IncludeFile))
		if f == nil then
			error ("ERROR Could not load Script file " .. IncludeFile )
		else
			env.info( "CUSTOM file -> " .. IncludeFile .. " dynamically loaded." )
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
env.info( 'CUSTOM *** DYNAMIC LOAD END *** ' )