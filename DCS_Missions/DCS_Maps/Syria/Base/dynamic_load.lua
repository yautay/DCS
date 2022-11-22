env.info( 'CUSTOM *** DYNAMIC LOAD SCRIPTS *** ' )
local base = _G

local FRAMEWORKS = {"F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\paths.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\Moose.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\lib\\DCS-SimpleTextToSpeech.lua", }
local SCRIPTS = {"F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\0_1_const.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_1_variables.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_2_common.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\2_1_menu.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\2_2_clients.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_1_atis.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_2_airboss.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_3_range.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\AW_Akrotiri.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\TANKERS_BLUE.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\CHIEF Red.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\RAT.lua", "F:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\MANTIS_Red.lua", }

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