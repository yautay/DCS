# Mosie Navigator Contract

This directory defines data files for the future Mosie Navigator tool. Follow this contract when editing or generating files here.

## Scope

- This directory currently contains documentation and YAML examples only.
- Do not add Lua runtime code unless explicitly requested.
- Do not add builder integration unless explicitly requested.
- Keep flight plan YAML minimal and data-only.

## Naming

- Use `mosie_navigator` as the directory name.
- Use `.yaml` for YAML files.
- Example flight plan names should use the pattern `flight_plan.<group>.yaml`.
- Example beacon names should use the pattern `beacons.<mission_or_map>.yaml`.

## Flight Plan YAML Contract

One flight plan file represents one DCS client group.

Required top-level fields:

- `group`: exact DCS group name.
- `plan`: human-readable plan name.
- `waypoints`: ordered list of waypoints.

No other top-level fields are required. Avoid adding runtime options to this file.

Required waypoint fields:

- `name`: human-readable waypoint name.
- `type`: waypoint type enum.
- `lat`: latitude in decimal degrees.
- `lon`: longitude in decimal degrees.

Optional waypoint fields:

- `alt_ft`: planned altitude in feet.
- `notes`: short human-readable note.

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

## Beacon YAML Contract

Beacon files are mission-wide and shared by all aircraft.

Required top-level field:

- `beacons`: ordered list of beacon definitions.

Required beacon fields:

- `id`: stable unique identifier within the mission.
- `name`: human-readable name.
- `lat`: latitude in decimal degrees.
- `lon`: longitude in decimal degrees.

Optional beacon fields:

- `alt_ft`: beacon altitude in feet.
- `frequency`: display frequency string.
- `power_nm`: nominal power/range in nautical miles.
- `notes`: short human-readable note.

Flight plan files must not define beacons. Beacon files must not assign beacons to groups.

## Coordinates

- Use decimal degrees for `lat` and `lon`.
- Coordinates must be compatible with MOOSE `COORDINATE:NewFromLLDD(lat, lon, altitude)`.
- Use negative longitude for west and negative latitude for south.
- Store altitude as `alt_ft` in feet when altitude is needed.

## Explicitly Forbidden In Flight Plan YAML

Do not add these to flight plan YAML files:

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
