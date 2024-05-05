from DCS_Missions.lib import *
from DCS_Missions.DCS_Maps.Kola.Base.Scripts import *
from collections import OrderedDict
import os

CWD = os.path.dirname(os.path.abspath(__file__))
FRAMEWORK_FILE = "frameworks.lua"
SCRIPTS_FILE = "script.lua"
DYNAMIC_LOAD_LUA = "dynamic_load.lua"

frameworks_order = OrderedDict()
frameworks_order["\n--1 - PATHS\n"] = PATH_SCRIPT_PATHS
# frameworks_order["\n--2 - MOOSE\n"] = PATH_LIBS_MOOSE_CUSTOM
frameworks_order["\n--2 - MOOSE\n"] = PATH_LIBS_MOOSE
frameworks_order["\n--4 - STTS\n"] = PATH_LIBS_STTS

scripts_order = OrderedDict()
scripts_order["\n--0.1 - CONST\n"] = PATH_SCRIPT_CONST
scripts_order["\n--1.1 - VARIABLES\n"] = PATH_SCRIPT_VARIABLES
scripts_order["\n--1.2 - COMMON\n"] = PATH_SCRIPT_COMMON
scripts_order["\n--2.2 - CLIENT\n"] = PATH_SCRIPT_CLIENTS
scripts_order["\n--3.2 - AIRBOSS\n"] = PATH_SCRIPT_AIRBOSS
# scripts_order["\n--3.3 - Base\n"] = PATH_SCRIPT_RANGE

# scripts_order["\n--AW.1 - AW SENAKI\n"] = PATH_SCRIPT_AW_SENAKI
# scripts_order["\n--AW.1 - AW SOCHI\n"] = PATH_SCRIPT_AW_SOCHI
# scripts_order["\n--TANKERS BLUE\n"] = PATH_SCRIPT_TANKERS_BLUE

# scripts_order["\n--PVE TRAINER\n"] = PATH_SCRIPT_PVE_TRAINER

# scripts_order["\n--9.1 - ATIS\n"] = PATH_SCRIPT_ATIS
scripts_order["\n--9.2 - RAT\n"] = PATH_SCRIPT_RAT

def delete_old_files(filename: str):
    if os.path.exists(filename):
        print(f"Deleting old {filename}")
        os.remove(filename)


delete_old_files(FRAMEWORK_FILE)
delete_old_files(SCRIPTS_FILE)
delete_old_files(DYNAMIC_LOAD_LUA)

content_scripts = ""
content_frameworks = ""


def open_script(path):
    with open(path, "rb") as file:
        return file.read()


def read_lines(path):
    with open(path, "r") as file:
        return file.readlines()


def write_lines(path, lines):
    with open(path, "w") as file:
        file.writelines(lines)


def append_script(path, content):
    with open(path, "a") as file:
        file.write(content)


def append_binary(path, content):
    with open(path, "ab") as file:
        file.write(content)


for file in [FRAMEWORK_FILE, SCRIPTS_FILE]:
    if os.path.exists(file):
        os.remove(file)

for k, v in frameworks_order.items():
    append_script(FRAMEWORK_FILE, k)
    append_binary(FRAMEWORK_FILE, open_script(v))
    content_frameworks += '"{}", '.format(v.replace("\\", "\\\\"))

for k, v in scripts_order.items():
    append_script(SCRIPTS_FILE, k)
    append_binary(SCRIPTS_FILE, open_script(v))
    content_scripts += '"{}", '.format(v.replace("\\", "\\\\"))

content_scripts = "{" + content_scripts + "}"
content_frameworks = "{" + content_frameworks + "}"

dynamic_load_scripts = f"local SCRIPTS = {content_scripts}\n"
dynamic_load_frameworks = f"local FRAMEWORKS = {content_frameworks}\n"

template = read_lines("dynamic_load.template")

for i in range(len(template)):
    if template[i].__contains__("FRAMEWORKS_PLACEHOLDER"):
        template[i] = dynamic_load_frameworks
    elif template[i].__contains__("SCRIPTS_PLACEHOLDER"):
        template[i] = dynamic_load_scripts

write_lines(DYNAMIC_LOAD_LUA, template)
# append_script(DYNAMIC_LOAD_LUA, dynamic_load_lua)
