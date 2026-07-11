# Mosie Navigator

Mosie Navigator is a navigation assistant for DCS missions. Flight plans and mission beacons are discovered from DCS Mission Editor trigger zones.

The current implementation draws debug markup, writes TXT navlogs, exports CSV route declarations, provides group F10 menus, and runs an active text navigator for assigned groups.

## Goals

- Keep flight plans independent from a specific mission script.
- Build flight plans visually in the DCS Mission Editor.
- Discover flight plan waypoints from trigger zones using naming conventions.
- Discover mission-wide radio beacons from trigger zones using naming conventions.
- Keep runtime settings in the navigator script later, not in mission data files.

## Directory Layout

```text
DCS_Missions/lib/mosie_navigator/
  MosieNavigator.lua
  README.md
  AGENTS.md
  examples/
    trigger_zones.md
```

Mission-specific navigation data should be created as trigger zones in the DCS Mission Editor.

## Assigning Groups To Plans

Assign a DCS aircraft group to a plan by adding a plan tag to the group name:

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

`PLAN` must match the plan identifier from trigger zones, for example `MN_JERICHO_01_TAKE_OFF_Tangmere` uses plan `JERICHO`.

`__R...` is an optional mission-maker ROLEX baseline. It shifts displayed TOT values for that group only, but is treated as that group's original plan and is not shown to pilots as an active F10 ROLEX. Examples:

- `__R5`: delay all TOT values by 5 minutes.
- `__R0:05`: delay all TOT values by 5 minutes.
- `__R0:00:30`: delay all TOT values by 30 seconds.

ROLEX does not change calculated TAS, because every waypoint TOT in that group is shifted by the same amount.

For independent player state later, prefer one client aircraft per DCS group.

## Debug Script

`MosieNavigator.lua` is the current debug/runtime implementation. When loaded after MOOSE, it discovers `MN_` and `MNB_` trigger zones and draws them on the F10 map.

For every group assigned with `[MN:<PLAN>]`, it creates a group F10 menu:

```text
F10 Other > Mosie Navigator
  NAVIGATOR
    Automatic ON
    Automatic OFF
    Show FP
    Status Now
    Next WP
    Prev WP
    Report Interval > 30 sec / 60 sec / 120 sec / 300 sec
  ROLEX
    RESET
    ADVANCE > 1 min / 2 min / 3 min / 5 min / 10 min
    RETARD > 1 min / 2 min / 3 min / 5 min / 10 min
```

`NAVIGATOR > Show FP` displays a simplified flight plan for that group. `NAVIGATOR > Automatic ON/OFF` controls the active text navigator.

`ROLEX` lets the pilot temporarily advance or retard that group's plan. `RESET` returns to the group's original plan, including any mission-maker `__R` baseline from the group name.

When enabled, the navigator sends compact text reports to the group. The regular report interval is selectable from the menu and defaults to 120 seconds. Regardless of the selected interval, the navigator always reports at 60 seconds and 30 seconds before the active waypoint TOT, and when it switches guidance to the next waypoint.

Active navigator reports use current aircraft altitude for IAS, include wind-corrected magnetic heading (`HDG ...M`), required TAS/IAS to meet TOT, fast/slow guidance, and XTE in 1 NM-style whole-mile guidance when off track.

Navigator reports are driven by one global scheduler ticking every 5 seconds, so the runtime cost is intentionally low. The main practical limit is message/audio spam, not computation.

Menus are refreshed after mission start and then periodically, so client aircraft that become active after a player enters a slot should receive the menu shortly after spawning.

It also writes one text navlog per assigned group. If no group assignments are found, it writes one fallback debug navlog per discovered plan. By default files are written to:

```text
<Saved Games DCS>/Logs/MosieNavigator_<GROUP>_<PLAN>.txt
```

The navlog is a single compact plain ASCII table with:

- waypoint number
- waypoint type
- resolved altitude, inherited from previous waypoints when needed
- IAS in mph, TAS in knots, and SOG in knots for the incoming leg
- COG, WHDG/WTAS wind corrections, wind-corrected true heading, magnetic variation, and magnetic heading
- leg distance and leg time
- computed ETA, rounded to full minutes for display
- DCS fuel recommendation for the Mosquito fuel slider and drop tanks

Static FP/navlog headings use forecast wind sampled along each leg every 10 NM, with at least start/end samples. `WHDG` shows heading correction in degrees and `WTAS` shows TAS correction in knots. Magnetic variation is averaged over the same samples, so `HDG(T) + VAR = HDG(M)`. Once computed, static FP/navlog values are cached and reused by `Show FP`.

For assigned groups with `__R...`, `Show FP` and the generated group navlog show baseline-adjusted TOT values without labeling that baseline as active ROLEX. If the pilot changes ROLEX from F10, only that pilot offset is shown as `ROLEX` and the static forecast weather/magnetic variation from the baseline plan is reused.

The script also writes one Mission Editor route declaration CSV per plan and a single mission-wide beacons CSV:

```text
<Saved Games DCS>/Logs/MosieNavigator_<PLAN>.csv
<Saved Games DCS>/Logs/MosieNavigator_Beacons.csv
```

Flight plan CSV columns:

```text
# PLAN,<plan>
ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT
```

Beacons CSV columns:

```text
ID,FREQUENCY,POWER_NM,ALT_FT,LAT,LON
```

