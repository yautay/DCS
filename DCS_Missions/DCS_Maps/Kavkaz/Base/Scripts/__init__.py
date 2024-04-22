import os


PATH_MISSION_SCRIPTS = os.path.dirname(os.path.abspath(__file__))

PATH_SCRIPT_PATHS = os.path.join(PATH_MISSION_SCRIPTS, "paths.lua")

# edit from here, those scripts will be smashed into final script file
PATH_SCRIPT_CONST = os.path.join(PATH_MISSION_SCRIPTS, "0_1_const.lua")
PATH_SCRIPT_VARIABLES = os.path.join(PATH_MISSION_SCRIPTS, "1_1_variables.lua")
PATH_SCRIPT_COMMON = os.path.join(PATH_MISSION_SCRIPTS, "1_2_common.lua")
PATH_SCRIPT_CLIENTS = os.path.join(PATH_MISSION_SCRIPTS, "2_2_clients.lua")
# PATH_SCRIPT_AIRBOSS = os.path.join(PATH_MISSION_SCRIPTS, "3_2_airboss.lua")
PATH_SCRIPT_RANGE = os.path.join(PATH_MISSION_SCRIPTS, "3_3_range.lua")


PATH_SCRIPT_AW_SENAKI = os.path.join(PATH_MISSION_SCRIPTS, "4_1_AW_Senaki.lua")
PATH_SCRIPT_AW_SOCHI = os.path.join(PATH_MISSION_SCRIPTS, "4_2_AW_Sochi.lua")
# PATH_SCRIPT_TANKERS_BLUE = os.path.join(PATH_MISSION_SCRIPTS, "4_2_TANKERS_BLUE.lua")
PATH_SCRIPT_PVE_TRAINER = os.path.join(PATH_MISSION_SCRIPTS, "6_1_PVE_Trainer.lua")

PATH_SCRIPT_ATIS = os.path.join(PATH_MISSION_SCRIPTS, "9_1_atis.lua")
