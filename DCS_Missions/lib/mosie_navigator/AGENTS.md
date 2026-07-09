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

If both ends of a leg define `__T`, `MosieNavigator.lua` may calculate required leg TAS in knots. If either end has no `__T`, TAS for that leg must be omitted or displayed as `---`.

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

- Coordinates come from DCS Mission Editor trigger zone positions.
- Do not store lat/lon in files for the primary workflow.
- The future script should read coordinates with MOOSE zone APIs such as `ZONE:New(name):GetCoordinate()`.

## Debug Lua Contract

- `MosieNavigator.lua` may discover zones and draw F10 debug markup.
- `MosieNavigator.lua` may write plain text navlog files for discovered plans.
- `MosieNavigator.lua` may periodically refresh group menus for client aircraft that become active after mission start.
- It may depend on MOOSE being loaded before it.
- It must not require YAML files.
- It must not implement player navigation state until explicitly requested.
- It may implement minimal F10 debug menu actions explicitly requested by the user.

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
