# Repository Agent Instructions

## Do Not Read

Archived missions live under `DCS_Missions/DCS_Maps/Archived/`. Skip this
directory entirely — it contains historical missions not relevant to current
development. Ignore patterns are also declared in `.agentignore`.

## Active Mission

Current active mission: `DCS_Missions/DCS_Maps/Normandy/op_jericho/`.

## DCS Analysis Inputs

For active mission debugging, inspect:

- Mission file: `DCS_Missions/DCS_Maps/Normandy/op_jericho/op_jerycho.miz`
- `.miz` files are ZIP archives; inspect the `mission` entry for trigger zones and group names.
- DCS logs: `C:\Users\yauta\Saved Games\DCS\Logs`
- Useful log/artifact files include `dcs.log`, `NAVDUMP.log`, `AI_ZONE_DUMP.log`, `MosieNavigator_*.txt`, and `MosieNavigator_*.csv`.

## Libraries

Shared Lua libraries live in `DCS_Missions/lib/`. The main navigator script
is `DCS_Missions/lib/mosie_navigator/` — see its own `AGENTS.md` for details.
