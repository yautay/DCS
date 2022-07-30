env.info( '*** DYNAMIC LOAD SCRIPTS *** ' )
local base = _G

local FRAMEWORKS = {"E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\paths.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\Moose.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\mist_4_5_107.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\DCS-SimpleTextToSpeech.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\skynet-iads_3_0_3.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\HoundElint.lua", }
local SCRIPTS = {"E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\0_1_const.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_1_variables.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_2_common.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\2_1_menu.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_1_atis.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\4_1_range.lua", "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\4_2_csar.lua", }

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