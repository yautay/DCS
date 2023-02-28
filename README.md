# DCS MISSIONS
## Project Structure
### Repository layout
Missions/projects/ranges within theatre folders as required.
```
\DCS_MISSIONS
+---DCS_Missions
|   +---DCS_Maps
|   |   \---Syria                                   # theatre folder
|   |       \---Mission_1                           # mission folder
|   |           \---Scripts                         
|   |
|   |       \---Mission_2                           
|   |           \---Scripts                         
|   |
|   |       \---Mission_3                           
|   |           \---Scripts                         
|   |
|   |   \---Caucasus                                
|   |       \---My_Mission                          
|   |           \---Scripts                         
|   |
|   |   \---Marianas                                
|   |       \---Test_range                               
|   |           \---Scripts                         
|   |
|   \---lib                                     # common libs
|               
+---server

```

### Mission folder layout
* Intel/Kneeboards sub-folders are optional.
* Base->builder.py - mission builder script - mandatory UPDATE as required
* Scripts->paths.lua - lua router for dynamic mission loading - mandatory UPDATE as required
* Scripts->\_\_init__.py - essential paths for builder - mandatory UPDATE as required
```
\DCS_MISSIONS
|   .gitignore
|   README.md
+---DCS_Missions
|   +---DCS_Maps
|   |   \---Syria                                   # theatre
|   |       \---Base                                # !!! Project Mission directory, duplicate and edit !!!
|   |           |   builder.py                      # builder for mission scripts
|   |           |   dynamic_load.template           # dynamic lua load template - do not edit!
|   |           |   VFR-DAY-SERVER.miz              # miz file
|   |           |   
|   |           +---Intel                           # mission additional files, maps, briefs... not used for scripting
|   |           |       .gitkeep
|   |           |       
|   |           +---Kneeboards                      # kneeboards
|   |           |       F14A-presets.png
|   |           |       F16-presets.png
|   |           |       F18-presets.png
|   |           |       presets.xlsx                
|   |           |       
|   |           \---Scripts                         # scripst for builder.py
|   |               |   0_1_const.lua               # lua shit here seperated by context
|   |               |   1_1_variables.lua           # lua shit here seperated by context   
|   |               |   1_2_common.lua              # lua shit here seperated by context
|   |               |   2_1_menu.lua                # lua shit here seperated by context
|   |               |   2_2_clients.lua             # lua shit here seperated by context
|   |               |   3_1_atis.lua                # lua shit here seperated by context
|   |               |   3_2_airboss.lua             # lua shit here seperated by context
|   |               |   3_3_range.lua               # lua shit here seperated by context
|   |               |   AW_Akrotiri.lua             # lua shit here seperated by context
|   |               |   BVR_Trainer.lua             # lua shit here seperated by context
|   |               |   paths.lua                   # !!! machine specific paths - make sure to update !!!
|   |               |   TANKERS_BLUE.lua            # lua shit here seperated by context
|   |               |   __init__.py                 # !!! lua shit paths - make sure to update !!!
|   |
|   \---lib                                     # Common libs
|       |   beacon.ogg
|       |   DCS-SimpleTextToSpeech.lua
|       |   Moose.lua                           # Develop Moose branch !!!
|       |   __init__.py
|               
+---server
|       ports.ps1                               # PowerShell scripts for server set'up
```
## Prerequisites
DCS lua sanitization must be redone by manual editing MissionScripting.lua within DCS instance.

## Workflow
builder.py script upon execution will build:
1) frameworks.lua - lua file with frameworks included (ie. Moose, STTS, Mist, or whatever...)
2) script.lua - lua file with all scripting you write for specific mission
3) dynamic_load.lua - lua file used in case you wish to dynamically load scripts into dcs ME. Makes workflow faset for mission planing, however not recommended for server. 

Either frameworks.lua + script.lua must be uploaded into DCS mission via ME **in same order**, or dynamic_load.lua must be uploaded once into mission. Never upload both options!

### Update paths.lua file within mission directory
#### usual required once - update variables from paths.lua:
- **SERVER_DCS_PATH** - string representation of **_Windows_** path to your server DCS Missions folder
- **LOCAL_DCS_PATH** - string representation of **_Windows_** path to your local DCS Missions folder
- **SRS_SERVER_PATH** - string representation of **_Windows_** path to your server SRS folder with SRS executable
- **SRS_SERVER_PORT** - string representation of **_Windows_** path to your local SRS folder with SRS executable
- **SRS_LOCAL_PATH** - integer value of your server SRS port
- **SRS_LOCAL_PORT** - integer value of your local SRS port
#### those might be reqiured to create new folder if you wish to keep airboss csv's 
- **SERVER_SAVE_SHEET_PATH** - string representation of **_Windows_** path to your server DCS Sheets folder (AIRBOSS telemetry)
- **LOCAL_SAVE_SHEET_PATH** - string representation of **_Windows_** path to your local DCS Sheets folder (AIRBOSS telemetry)
#### for each new mission folder created update variables:
- **SCRIPTS_PATH** - string representation of **_Windows_** path to **_THIS_** mission's Scripts folder !!!
### lua scripts must be placed within Scripts folder then you must update:
- \_\_init__.py - CRUD scripts that you created, do not delete paths.lua form file (line 6)
- paths.lua - update SERVER variable as required



