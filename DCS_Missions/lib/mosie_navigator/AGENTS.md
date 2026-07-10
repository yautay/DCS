# Mosie Navigator Contract

This directory defines the trigger-zone contract for the future Mosie Navigator tool. Follow this contract when editing or generating files here.

## Scope

- This directory contains documentation, trigger-zone naming examples, and the first debug Lua implementation.
- Keep Lua runtime changes minimal and focused unless explicitly requested.
- Do not add builder integration unless explicitly requested.
- Do not reintroduce YAML flight plan files unless explicitly requested.

## Naming

- Use `mosie_navigator` as the directory name.
- Use trigger zones in the DCS Mission Editor as the source of navigation data.
- Use `MN_` as the flight plan trigger zone prefix.
- Use `MNB_` as the beacon trigger zone prefix.
- Use `[MN:<PLAN>]` in DCS group names to assign groups to plans.

## Group Assignment Contract

Assign a DCS group to a plan by adding this tag to the group name:

```text
<GROUP NAME> [MN:<PLAN>][__R<H:MM|H:MM:SS|M>]
```

Examples:

```text
MOSQUITO 1-1 [MN:JERICHO]
MOSQUITO 1-2 [MN:JERICHO]__R0:05
MOSQUITO 1-3 [MN:JERICHO]__R0:00:30
SPITFIRE 2-1 [MN:ESCORT]
```

`PLAN` must match a plan identifier discovered from `MN_` trigger zones.

`__R...` is an optional group ROLEX delay that shifts all displayed/exported TOT values for that group only. Accepted examples: `__R5`, `__R0:05`, `__R0:00:30`. It must not change calculated TAS because the whole plan is shifted by the same amount.

## Flight Plan Trigger Zone Contract

Flight plans are discovered from trigger zone names.

Required format:

```text
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>][__A<ALT_FT>][__T<TOT>]
```

Fields:

- `MN`: literal prefix.
- `PLAN`: plan identifier without underscores.
- `ORDER`: zero-padded waypoint order.
- `TYPE`: waypoint type enum.
- `NAME`: optional human-readable waypoint name without spaces. If omitted, the waypoint type is used as the display name.
- `__A<ALT_FT>`: optional planned altitude in feet, for example `__A500` or `__A500FT`.
- `__T<TOT>`: optional planned time on target, using `HH:MM` or `HH:MM:SS`, for example `__T14:30`.

If both ends of a leg define `__T`, `MosieNavigator.lua` may calculate required leg TAS in knots. If either end has no `__T`, TAS for that leg must be omitted or displayed as `---`. Static FP/navlog output may also show IAS calculated from the row waypoint altitude (`__A`) and magnetic course corrected for declination only. Wind-corrected magnetic heading belongs to active navigator guidance, not static FP/navlog output.

Example:

```text
MN_JERICHO_01_TAKE_OFF_Tangmere
MN_JERICHO_02_NAV
MN_JERICHO_03_RENDEZVOUS_Rendezvous
MN_JERICHO_04_HOLD_Hold
MN_JERICHO_05_INGRESS_IP
MN_JERICHO_06_TARGET_Prison
MN_JERICHO_07_EGRESS_Egress
MN_JERICHO_08_LANDING_Tangmere
```

Optional planned altitude and TOT example:

```text
MN_JERICHO_05_INGRESS_IP__A50__T14:28
MN_JERICHO_06_TARGET_Prison__A50__T14:30
```

Allowed waypoint `type` values:

- `TAKE_OFF`
- `LANDING`
- `RENDEZVOUS`
- `INGRESS`
- `TARGET`
- `EGRESS`
- `NAV`
- `HOLD`

Use `INGRESS` for IP / initial point semantics. Do not add a separate `IP` or `INITIAL_POINT` type unless the contract is explicitly changed.

## Beacon Trigger Zone Contract

Beacons are mission-wide and shared by all aircraft.

Full format:

```text
MNB_<ID>_<FREQUENCY>_<POWER_NM>_<ALT_FT>
```

Minimal format:

```text
MNB_<ID>
```

Fields:

- `MNB`: literal prefix.
- `ID`: stable unique beacon identifier within the mission, without underscores.
- `FREQUENCY`: display frequency, for example `310KHZ`.
- `POWER_NM`: nominal power/range, for example `120NM`.
- `ALT_FT`: beacon altitude, for example `200FT`.

