import os
PATH_MISSION_SCRIPTS = os.path.dirname(os.path.abspath(__file__))
PATH_SCRIPT_PATHS = os.path.join(PATH_MISSION_SCRIPTS, "paths.lua")

#common libs
PATH_LIBS_MOOSE = os.path.join(PATH_MISSION_SCRIPTS, "0_1_const.lua")
# edit from here, those scripts will be smashed into final script file
PATH_SCRIPT_CONST = os.path.join(PATH_MISSION_SCRIPTS, "0_1_const.lua")
PATH_SCRIPT_VARIABLES = os.path.join(PATH_MISSION_SCRIPTS, "1_1_variables.lua")
PATH_SCRIPT_COMMON = os.path.join(PATH_MISSION_SCRIPTS, "1_2_common.lua")
PATH_SCRIPT_AIRWING = os.path.join(PATH_MISSION_SCRIPTS, "4_2_AIRWING.lua")
PATH_SCRIPT_SQUADRONS = os.path.join(PATH_MISSION_SCRIPTS, "4_1_SQUADRONS.lua")
PATH_SCRIPT_AWACS = os.path.join(PATH_MISSION_SCRIPTS, "4_3_AWACS.lua")
PATH_SCRIPT_SPAWN = os.path.join(PATH_MISSION_SCRIPTS, "4_4_SPAWN.lua")
PATH_SCRIPT_MANTIS = os.path.join(PATH_MISSION_SCRIPTS, "4_5_MANTIS.lua")
