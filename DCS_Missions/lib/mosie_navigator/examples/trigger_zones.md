# Trigger Zone Naming Examples

Mosie Navigator discovers flight plans and beacons from DCS Mission Editor trigger zones.

## Group Assignment

Add a plan tag to the DCS group name:

```text
MOSQUITO 1-1 [MN:JERICHO]
MOSQUITO 1-2 [MN:JERICHO]
SPITFIRE 2-1 [MN:ESCORT]
```

The tag value must match the plan name used in `MN_` trigger zones.

## Flight Plan Zones

Use this format:

```text
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>]
```

`PLAN` must not contain underscores. Use names like `JERICHO`, `ESCORT`, or `MOSSIE1`.
`NAME` is optional. If omitted, the waypoint type is used as the display name.

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
