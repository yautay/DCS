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

Shared Lua libraries live in `DCS_Missions/lib/`. Key modules:

- `DCS_Missions/lib/mosie_navigator/` — flight plan navigator. See its own `AGENTS.md`.
- `DCS_Missions/lib/mosie_ai_planner/` — AI group scheduler. See its own `AGENTS.md`.
- `DCS_Missions/lib/test_helpers/` — shared Lua test shim and framework (do not load in DCS runtime).

## Development Layout

Both `mosie_navigator/` and `mosie_ai_planner/` ship **generated runtime bundles**
(`MosieNavigator.lua`, `MosieAiPlanner.lua`) built from numbered source modules in `src/`.

**Never edit the bundle directly.** All behavioural changes must go into `src/*.lua`
and be propagated with `python3 build.py`. Verify sync with `python3 build.py --check`.

## Test Coverage

Run test coverage for both libraries from the repo root:

```bash
eval "$(/tmp/luaenv/bin/luarocks path)"   # make luacov visible to lua
python3 scripts/coverage.py               # runs both specs, reports per-file and total
```

Individual spec suites (without coverage):

```bash
cd DCS_Missions/lib/mosie_navigator  && lua MosieNavigator.spec.lua
cd DCS_Missions/lib/mosie_ai_planner && lua MosieAiPlanner.spec.lua
```

Coverage threshold: **80% total per module** (enforced by the runner; exit 1 on failure).
Prerequisites: Lua 5.3+, LuaCov — see `README.md` for install instructions.
