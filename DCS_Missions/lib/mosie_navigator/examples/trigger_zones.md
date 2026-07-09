# Trigger Zone Naming Examples

Mosie Navigator discovers flight plans and beacons from DCS Mission Editor trigger zones.

## Group Assignment

Add a plan tag to the DCS group name:

```text
MOSQUITO 1-1 [MN:JERICHO]
MOSQUITO 1-2 [MN:JERICHO]__R0:05
MOSQUITO 1-3 [MN:JERICHO]__R0:00:30
SPITFIRE 2-1 [MN:ESCORT]
```

The tag value must match the plan name used in `MN_` trigger zones.
The optional `__R...` group suffix applies a ROLEX delay to that group's displayed/exported TOT values only.

Assigned groups receive a Mosie Navigator F10 menu with `Show FP`, active navigator controls, and report interval selection.

## Flight Plan Zones

Use this format:

```text
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>][__A<ALT_FT>][__T<TOT>]
```

`PLAN` must not contain underscores. Use names like `JERICHO`, `ESCORT`, or `MOSSIE1`.
`NAME` is optional. If omitted, the waypoint type is used as the display name.
`__A<ALT_FT>` and `__T<TOT>` are optional. If two adjacent waypoints both define `__T`, Mosie Navigator calculates the required leg TAS in knots.

Example Operation Jericho plan:

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

Example escort plan:

```text
MN_ESCORT_01_TAKE_OFF_Tangmere
MN_ESCORT_02_RENDEZVOUS_Rendezvous
MN_ESCORT_03_NAV_CoverNorth
MN_ESCORT_04_EGRESS_Return
MN_ESCORT_05_LANDING_Tangmere
```

## Beacon Zones

Use this format:

```text
MNB_<ID>_<FREQUENCY>_<POWER_NM>_<ALT_FT>
```

`ID` must not contain underscores. Use names like `TANGMERE`, `BAYEUX`, or `DOVER`.

Examples:

```text
MNB_TANGMERE_310KHZ_120NM_200FT
MNB_BAYEUX_315KHZ_90NM_180FT
MNB_DOVER_305KHZ_100NM_250FT
```

Minimal beacon format is also allowed when the future script can apply defaults:

```text
MNB_TANGMERE
```
