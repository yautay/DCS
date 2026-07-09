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
<GROUP NAME> [MN:<PLAN>]
```

Examples:

```text
MOSQUITO 1-1 [MN:JERICHO]
MOSQUITO 1-2 [MN:JERICHO]
SPITFIRE 2-1 [MN:ESCORT]
```

`PLAN` must match the plan identifier from trigger zones, for example `MN_JERICHO_01_TAKE_OFF_Tangmere` uses plan `JERICHO`.

For independent player state later, prefer one client aircraft per DCS group.

## Debug Script

`MosieNavigator.lua` is the first debug implementation. When loaded after MOOSE, it discovers `MN_` and `MNB_` trigger zones and draws them on the F10 map.

For every group assigned with `[MN:<PLAN>]`, it creates a group F10 menu:

```text
F10 Other > Mosie Navigator > Show FP
```

`Show FP` displays a simplified flight plan for that group.

It also writes one text navlog per assigned group. If no group assignments are found, it writes one fallback debug navlog per discovered plan. By default files are written to:

```text
<Saved Games DCS>/Logs/MosieNavigator_<GROUP>_<PLAN>.txt
```

The navlog is a plain ASCII table with:

- waypoint number
- latitude
- longitude
- true course from the waypoint to the next waypoint
- cumulative distance from start in NM
- leg distance from previous waypoint in NM

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
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>]
```

Fields:

- `MN`: Mosie Navigator flight plan prefix.
- `PLAN`: plan identifier without underscores, for example `JERICHO` or `ESCORT`.
- `ORDER`: zero-padded waypoint order, for example `01`, `02`, `03`.
- `TYPE`: one of the supported waypoint types.
- `NAME`: optional human-readable waypoint name without spaces. If omitted, the waypoint type is used as the display name.

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
