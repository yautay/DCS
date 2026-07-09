# Mosie Navigator

Mosie Navigator is a planned navigation assistant for DCS missions. This directory currently defines the data contract only: flight plans and mission beacons discovered from DCS Mission Editor trigger zones.

Only the initial F10 debug drawing logic is implemented here. Player navigation, menus, reports, and radio simulation are not implemented yet.

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

`__R...` is an optional group ROLEX offset. It shifts all displayed and exported TOT values for that group only. Examples:

- `__R5`: delay all TOT values by 5 minutes.
- `__R0:05`: delay all TOT values by 5 minutes.
- `__R0:00:30`: delay all TOT values by 30 seconds.

ROLEX does not change calculated TAS, because every waypoint TOT in that group is shifted by the same amount.

For independent player state later, prefer one client aircraft per DCS group.

## Debug Script

`MosieNavigator.lua` is the first debug implementation. When loaded after MOOSE, it discovers `MN_` and `MNB_` trigger zones and draws them on the F10 map.

For every group assigned with `[MN:<PLAN>]`, it creates a group F10 menu:

```text
F10 Other > Mosie Navigator > Show FP
```

`Show FP` displays a simplified flight plan for that group.

The same menu also provides an active text navigator:

```text
Navigator On
Navigator Off
Status Now
Next WP
Prev WP
Report Interval > 30 sec / 60 sec / 120 sec / 300 sec
```

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
- latitude in decimal minutes format, for example `N51 19.43`
- longitude in decimal minutes format, for example `E000 01.60`
- true course from the waypoint to the next waypoint
- magnetic course from the waypoint to the next waypoint
- cumulative distance from start in NM
- leg distance from previous waypoint in NM
- planned altitude, if defined with `__A`
- planned TOT, if defined with `__T`
- calculated leg TAS in knots, if both ends of the leg define `__T`
- calculated leg IAS in knots, if both ends of the leg define `__T` and the row waypoint defines `__A`

Static FP/navlog magnetic course is declination-corrected but does not include wind correction. Wind-corrected magnetic heading is used by active navigator guidance.

For assigned groups with `__R...`, `Show FP` and the generated group navlog show ROLEX-adjusted TOT values.

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
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>][__A<ALT_FT>][__T<TOT>]
```

Fields:

- `MN`: Mosie Navigator flight plan prefix.
- `PLAN`: plan identifier without underscores, for example `JERICHO` or `ESCORT`.
- `ORDER`: zero-padded waypoint order, for example `01`, `02`, `03`.
- `TYPE`: one of the supported waypoint types.
- `NAME`: optional human-readable waypoint name without spaces. If omitted, the waypoint type is used as the display name.
- `__A<ALT_FT>`: optional planned altitude in feet, for example `__A500` or `__A500FT`.
- `__T<TOT>`: optional planned time on target for that waypoint, using `HH:MM` or `HH:MM:SS`, for example `__T14:30`.

If both ends of a leg have `__T`, Mosie Navigator calculates the required leg TAS in knots from leg distance and elapsed planned time. If either waypoint has no `__T`, TAS for that leg is shown as `---`.

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
- `RENDEZVOUS`
- `INGRESS`
- `TARGET`
- `EGRESS`
- `NAV`
- `HOLD`

The initial point / IP concept should be represented as `INGRESS`.

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
