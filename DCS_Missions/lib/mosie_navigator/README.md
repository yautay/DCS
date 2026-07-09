# Mosie Navigator

Mosie Navigator is a planned navigation assistant for DCS missions. This directory currently defines the data contract only: flight plans and mission beacons stored as YAML files.

No Lua runtime logic is implemented here yet.

## Goals

- Keep flight plans independent from a specific mission script.
- Allow one flight plan file per DCS client group.
- Keep mission-wide radio beacons in a separate shared file.
- Store only navigation data in YAML; runtime settings belong in the navigator script later.

## Directory Layout

```text
DCS_Missions/lib/mosie_navigator/
  README.md
  AGENTS.md
  examples/
    flight_plan.mosquito_1_1.yaml
    beacons.normandy.yaml
```

Mission-specific files can later live next to a mission, for example:

```text
DCS_Missions/DCS_Maps/Normandy/op_jericho/Nav/
  MOSQUITO_1_1.yaml
  MOSQUITO_1_2.yaml
  beacons.yaml
```

## Flight Plan Files

One flight plan YAML file describes one DCS client group.

Required top-level fields:

- `group`: DCS group name.
- `plan`: human-readable plan name.
- `waypoints`: ordered list of waypoints.

Each waypoint requires:

- `name`: human-readable waypoint name.
- `type`: one of the supported waypoint types.
- `lat`: latitude in decimal degrees.
- `lon`: longitude in decimal degrees.

Optional waypoint fields:

- `alt_ft`: planned altitude in feet.
- `notes`: short free-text note for humans.

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

## Beacon Files

Beacon YAML files are mission-wide. They are shared by all aircraft and flight plans in the mission.

Required beacon fields:

- `id`: stable unique beacon identifier within the mission.
- `name`: human-readable beacon name.
- `lat`: latitude in decimal degrees.
- `lon`: longitude in decimal degrees.

Optional beacon fields:

- `alt_ft`: beacon altitude in feet.
- `frequency`: display frequency, for example `310 kHz`.
- `power_nm`: nominal power/range in nautical miles.
- `notes`: short free-text note for humans.

## Coordinate Format

Coordinates use decimal degrees compatible with MOOSE:

```lua
COORDINATE:NewFromLLDD(lat, lon, altitude)
```

Altitude conversion is expected to happen in the future navigator script, for example:

```lua
UTILS.FeetToMeters(alt_ft)
```

## Out Of Scope For YAML

These settings must not be stored in flight plan YAML files:

- report intervals
- message duration
- UI/menu settings
- realism mode
- scheduler settings
- radio horizon logic
- per-player runtime state
- global navigator defaults

Those belong in the future navigator runtime implementation.