Coordinates are written as signed decimal degrees to 6 dp. Flight plan CSV is a declaration export of the Mission Editor trigger zones, not a computed navlog: `NAME`, `ALT_FT`, `TOT`, and `SPEED_KT` are populated only when the mission maker declared the corresponding name, `__A`, `__T`, or `__S` token. Inherited/default/computed values and group ROLEX offsets are not written to flight plan CSV. Beacons CSV remains a direct beacon definition export.

CSV output can be toggled independently via `MosieNavigator.Config.generateCsvFiles` (default `true`).

By default the script starts automatically. To disable auto-start, set this before loading the file:

```lua
MOSIE_NAVIGATOR_AUTO_START = false
```

Then start manually:

```lua
MosieNavigator:Start()
```

Assumptions:

- `Moose.lua` is already loaded.
- MOOSE zone APIs are available.
- Mission scripting is desanitized as needed by the mission workflow.
- `io` and `lfs` are available if navlog files should be written.

## Flight Plan Trigger Zones

Flight plans are discovered from trigger zone names.

Use this format:

```text
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>][__A<ALT_FT>][__T<TOT>][__S<GS_KT>]
```

Fields:

- `MN`: Mosie Navigator flight plan prefix.
- `PLAN`: plan identifier without underscores, for example `JERICHO` or `ESCORT`.
- `ORDER`: zero-padded waypoint order, for example `01`, `02`, `03`.
- `TYPE`: one of the supported waypoint types.
- `NAME`: optional human-readable waypoint name without spaces. If omitted, the waypoint type is used as the display name.
- `__A<ALT_FT>`: optional planned altitude in feet, for example `__A500` or `__A500FT`.
- `__T<TOT>`: planned time at that waypoint, using `HH:MM`, for example `__T14:30`. Mandatory on `TAKE_OFF`.
- `__S<GS_KT>`: optional speed override in knots. On `TAKE_OFF`, it overrides the default cruise speed for the whole plan.

If `TAKE_OFF` has no `__S`, the default cruise speed is 228 mph converted internally to 198.1 kt. `__S` tokens are always knots; individual waypoint `__S` tokens override only the leg arriving at that waypoint. Segments between `__T` anchors may derive speeds to satisfy timing constraints.

Example:

```text
MN_JERICHO_01_TAKE_OFF_Tangmere__T12:00
MN_JERICHO_02_NAV
MN_JERICHO_03_NAV_Checkpoint
MN_JERICHO_04_HOLD_Hold
MN_JERICHO_05_INGRESS_IP
MN_JERICHO_06_TARGET_Prison
MN_JERICHO_07_EGRESS_Egress
MN_JERICHO_08_LANDING_Tangmere
```

Example with planned altitude and time on target:

```text
MN_JERICHO_01_TAKE_OFF_Tangmere__A0__T14:00
MN_JERICHO_02_NAV_Channel__A500__T14:12
MN_JERICHO_05_INGRESS_IP__A50__T14:28
MN_JERICHO_06_TARGET_Prison__A50__T14:30
MN_JERICHO_08_LANDING_Tangmere__A0
```

Supported waypoint types:

- `TAKE_OFF`
- `LANDING`
- `INGRESS`
- `TARGET`
- `EGRESS`
- `NAV`
- `HOLD`

The initial point / IP concept should be represented as `INGRESS`.
`LAND` is also accepted and normalized to `LANDING`.

The first waypoint must be `TAKE_OFF`, and the last waypoint must be `LANDING`; otherwise the flight plan fails generation.

Fuel output includes a DCS-specific recommendation for the Mosquito internal fuel slider and drop tanks. It uses 3269 lb internal fuel, 7.215 lb/gal, and `NONE` / `2x50 GAL` / `2x100 GAL` drop tank options. Internal-only recommendations add a 1% buffer after rounding up, capped at 100%.

Route fuel burn is interpolated by IAS between Merlin 25 engine settings from the Mosquito manual. Internal profile codes are `CRZ`, `MCW`, `MCR`, `CLB`, or interpolated pairs such as `MCW-MCR`. IAS references are DCS-tested mph values converted internally to knots for calculation.

## Beacon Trigger Zones

Beacons are mission-wide and shared by all aircraft and flight plans.

Use this format:

```text
MNB_<ID>_<FREQUENCY>_<POWER_NM>_<ALT_FT>
```

Fields:

- `MNB`: Mosie Navigator beacon prefix.
- `ID`: stable unique beacon identifier within the mission, without underscores.
- `FREQUENCY`: display frequency, for example `310KHZ`.
- `POWER_NM`: nominal power/range, for example `120NM`.
- `ALT_FT`: beacon altitude, for example `200FT`.

Examples:

```text
MNB_TANGMERE_310KHZ_120NM_200FT
MNB_BAYEUX_315KHZ_90NM_180FT
```

Minimal format is allowed for future defaults:

```text
MNB_TANGMERE
```

## Coordinates

The future navigator script will read trigger zone coordinates directly from DCS/MOOSE. Manual latitude/longitude entry is not part of the primary workflow.

Trigger zone coordinates are expected to be converted to MOOSE coordinates with zone APIs, for example:

```lua
ZONE:New("MN_JERICHO_01_TAKE_OFF_Tangmere"):GetCoordinate()
```

## Out Of Scope For Trigger Zone Names

These settings must not be encoded in flight plan trigger zone names:

- report intervals
- message duration
- UI/menu settings
- realism mode
- scheduler settings
- runtime player state
- global navigator defaults

Those belong in the future navigator runtime implementation.
