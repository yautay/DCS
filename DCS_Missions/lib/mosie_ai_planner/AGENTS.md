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
src/09_attack.lua   — target package parsing helpers, attack task builders, ATTACKING state
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

## Planned AI Attack Package Contract

This is the intended attack-authoring flow for future MosieAiPlanner attack control. Treat it
as a design contract until the implementation exists.

Waypoint zones keep normal navigation semantics. A `TARGET` waypoint is the attack commit
point and may reference a reusable target package with `__P_<PACKAGE_ID>`:

```text
MN_<PLAN>_<ORDER>_TARGET_<NAME>__A<ALT_FT>__T<HH:MM>__S<GS_KT>__P_<PACKAGE_ID>
```

Target packages use separate trigger zones:

```text
MNT_<PACKAGE_ID>_<PROFILE>[_<NAME>]
```

The `MNT_` zone coordinate is the actual aim/search centre. Its radius is the CEP/search
radius. Multiple plans or groups may reference the same package. Package zones are data-only
and must not be drawn on the F10 map.

Runtime flow:

1. AI follows the normal route to the `TARGET` waypoint.
2. `INGRESS -> TARGET` remains the attack axis and `TARGET __T` remains the timing anchor.
3. On entering the `TARGET` zone radius, planner state changes to `ATTACKING`.
4. While `ATTACKING`, normal `Route(...)` retasks, ETA correction, and timing orbit retasks are suspended.
5. The attack task targets the referenced `MNT_` package, not the `TARGET` waypoint coordinate.
6. After release/attack timeout, the group routes to the next `EGRESS` waypoint.
7. After `EGRESS`, normal route following resumes.

Planned profiles:

- `ILLUM` — illuminate the target area.
- `DIVE_BOMB` — unguided bomb attack from a dive.
- `LEVEL_BOMB` — unguided level/carpet bombing attack.
- `ROCKETS` — rocket attack.
- `STRAFE` — cannon/gun strafe.
- `SEARCH_DESTROY` — search hostile units in the `MNT_` radius and attack matching targets.

`SEARCH_DESTROY` filters are planned as `__U_AAA`, `__U_TRUCK`, `__U_APC`, `__U_TANK`,
`__U_ARTY`, `__U_INF`, `__U_SHIP`, and `__U_ANY`. Attack profiles default to expending all
allowed weapons for that profile.
