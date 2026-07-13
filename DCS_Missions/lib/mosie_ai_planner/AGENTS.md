# MosieAiPlanner Agent Instructions

## Source Layout — Edit src/, Never the Bundle

`MosieAiPlanner.lua` is a **generated bundle**. Do not edit it directly.
Any behavioural change must be made in `src/*.lua` first, then propagated to
the bundle by running the build script.

```
src/01_config.lua   — MosieAiPlanner table, config defaults, merge loop
src/02_util.lua     — logging, group checks, unit conversions (knots/nm/ft), _Clamp, _LogStateOnce
src/03_time.lua     — _GetMissionTime, _FormatClock
src/04_io.lua       — output directory, AI_ZONE_DUMP file, debug/command dump helpers, _SetAiMode
src/05_plans.lua    — _GetPlans, _DiscoverAssignments, _GetComputedPlan, _GetSecondsToClockSeconds
src/06_geo.lua      — coordinate helpers, airbase lookup, _FindNearestLandingAirbase, _GetDistanceNm
src/07_zone.lua     — _IsCoordinateInWaypointZone, zone dump, flight-sample formatting, clock helpers
src/08_route.lua    — _BuildRoutePoint, _BuildVec2RoutePoint, line-intercept geometry, _BuildRoute, _RetaskRoute
src/09_control.lua  — _MaybeStartUncontrolled, _AdvanceArrivedWaypoint, _TickHold, timing orbit, _TickAssignment
src/10_main.lua     — Tick, Start, auto-start guard
```

Load order follows the numeric prefix and must be preserved — `10_main.lua` must remain last
because it calls `MosieAiPlanner:Start()`.

## Build

Regenerate the bundle after editing any source module:

```bash
cd DCS_Missions/lib/mosie_ai_planner
python3 build.py          # write MosieAiPlanner.lua from src/*.lua
python3 build.py --check  # exit 1 if bundle drifts from source (used by CI / coverage runner)
```

## Testing

Unit tests live in `MosieAiPlanner.spec.lua`. Load order:

1. `../test_helpers/dcs_shim.lua` — DCS API globals + makeCoord factory
2. `../Moose.lua` — real MOOSE library
3. `../mosie_navigator/src/*.lua` — MosieNavigator (runtime dependency)
4. `src/*.lua` — MosieAiPlanner source modules
5. `../test_helpers/suite.lua` — test framework (suite / it / assert*)

Run from this directory:

```bash
lua MosieAiPlanner.spec.lua
```

Bundle smoke test is included at the end of the spec — it dofile-s `MosieAiPlanner.lua`
to catch syntax errors in the generated bundle.

## Coverage

Run from the repo root:

```bash
eval "$(/tmp/luaenv/bin/luarocks path)"
python3 scripts/coverage.py --module planner
```

Coverage threshold: **80% total**. Per-file coverage below 80% is reported as a warning.
Files that are inherently DCS-runtime-only (e.g. scheduler initialisation in `10_main.lua`)
will always have lower per-file coverage and do not block CI.

## Contract with MosieNavigator

`MosieAiPlanner` depends on `MosieNavigator` being loaded before it.
Key delegation points:

- `_GetNavigator()` → returns the `MosieNavigator` global.
- `_ExtractRolexFromGroupName` → delegates to `MosieNavigator:_ExtractRolexFromGroupName`.
- `_FormatClock` → delegates to `MosieNavigator:_FormatClock` when available; falls back to local HH:MM:SS formatter.
- `_GetOutputDirectory` → delegates to `MosieNavigator:_GetOutputDirectory`.
- `_GetSecondsToClockSeconds` → delegates to `MosieNavigator:_GetSecondsToClockSeconds`.
- `_GetComputedPlan` → calls `MosieNavigator:_GetActiveComputedPlan` or `_ComputePlan`.

Never load `MosieAiPlanner.lua` before `MosieNavigator.lua` in DCS missions.

## Group Assignment Contract

Assign an AI group to a plan by adding a tag to the group name in the Mission Editor:

```text
<GROUP NAME> [MN:<PLAN>][__R<H:MM|H:MM:SS|M>]
```

Examples:

```text
MOSQUITO 1-1 [MN:JERICHO]
MOSQUITO 1-2 [MN:JERICHO]__R0:05
```

`PLAN` must match a plan discovered by MosieNavigator from `MN_` trigger zones.
`__R` is the mission-maker ROLEX baseline — it is not shown to pilots as an active ROLEX.
