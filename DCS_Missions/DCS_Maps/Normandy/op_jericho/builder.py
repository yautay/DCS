import os
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

from DCS_Missions.lib import *
from DCS_Missions.DCS_Maps.Normandy.op_jericho.Scripts import *

CWD = os.path.dirname(os.path.abspath(__file__))
FRAMEWORK_FILE = "frameworks.lua"
SCRIPTS_FILE = "script.lua"
DYNAMIC_LOAD_LUA = "dynamic_load.lua"

frameworks_order = {
    "\n--1 - PATHS\n": PATH_SCRIPT_PATHS,
    "\n--2 - MOOSE\n": PATH_LIB_MOOSE,
    "\n--3 - STTS\n": PATH_LIB_STTS,
    "\n--4 - MOSIE NAVIGATOR\n": PATH_LIB_MOSIE_NAVIGATOR,
}

scripts_order = {
    "\n--0_1_const.lua\n": PATH_SCRIPT_CONST,
    "\n--1_1_variables.lua\n": PATH_SCRIPT_VARIABLES,
    "\n--1_2_common.lua\n": PATH_SCRIPT_COMMON,
}


def delete_old_files(filename: str):
    filename = os.path.join(CWD, filename)
    if os.path.exists(filename):
        print(f"Deleting old {filename}")
        os.remove(filename)


delete_old_files(FRAMEWORK_FILE)
delete_old_files(SCRIPTS_FILE)
delete_old_files(DYNAMIC_LOAD_LUA)

content_scripts = ""
content_frameworks = ""


def output_path(filename: str):
    return os.path.join(CWD, filename)


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
    with open(path, "a", encoding="utf-8") as file:
        file.write(content)


def append_binary(path, content):
    with open(path, "ab") as file:
        file.write(content)


for k, v in frameworks_order.items():
    append_script(output_path(FRAMEWORK_FILE), k)
    append_binary(output_path(FRAMEWORK_FILE), open_script(v))
    content_frameworks += '"{}", '.format(v.replace("\\", "\\\\"))

for k, v in scripts_order.items():
    append_script(output_path(SCRIPTS_FILE), k)
    append_binary(output_path(SCRIPTS_FILE), open_script(v))
    content_scripts += '"{}", '.format(v.replace("\\", "\\\\"))

content_scripts = "{" + content_scripts + "}"
content_frameworks = "{" + content_frameworks + "}"

dynamic_load_scripts = f"local SCRIPTS = {content_scripts}\n"
dynamic_load_frameworks = f"local FRAMEWORKS = {content_frameworks}\n"

template = read_lines(output_path("dynamic_load.template"))

for i in range(len(template)):
    if template[i].__contains__("FRAMEWORKS_PLACEHOLDER"):
        template[i] = dynamic_load_frameworks
    elif template[i].__contains__("SCRIPTS_PLACEHOLDER"):
        template[i] = dynamic_load_scripts

write_lines(output_path(DYNAMIC_LOAD_LUA), template)
# append_script(DYNAMIC_LOAD_LUA, dynamic_load_lua)