Examples:

```text
MNB_TANGMERE_310KHZ_120NM_200FT
MNB_BAYEUX_315KHZ_90NM_180FT
MNB_TANGMERE
```

Flight plan zones must not define beacons. Beacon zones must not assign beacons to groups.

## Coordinates

- Coordinates for the primary workflow come from DCS Mission Editor trigger zone positions.
- Trigger zone names must not encode lat/lon.
- The future script reads coordinates with MOOSE zone APIs such as `ZONE:New(name):GetCoordinate()`.
- Lat/lon may appear in exported CSV files (see CSV Export Contract) because those files are the source of truth for the future import path.

## Debug Lua Contract

- `MosieNavigator.lua` may discover zones and draw F10 debug markup.
- `MosieNavigator.lua` may write plain text navlog files for discovered plans.
- `MosieNavigator.lua` may write CSV flight plan files per assigned group and one mission-wide CSV beacons file, intended as source-of-truth for a future import path.
- `MosieNavigator.lua` may periodically refresh group menus for client aircraft that become active after mission start.
- `MosieNavigator.lua` may provide an active text navigator per assigned group, with configurable report intervals, manual waypoint changes, wind-corrected magnetic heading, XTE guidance, and mandatory 60/30 second waypoint callouts.
- It may depend on MOOSE being loaded before it.
- It must not require YAML files.
- It must not implement player navigation state until explicitly requested.
- It may implement minimal F10 debug menu actions explicitly requested by the user.
- It must not implement CSV import until explicitly requested; the CSV export is only the write half of the round-trip.

## CSV Export Contract

CSV files are the intended source of truth for a future import path (defining plans and beacons in files instead of in the Mission Editor). Export must remain round-trip-lossless so a future importer can rebuild the exact `MN_...` / `MNB_...` zone name.

Filenames (written to the same directory as the text navlog):

```text
MosieNavigator_<GROUP>_<PLAN>.csv
MosieNavigator_<PLAN>.csv            (fallback when no group is assigned)
MosieNavigator_Beacons.csv
```

Flight plan CSV layout:

```text
# PLAN,<plan>
# GROUP,<group>          (only when a group is assigned)
# ROLEX_SEC,<seconds>    (only when non-zero)
ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT
```

- `LAT`, `LON` are signed decimal degrees to 6 dp.
- `NAME` is empty when the source zone had no explicit `_<NAME>` token (the display name defaulted to the type).
- `ALT_FT` is empty when the source zone had no `__A` token.
- `TOT` is empty when the source zone had no `__T` token. When present, format is `HH:MM` or `HH:MM:SS`. TOT is the raw planned value; ROLEX shift is not applied in CSV (the group ROLEX is recorded in the header comment).

Beacon CSV layout:

```text
ID,FREQUENCY,POWER_NM,ALT_FT,LAT,LON
```

- `FREQUENCY` is empty when the source zone was in the minimal `MNB_<ID>` form.
- `POWER_NM` and `ALT_FT` are always populated (defaults substituted when the zone is minimal).
- `LAT`, `LON` are signed decimal degrees to 6 dp.

Toggle CSV output independently via `MosieNavigator.Config.generateCsvFiles` (default `true`). It is independent from `generateFlightPlanFiles` (text navlog).

## Explicitly Forbidden In Flight Plan Zone Names

Do not encode these in flight plan trigger zone names:

- report intervals
- message duration
- UI/menu structure
- realism mode
- scheduler options
- radio horizon options
- global defaults
- runtime player state
- generated Lua fragments

These belong in the future navigator script or builder integration, not in the plan data.

## Testing

Unit tests live in `MosieNavigator.spec.lua`. They load the real `lib/Moose.lua` behind a minimal DCS API shim, then exercise the parsers, formatters, math helpers, and zone discovery flow.

Run from this directory:

```bash
lua MosieNavigator.spec.lua
```

Requires Lua 5.1 (or LuaJIT) — matches the DCS runtime. Exit code is 0 on success, 1 on any failure. Tests must remain compatible with Lua 5.1 semantics (no `goto`, no integer-only `//`, no bitwise operators).
