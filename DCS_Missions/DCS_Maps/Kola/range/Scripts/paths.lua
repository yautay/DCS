SERVER = false

SERVER_DCS_PATH = "D:\\repo\\DCS\\DCS_Missions"
LOCAL_DCS_PATH = "F:\\repo\\DCS\\DCS_Missions"

SCRIPTS_PATH = "\\DCS_Maps\\Kola\\range\\Scripts\\"

LIBS_PATH = "\\lib"


SRS_PATH = nil
SRS_PORT = nil

SRS_SERVER_PATH = "C:\\DCS-SimpleRadio-Standalone"
SRS_SERVER_PORT = 5002
SRS_LOCAL_PATH = "Z:\\DCS-SimpleRadio-Standalone"
SRS_LOCAL_PORT = 5002

SERVER_SAVE_SHEET_PATH = "C:\\DCS_Data\\"
LOCAL_SAVE_SHEET_PATH = "Z:\\DUMP\\"

if (SERVER) then
	scripts_path = SERVER_DCS_PATH .. SCRIPTS_PATH
	lib_path = SERVER_DCS_PATH .. LIBS_PATH
	SRS_PATH = SRS_SERVER_PATH
	SRS_PORT = SRS_SERVER_PORT
	SHEET_PATH = SERVER_SAVE_SHEET_PATH
else
	scripts_path = LOCAL_DCS_PATH .. SCRIPTS_PATH
	lib_path = LOCAL_DCS_PATH .. LIBS_PATH
	SRS_PATH = SRS_LOCAL_PATH
	SRS_PORT = SRS_LOCAL_PORT
	SHEET_PATH = LOCAL_SAVE_SHEET_PATH
end

local function ensureDirectory(path)
	local normalizedPath = path:gsub("[/\\]+$", "")
	if lfs and not lfs.attributes(normalizedPath, "mode") then
		local ok, err = lfs.mkdir(normalizedPath)
		if not ok then
			env.info(string.format("CUSTOM ERROR could not create directory %s: %s", normalizedPath, tostring(err)))
		end
	elseif not lfs then
		env.info(string.format("CUSTOM WARNING lfs unavailable; cannot ensure directory %s", normalizedPath))
	end
end

ensureDirectory(SHEET_PATH)

env.info("CUSTOM ### PATH SETUP ###")
env.info(string.format("CUSTOM SERVER->%s", tostring(SERVER)))
env.info(string.format("CUSTOM SCRIPTS PATH->%s", scripts_path))
env.info(string.format("CUSTOM SRS PATH->%s", SRS_PATH))
env.info(string.format("CUSTOM SRS PORT->%s", SRS_PORT))
env.info("CUSTOM ### PATH SETUP ###")
