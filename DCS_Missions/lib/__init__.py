import os

PATH_DEPENDENCY_SCRIPTS = os.path.dirname(os.path.abspath(__file__))

PATH_LIB_MOOSE = os.path.join(PATH_DEPENDENCY_SCRIPTS, "Moose.lua")
PATH_LIB_MOSIE_NAVIGATOR = os.path.join(PATH_DEPENDENCY_SCRIPTS, "mosie_navigator", "MosieNavigator.lua")
PATH_LIB_STTS = os.path.join(PATH_DEPENDENCY_SCRIPTS, "DCS-SimpleTextToSpeech.lua")
PATH_LIB_ATTACK = os.path.join(PATH_DEPENDENCY_SCRIPTS, "AirGroundAttackScript.lua")
PATH_LIB_BEACON_OGG = os.path.join(PATH_DEPENDENCY_SCRIPTS, "beacon.ogg")
