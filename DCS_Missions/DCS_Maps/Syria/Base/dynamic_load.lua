env.info( 'CUSTOM *** DYNAMIC LOAD SCRIPTS *** ' )
local base = _G

local FRAMEWORKS = {"D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\paths.lua", "D:\\repo\\DCS\\DCS_Missions\\lib\\Moose.lua", "D:\\repo\\DCS\\DCS_Missions\\lib\\DCS-SimpleTextToSpeech.lua", }
local SCRIPTS = {"D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\0_1_const.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_1_variables.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\1_2_common.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\2_1_menu.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\2_2_clients.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_1_atis.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_2_airboss.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\3_3_range.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\AW_Akrotiri.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\TANKERS_BLUE.lua", "D:\\repo\\DCS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\BVR_Trainer.lua", }

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