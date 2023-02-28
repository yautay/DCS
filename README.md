# DCS MISSIONS
## Project Structure
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
## Workflow
WIP
