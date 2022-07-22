from lib import *
from DCS_Maps.Caucasus.Caucasus_Core.Scripts import *
from collections import OrderedDict
import os
import pyfiglet


CWD = os.path.dirname(os.path.abspath(__file__))
FRAMEWORK_FILE = "frameworks.lua"
SCRIPTS_FILE = "script.lua"

frameworks_order = OrderedDict()
frameworks_order[pyfiglet.figlet_format('1 - PATHS')] = PATH_SCRIPT_PATHS
frameworks_order[pyfiglet.figlet_format('2 - MOOSE')] = PATH_LIBS_MOOSE
frameworks_order[pyfiglet.figlet_format('3 - MIST')] = PATH_LIBS_MIST
frameworks_order[pyfiglet.figlet_format('4 - STTS')] = PATH_LIBS_STTS
frameworks_order[pyfiglet.figlet_format('5 - HOUND')] = PATH_LIBS_HOUND

scripts_order = OrderedDict()
scripts_order[pyfiglet.figlet_format('1 - VARIABLES')] = PATH_SCRIPT_VARIABLES
scripts_order[pyfiglet.figlet_format('2 - COMMON')] = PATH_SCRIPT_COMMON
scripts_order[pyfiglet.figlet_format('3 - RADIO PRESETS')] = PATH_SCRIPT_RADIO_PRESETS
scripts_order[pyfiglet.figlet_format('4 - MENU')] = PATH_SCRIPT_MENU
scripts_order[pyfiglet.figlet_format('5 - ATIS')] = PATH_SCRIPT_ATIS
scripts_order[pyfiglet.figlet_format('6 - ELINT')] = PATH_SCRIPT_ELINT
scripts_order[pyfiglet.figlet_format('7 - AIRBOSS')] = PATH_SCRIPT_AIRBOSS
scripts_order[pyfiglet.figlet_format('8 - CSAR')] = PATH_SCRIPT_CSAR
scripts_order[pyfiglet.figlet_format('9 - FOX')] = PATH_SCRIPT_FOX_TRAINER
scripts_order[pyfiglet.figlet_format('10 - AG GROUND')] = PATH_SCRIPT_TRAINING_GROUND_AG
scripts_order[pyfiglet.figlet_format('11.1 - AW VAZ')] = PATH_SCRIPT_AW_VAZIANI
scripts_order[pyfiglet.figlet_format('11.2 - AW KUT')] = PATH_SCRIPT_AW_KUTAISI
scripts_order[pyfiglet.figlet_format('11.3 - AW MOZ')] = PATH_SCRIPT_AW_MOZDOK
scripts_order[pyfiglet.figlet_format('12 - RED CHIEF')] = PATH_SCRIPT_REDCHIEF
scripts_order[pyfiglet.figlet_format('13 - SCHEDULER')] = PATH_SCRIPT_SCHEDULERS


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
