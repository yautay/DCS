SERVER = false

SERVER_DCS_PATH = "D:\\repos\\DCS\\DCS_Missions"
LOCAL_DCS_PATH = "D:\\repo\\DCS\\DCS_Missions"

SCRIPTS_PATH = "\\DCS_Maps\\Syria\\Base\\Scripts\\"

LIBS_PATH = "\\lib"


SRS_PATH = nil
SRS_PORT = nil

SRS_SERVER_PATH = "D:\\DCS-SimpleRadio-Standalone"
SRS_SERVER_PORT = 5002
SRS_LOCAL_PATH = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
SRS_LOCAL_PORT = 5002

SERVER_SAVE_SHEET_PATH = "C:\\Users\\yauta\\Saved Games\\DCS.openbeta_server\\Sheets"
LOCAL_SAVE_SHEET_PATH = "C:\\Users\\yauta\\Saved Games\\DCS.openbeta_server\\Sheets"

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

env.info("CUSTOM ### PATH SETUP ###")
env.info(string.format("CUSTOM SERVER->%s", tostring(SERVER)))
env.info(string.format("CUSTOM SCRIPTS PATH->%s", scripts_path))
env.info(string.format("CUSTOM SRS PATH->%s", SRS_PATH))
env.info(string.format("CUSTOM SRS PORT->%s", SRS_PORT))
env.info("CUSTOM ### PATH SETUP ###")
