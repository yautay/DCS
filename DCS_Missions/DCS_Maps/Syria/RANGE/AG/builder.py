import string

from lib import *
# change this below!!!!
from DCS_Maps.Syria.RANGE.AG.Scripts import *
from collections import OrderedDict
import os

CWD = os.path.dirname(os.path.abspath(__file__))
FRAMEWORK_FILE = "frameworks.lua"
SCRIPTS_FILE = "script.lua"
DYNAMIC_LOAD_LUA = "dynamic_load.lua"

frameworks_order = OrderedDict()
frameworks_order["\n--1 - PATHS\n"] = PATH_SCRIPT_PATHS
frameworks_order["\n--2 - MOOSE\n"] = PATH_LIBS_MOOSE
# frameworks_order["\n--3 - MIST\n"] = PATH_LIBS_MIST
frameworks_order["\n--4 - STTS\n"] = PATH_LIBS_STTS
# frameworks_order["\n--5 - SKYNET\n"] = PATH_LIBS_SKYNET
# frameworks_order["\n--6 - HOUND\n"] = PATH_LIBS_HOUND


scripts_order = OrderedDict()
scripts_order["\n--0.1 - CONST\n"] = PATH_SCRIPT_CONST
scripts_order["\n--1.1 - VARIABLES\n"] = PATH_SCRIPT_VARIABLES
scripts_order["\n--1.2 - COMMON\n"] = PATH_SCRIPT_COMMON
scripts_order["\n--2.1 - MENU\n"] = PATH_SCRIPT_MENU
scripts_order["\n--3.1 - ATIS\n"] = PATH_SCRIPT_ATIS
scripts_order["\n--3.2 - AIRBOSS\n"] = PATH_SCRIPT_AIRBOSS

scripts_order["\n--4.2 - CSAR\n"] = PATH_SCRIPT_CSAR

scripts_order["\n--AW.1 - AW AKROTIRI\n"] = PATH_SCRIPT_AW_AKROTIRI
scripts_order["\n--AW.2 - AW LARNACA\n"] = PATH_SCRIPT_AW_LARNACA
scripts_order["\n--AW.3 - AW ASSAD\n"] = PATH_SCRIPT_AW_ASSAD
scripts_order["\n--CHIEF.1 - CHIEF RED\n"] = PATH_SCRIPT_RED_CHIEF

scripts_order["\n--MANTIS - Red IADS\n"] = PATH_SCRIPT_MANTIS_RED
# scripts_order["\n--SCR - SCORING\n"] = PATH_SCRIPT_SCORING
scripts_order["\n--5.1 - SCHEDULER\n"] = PATH_SCRIPT_SCHEDULERS


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
