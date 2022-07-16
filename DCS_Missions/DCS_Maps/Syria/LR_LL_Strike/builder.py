from lib import *
from DCS_Maps.Caucasus.Caucasus_BFM_1.Scripts import *
from collections import OrderedDict
import os


CWD = os.path.dirname(os.path.abspath(__file__))
FRAMEWORK_FILE = "frameworks.lua"
SCRIPTS_FILE = "script.lua"

frameworks_order = OrderedDict()
frameworks_order["\n--1 - PATHS\n"] = PATH_SCRIPT_PATHS
frameworks_order["\n--2 - MOOSE\n"] = PATH_LIBS_MOOSE
frameworks_order["\n--3 - MIST\n"] = PATH_LIBS_MIST
frameworks_order["\n--4 - STTS\n"] = PATH_LIBS_STTS


scripts_order = OrderedDict()
scripts_order["\n--1 - VARIABLES)\n"] = PATH_SCRIPT_VARIABLES
scripts_order["\n--2 - COMMON\n"] = PATH_SCRIPT_COMMON
scripts_order["\n--3 - RADIO PRESETS\n"] = PATH_SCRIPT_RADIO_PRESETS
scripts_order["\n--4 - MENU\n"] = PATH_SCRIPT_MENU
scripts_order["\n--5 - ATIS\n"] = PATH_SCRIPT_ATIS
scripts_order["\n--7 - AIRBOSS\n"] = PATH_SCRIPT_AIRBOSS
scripts_order["\n--8 - CSAR\n"] = PATH_SCRIPT_CSAR
scripts_order["\n--9 - FOX\n"] = PATH_SCRIPT_FOX_TRAINER
scripts_order["\n--11.1 - AW VAZ\n"] = PATH_SCRIPT_AW_VAZIANI
scripts_order["\n--11.2 - AW KUT\n"] = PATH_SCRIPT_AW_KUTAISI
scripts_order["\n--13 - SCHEDULER\n"] = PATH_SCRIPT_SCHEDULERS


def open_script(path):
    with open(path, "rb") as file:
        return file.read()


def append_script(path, content):
    with open(path, "a") as file:
        file.write(content)


def append_binary(path, content):
    with open(path, "ab") as file:
        file.write(content)


for k, v in frameworks_order.items():
    append_script(FRAMEWORK_FILE, k)
    append_binary(FRAMEWORK_FILE, open_script(v))


for k, v in scripts_order.items():
    append_script(SCRIPTS_FILE, k)
    append_binary(SCRIPTS_FILE, open_script(v))
