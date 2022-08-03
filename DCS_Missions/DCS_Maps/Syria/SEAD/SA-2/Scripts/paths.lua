SERVER = false

SERVER_PATH = "C:\\Users\\yauta\\Saved Games\\DCS.openbeta_server\\Missions\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\"
LOCAL_PATH = "E:\\repos\\DCS_MISSIONS\\DCS_Missions\\DCS_Maps\\Syria\\Base\\Scripts\\"

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

env.info("### PATH SETUP ###")
env.info(string.format("SERVER->%s", tostring(SERVER)))
env.info(string.format("SCRIPTS PATH->%s", scripts_path))
env.info(string.format("SRS PATH->%s", SRS_PATH))
env.info(string.format("SRS PORT->%s", SRS_PORT))
env.info("### PATH SETUP ###")
