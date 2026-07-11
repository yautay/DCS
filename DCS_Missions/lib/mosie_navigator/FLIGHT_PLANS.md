# Mosie Navigator — Flight Plan Authoring Guide

This guide is for **mission authors** who build flight plans in the DCS Mission Editor (ME).
It explains how to name trigger zones so that Mosie Navigator generates correct navlogs,
F10 menus, and CSV exports.

For the machine-readable contract (token grammar, CSV layout, forbidden encodings) see
[AGENTS.md](AGENTS.md).

---

## Table of Contents

1. [Overview](#1-overview)
2. [Quick Start](#2-quick-start)
3. [Trigger Zone Naming](#3-trigger-zone-naming)
   - 3.1 [Waypoint zones — `MN_`](#31-waypoint-zones--mn_)
   - 3.2 [Metadata tokens — `__A`, `__T`, `__S`](#32-metadata-tokens----a--t--s)
   - 3.3 [Beacon zones — `MNB_`](#33-beacon-zones--mnb_)
   - 3.4 [Group assignment — `[MN:<PLAN>]`](#34-group-assignment--mnplan)
4. [Waypoint Types](#4-waypoint-types)
5. [How the Plan Is Computed](#5-how-the-plan-is-computed)
   - 5.1 [Mandatory rules](#51-mandatory-rules)
   - 5.2 [Altitude cascade](#52-altitude-cascade)
   - 5.3 [Speed resolution](#53-speed-resolution)
   - 5.4 [HOLD duration](#54-hold-duration)
   - 5.5 [ETA = TOT](#55-eta--tot)
   - 5.6 [ROLEX offset](#56-rolex-offset)
   - 5.7 [Speed envelope and clamping](#57-speed-envelope-and-clamping)
6. [Mosquito FB Mk VI Engine Settings and Fuel](#6-mosquito-fb-mk-vi-engine-settings-and-fuel)
7. [Reading the Navlog](#7-reading-the-navlog)
8. [CSV Export](#8-csv-export)
9. [Common Patterns](#9-common-patterns)
10. [Worked Examples](#10-worked-examples)
11. [Troubleshooting](#11-troubleshooting)
12. [Token Reference](#12-token-reference)
13. [Warnings Glossary](#13-warnings-glossary)

---

## 1. Overview

Mosie Navigator reads **DCS trigger zone names** as structured data. There is no YAML file,
no external tool, no script to edit. You place zones on the map, give them the right names,
assign groups, and the Lua script does the rest.

What you get per group:

- **F10 menu** — "Show FP", "Navigator On/Off", "Status Now", "Next/Prev WP"
- **In-game message** — navlog (ALT, IAS, TAS, COG, HDG, VAR, SOG, distance, time, ETA) when you click "Show FP"
- **Text navlog file** — written to the DCS `Logs/` folder at mission start
- **CSV export** — one route declaration file per plan, one mission-wide beacons file

---

## 2. Quick Start

Minimal viable plan (4 zones, one group):

```text
MN_ALPHA_01_TAKE_OFF_Base__T12:00__S180__A500
MN_ALPHA_02_NAV
MN_ALPHA_03_TARGET_Objective
MN_ALPHA_04_LANDING_Base
```

Group name in ME:

```text
MOSQUITO 1-1 [MN:ALPHA]
```

That is all. The script will:
- Propagate 180 kt GS and 500 ft altitude to all waypoints that lack their own `__S`/`__A`.
- Compute ETAs from the 12:00 brake release.
- Interpolate each leg's fuel burn from Mosquito Merlin 25 engine settings.
- Write a navlog and a route declaration CSV to `Logs/`.

---

## 3. Trigger Zone Naming

### 3.1 Waypoint zones — `MN_`

```text
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>][__A<ALT_FT>][__T<HH:MM[:SS]>][__S<GS_KT>]
```

| Part | Required | Notes |
|---|---|---|
| `MN` | yes | literal prefix |
| `PLAN` | yes | plan id, no underscores, e.g. `JERICHO` |
| `ORDER` | yes | integer, determines sort order, e.g. `01`, `02` |
| `TYPE` | yes | see §4 |
| `NAME` | no | human-readable label, underscores become spaces in display |
| `__A<ft>` | no | altitude in feet, e.g. `__A500` or `__A500FT` |
| `__T<time>` | mandatory on TAKE_OFF | ETA/TOT, e.g. `__T12:00` or `__T12:00:30` |
| `__S<kt>` | recommended on TAKE_OFF | ground speed in knots, e.g. `__S180` |

Metadata tokens after the first `__` may appear in any order.

### 3.2 Metadata tokens — `__A`, `__T`, `__S`

**`__A<ft>`** — planned altitude in feet for the leg arriving at this waypoint.
- `__A500`, `__A500FT` are both valid.
- On `TAKE_OFF`: sets the **default altitude for the whole plan** (propagates forward).
- Inherits from previous WP when omitted; inherited values are shown with `*` in the navlog.

**`__T<HH:MM[:SS]>`** — planned ETA at this waypoint (local mission time, 24-hour clock).
- `__T14:30`, `__T14:30:15` are both valid.
- On `TAKE_OFF`: **brake release time** — mandatory.
- On other waypoints: timing constraint used by the speed/HOLD algorithm (see §5).
- There is no separate "TOT vs ETA" distinction; `__T` means both.

**`__S<kt>`** — planned ground speed (no-wind TAS at MSL) in knots for the leg **arriving at** this waypoint.
- `__S180`, `__S180KT` are both valid.
- On `TAKE_OFF`: overrides the **default cruise GS for the whole plan** (propagates forward).
- On later waypoints: overrides the default for that specific leg only, then reverts.
- See §5.3 for interaction with `__T` constraints.

### 3.3 Beacon zones — `MNB_`

```text
MNB_<ID>[_<FREQUENCY>_<POWER_NM>NM_<ALT_FT>FT]
```

Examples:

```text
MNB_TANGMERE_310KHZ_120NM_200FT
MNB_BAYEUX_315KHZ_90NM_180FT
MNB_ALPHA                          (minimal form — defaults used)
```

Beacons are drawn on the F10 map and exported to `MosieNavigator_Beacons.csv`.

### 3.4 Group assignment — `[MN:<PLAN>]`

Add the tag anywhere in the DCS group name:

```text
MOSQUITO 1-1 [MN:JERICHO]
MOSQUITO 1-2 [MN:JERICHO]__R0:05
```

`PLAN` must match a plan identifier in your `MN_` zones.

`__R<offset>` (ROLEX) shifts all ETAs for that group only. Formats: `__R5` (5 min),
`__R0:05` (5 min), `__R0:00:30` (30 sec). Use this for staggered attacks.

---

## 4. Waypoint Types

| Type | Meaning |
|---|---|
| `TAKE_OFF` | Departure point. **Must be ORDER 1. Must have `__T`.**  |
| `NAV` | Generic navigation waypoint. |
| `INGRESS` | Initial Point (IP) — entry to the target area. |
| `TARGET` | Strike/attack point. |
| `EGRESS` | Exit from the target area. |
| `HOLD` | Orbit point — absorbs timing slack (see §5.4). |
| `LANDING` | Destination. Usually last in order. |

`LAND` is accepted as a Mission Editor alias and is normalized to `LANDING`.

---

## 5. How the Plan Is Computed

### 5.1 Mandatory rules

1. The first waypoint **must** be `TAKE_OFF`.
2. `TAKE_OFF` **must** have `__T` (brake release time). Without it, no navlog is generated.
3. The last waypoint **must** be `LANDING`.
4. If `TAKE_OFF` has no `__S`, the plan default cruise speed is 228 mph converted internally to 198.1 kt. `__S` tokens are always knots; individual waypoint `__S` tokens still override the arriving leg.

### 5.2 Altitude cascade

`__A` on `TAKE_OFF` → default altitude for the whole plan. Each waypoint without its own
`__A` inherits the previous waypoint's resolved altitude.

```
01 TAKE_OFF  __A5000   → resolved 5000 ft
02 NAV                 → resolved 5000 ft  (inherited, shown as 5000*)
03 INGRESS   __A50     → resolved 50 ft
04 TARGET              → resolved 50 ft    (inherited, shown as 50*)
05 EGRESS              → resolved 50 ft    (inherited)
06 LANDING   __A200    → resolved 200 ft
```

If no `__A` is anywhere in the plan, all waypoints default to 0 ft MSL (IAS ≈ TAS) and a
warning is emitted.

Inherited speeds in the text navlog are marked with `*`, matching inherited altitude notation.

### 5.3 Speed resolution

Each leg is classified as either **FIXED** (the arriving WP has an explicit `__S`) or
**FREE** (no explicit `__S`).

The algorithm identifies **`__T` anchors** (waypoints with `__T`) and processes segments
between consecutive anchors:

**Segment with no HOLD inside:**

| Leg classification | Result |
|---|---|
| All FREE | Uniform derived GS = total dist ÷ Δtime. No warning. |
| Mixed (some FIXED, some FREE) | FIXED legs use their `__S` GS; FREE legs share remaining time (averaged). |
| All FIXED | `__T` wins — uniform derived GS applied to all legs; all `__S` values ignored (warning emitted). |

**Segment containing a HOLD, or legs after the last anchor:**

Each leg uses its own `__S` or the plan default GS. The HOLD absorbs timing slack (see §5.4).

**Default GS.** Comes from `__S` on `TAKE_OFF` in knots, or from the Mosquito default cruise speed of 228 mph (198.1 kt) when `TAKE_OFF __S` is absent. It propagates forward until overridden by a later `__S` (which applies to that one leg only).

### 5.4 HOLD duration

A HOLD waypoint pauses the flight for some duration before the next leg. Duration is
determined as follows:

| Situation | Duration |
|---|---|
| HOLD has `__T` | `__T` = **arrival** time; duration computed from next downstream `__T`. |
| HOLD has no `__T` — last HOLD before a downstream `__T` | Absorbs all remaining slack so the downstream `__T` is met. |
| HOLD has no `__T` — not the last before a downstream `__T` | Duration = 0; warning emitted. |
| HOLD has no `__T` — no downstream `__T` at all | Duration = 0; warning emitted. |

The HOLD's arrival ETA is shown in the navlog row. The orbit fuel and exit time appear on
a sub-line below the row.

### 5.5 ETA = TOT

There is no distinction between ETA and TOT. `__T` is simply the planned time at that
waypoint. The navlog shows `ETA` for all waypoints uniformly.

### 5.6 ROLEX offset

A group's `__R` value shifts the T0 (TAKE_OFF `__T`) and all downstream ETAs by the same
amount. It does not affect speed calculations — the whole plan is shifted uniformly.

### 5.7 Speed envelope and clamping

All speed calculations are converted to IAS (knots) at the leg altitude and checked against
the Mosquito envelope (`minIasKt` / `maxIasKt`). If a derived or declared speed falls outside
the envelope, it is clamped to the nearest bound and a warning is emitted. The `__T`
constraint may not be met when clamping occurs.

---

## 6. Mosquito FB Mk VI Engine Settings and Fuel

The fuel estimate uses Merlin 25 engine settings defined in `MosieNavigator.Aircraft`.
Manual fuel values are per engine; Mosie Navigator stores total aircraft burn for both engines.

| PROF | Setting | RPM | Mixture | Boost | Burn / engine | Aircraft burn | Route IAS ref |
|---|---|---:|---|---:|---:|---:|---:|
| — | `takeoff_emergency_18` | 3000 | Rich | +18 | — | — | — |
| — | `takeoff_12` | 3000 | Rich | +12 | 115 | 230 | — |
| `CLB` | `max_climb` | 2850 | Rich | +9 | 95 | 190 | 240 mph / 208.6 kt |
| `MCR` | `max_cont_rich` | 2650 | Rich | +7 | 80 | 160 | 237 mph / 205.9 kt |
| `MCW` | `max_cont_weak` | 2650 | Weak | +7 | 63 | 126 | 228 mph / 198.1 kt |
| `CRZ` | `cruise_weak` | 2300 | Weak | +2 | 42 | 84 | 192 mph / 166.8 kt |

Route fuel burn is linearly interpolated by computed IAS between the route IAS reference
points. Values below the lowest point use `cruise_weak`; values above the highest point use
`max_climb`. The IAS reference points are DCS-tested mph measurements converted internally to
knots. `max_climb` is set to 240 mph to keep the interpolation curve monotonic when measured
2650/+7 rich and 2850/+9 rich speeds overlap.

Interpolated `PROF` values use two enum codes, for example `CRZ-MCW`, `MCW-MCR`, or `MCR-CLB`.

Fuel components in the summary:

| Component | Value |
|---|---|
| TAXI | 15 IMP GAL (start, warm-up, taxi) |
| ROUTE | sum of all leg burns |
| HOLD orbit | `holdBurnImpGph × duration` (84 gph) |
| RESERVE | 30 min at lowest route burn (84 gph → 42.0 gal) |
| LANDING | 5 IMP GAL |
| DCS FUEL | recommended DCS internal fuel slider and drop tank fit |

The DCS fuel recommendation uses 3269 lb internal fuel and 7.215 lb/gal (200 gal = 1443 lb). Internal-only recommendations are rounded up to the next full percent with an added 1% buffer, capped at 100%. If the plan exceeds internal fuel, Mosie Navigator recommends `2x50 GAL` or `2x100 GAL` drop tanks. The displayed `DCS FUEL` section intentionally shows only `REQUIRED`, `INTERNAL`, and `DROP`; capacity and margin are kept internal for warnings. A warning is emitted if TOTAL exceeds internal fuel plus `2x100 GAL`.

---

## 7. Reading the Navlog

Column meanings in the text navlog:

| Column | Meaning |
|---|---|
| ID | Waypoint order number |
| TYPE | Waypoint type |
| ALT | Resolved altitude in feet. `*` = inherited from previous WP. |
| IAS(MPH) | Wind-corrected indicated airspeed of the incoming leg in mph. `*` = inherited/default speed. |
| TAS(KN) | Wind-corrected true airspeed of the incoming leg in knots. |
| COG | Course over ground of the incoming leg, true degrees. |
| WHDG | Wind heading correction in degrees, signed so `COG + WHDG = HDG(T)`. |
| WTAS | Wind TAS correction in knots, signed so `SOG + WTAS = TAS(KN)`. |
| HDG(T) | Wind-corrected true heading. |
| VAR | Magnetic variation, signed so `HDG(T) + VAR = HDG(M)`. |
| HDG(M) | Wind-corrected magnetic heading. |
| SOG | Speed over ground of the incoming leg in knots. |
| DIST | Distance of the incoming leg in NM. |
| TIME | Leg time in whole minutes. |
| ETA | Computed arrival time (includes ROLEX), rounded to whole minutes. |

**TAKE_OFF row:** Incoming-leg fields are `---` (no incoming leg).

**HOLD row:** Shows the incoming leg data. Below the row an **orbit sub-line** shows orbit
duration, IAS, orbit fuel, and exit time.

Example orbit sub-line:
```
   orbit 9 min @ 140 IAS: 9.8 gal  (exit 12:24)
```

At the end of the navlog:
- **TOTAL_DIST** — total route distance in NM.
- **FUEL summary** — see §6.
- **WARNINGS** — any clamping, missing data, or HOLD issues.

---

## 8. CSV Export

Filenames written to `Logs/` (or `Config.flightPlanOutputDirectory`):

```
MosieNavigator_<PLAN>.csv             (one per plan)
MosieNavigator_Beacons.csv            (mission-wide beacons)
```

Flight plan CSV header row:

```
ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT
```

- `ALT_FT` — declared `__A` value; empty when the waypoint has no `__A` token.
- `TOT` — declared `__T` value in `HH:MM`; empty when the waypoint has no `__T` token.
- `SPEED_KT` — declared `__S` value; empty when the waypoint has no `__S` token.

The flight plan CSV is a Mission Editor declaration export. It does not include inherited/default/computed values and does not apply group ROLEX offsets. Future waypoint tokens should follow the same rule: CSV columns are populated only from explicitly declared trigger-zone data.

Toggle CSV output independently: `MosieNavigator.Config.generateCsvFiles = false`.

---

## 9. Common Patterns

### "Just fly there" (no timing constraints)

Set `__T` and `__S` on TAKE_OFF. Leave all other waypoints bare. The plan propagates the
default GS and altitude, computes ETAs, and estimates fuel. No constraints to miss.

```text
MN_ALPHA_01_TAKE_OFF__T12:00__S180__A500
MN_ALPHA_02_NAV
MN_ALPHA_03_TARGET
MN_ALPHA_04_LANDING
```

### "Time on Target" strike

Add `__T` on TARGET. The algorithm derives the required GS to hit the time. If the whole
segment has uniform speed requirements, no `__S` override is needed on intermediate WPs.

```text
MN_ALPHA_01_TAKE_OFF__T12:00__S180__A5000
MN_ALPHA_02_NAV
MN_ALPHA_03_INGRESS__A50
MN_ALPHA_04_TARGET__A50__T14:30
MN_ALPHA_05_LANDING
```

### "Navigation checkpoint, then strike with TOT"

Use a HOLD at the RV point to absorb timing slack:

```text
MN_ALPHA_01_TAKE_OFF__T12:00__S180__A5000
MN_ALPHA_02_NAV_RV
MN_ALPHA_03_HOLD_Wait           ← no __T; absorbs slack to hit TARGET TOT
MN_ALPHA_04_INGRESS__A50
MN_ALPHA_05_TARGET__A50__T14:30
MN_ALPHA_06_LANDING
```

### "Multiple bombers, staggered ROLEX"

Same plan, different ROLEX per group:

```text
MOSQUITO 1-1 [MN:JERICHO]
MOSQUITO 1-2 [MN:JERICHO]__R0:05
MOSQUITO 1-3 [MN:JERICHO]__R0:10
```

All three use the same zones. ETAs shift by 5-minute intervals.

### "Low-level ingress with high-speed attack run"

Use `__S` override on the INGRESS leg only; rest of plan uses default cruise:

```text
MN_ALPHA_01_TAKE_OFF__T12:00__S180__A5000
MN_ALPHA_02_NAV
MN_ALPHA_03_INGRESS__A50__S220    ← fast last 20 NM
MN_ALPHA_04_TARGET__A50__T14:30
MN_ALPHA_05_EGRESS
MN_ALPHA_06_LANDING
```

---

## 10. Worked Examples

These eight examples correspond to the design test cases in `MosieNavigator.spec.lua`.
All use 500 ft altitude at MSL unless noted. At 500 ft, IAS ≈ GS.

---

### Example 1 — BASIC (no constraints)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 NAV       (20 NM from 01)
03 NAV       (30 NM from 02)
04 TARGET    (25 NM from 03)
05 LANDING   (45 NM from 04)
```

**Algorithm:** No intermediate `__T`. All legs use default 200 kt GS.

**Result:**
```
ID TYPE        ALT IAS(MPH) TAS(KN) COG WHDG WTAS HDG(T) VAR  HDG(M) SOG DIST TIME ETA
01 TAKE_OFF    500      ---     --- ---  ---  ---    --- ---     --- ---  ---  --- 12:00
02 NAV        500*      229     200 090  +00  +00    090 -0.0    090 200 20.0    6 12:06
03 NAV        500*      229     200 090  +00  +00    090 -0.0    090 200 30.0    9 12:15
04 TARGET     500*      229     200 090  +00  +00    090 -0.0    090 200 25.0    8 12:22
05 LANDING    500*      229     200 270  +00  +00    270 -0.0    270 200 45.0   14 12:36

FUEL:  TAXI 15.0  ROUTE ...  RESERVE 42.0  LANDING 5.0  TOTAL ...
DCS FUEL: recommended internal slider percent and drop tanks
```

---

### Example 2 — MID_TOT (constraint-derived speed)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 NAV       (20 NM)
03 NAV       (30 NM)
04 TARGET    __T12:20  (25 NM)
05 LANDING   (45 NM)
```

**Algorithm:** Segment [01..04] is 75 NM in 20 min → derived GS = 225 kt. All legs in
segment use 225 kt (all FREE). Post-constraint leg 04→05 reverts to default 200 kt.

**Result:** TARGET ETA = 12:20. Post-TARGET leg at 200 kt.

---

### Example 3 — HOLD_ANCHOR (`__T` on HOLD = arrival)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 NAV       (30 NM)
03 HOLD      __T12:15  (20 NM from 02)   ← arrival 12:15
04 NAV       (15 NM)
05 TARGET    __T12:30  (5 NM from 04)
06 LANDING   (50 NM)
```

**Algorithm:** HOLD ETA = 12:15. Downstream TARGET = 12:30. Flight HOLD→TARGET: 20/200 = 6 min.
HOLD duration = 30 - 15 - 6 = 9 min.

**Orbit sub-line:**
```
   orbit 9 min @ 140 IAS: 9.8 gal  (exit 12:24)
```

---

### Example 4 — HOLD_ABSORB (no `__T` on HOLD, absorbs slack)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 NAV       (30 NM)
03 HOLD      (20 NM)       ← no __T
04 TARGET    __T12:30  (20 NM)
05 LANDING
```

**Algorithm:** Flight to HOLD = 25 min → ETA at HOLD = 12:25. No `__T`, last HOLD before
TARGET. Flight HOLD→TARGET = 6 min. Slack = 30 - 25 - 6 = wait... let's recompute:
- 30 NM + 20 NM to HOLD = 50 NM / 200 kt = 15 min → ETA 12:15
- 12:30 (TARGET) - 12:15 (HOLD arrival) - 6 min (HOLD→TARGET) = 9 min orbit.

TARGET ETA = 12:30. No warnings.

---

### Example 5 — MIXED_S (FIXED honored, FREE averaged)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 NAV       (20 NM)        ← FREE
03 INGRESS   __S220 __A200  (10 NM)  ← FIXED
04 TARGET    __A200 __T12:15 (20 NM) ← FREE
05 LANDING
```

**Algorithm:** Segment [01..04] 50 NM in 15 min.
- FIXED leg →03: 10 NM at 220 kt TAS ≈ 2.73 min.
- FREE legs →02 and →04: 40 NM in remaining 12.27 min → ~196 kt GS.

**Result:** INGRESS leg at 220 kt, others at ~196 kt. TARGET ETA = 12:15.

---

### Example 6 — ALL_S_OVERRIDDEN (`__T` wins over all `__S`)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 NAV       __S180  (20 NM)   ← FIXED
03 INGRESS   __S220 __A200 (10 NM)  ← FIXED
04 TARGET    __S200 __A200 __T12:15 (20 NM)  ← FIXED
05 LANDING
```

**Algorithm:** All three legs in segment [01..04] are FIXED. Because all are FIXED,
`__T` wins: uniform derived GS = 50 NM / 15 min ≈ 200 kt applied to all. Warning emitted.

**Warning:** `segment [WP01..WP04] all-FIXED override ... __S ignored`

---

### Example 7 — MULTI_HOLD (last HOLD absorbs, earlier ones = 0)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 HOLD      (15 NM)    ← H1, no __T
03 NAV       (20 NM)
04 HOLD      (25 NM)    ← H2, no __T
05 TARGET    __T12:35  (10 NM)
06 LANDING   (50 NM)
```

**Algorithm:**
- H1: not the last HOLD before TARGET → duration 0, warning.
- H2: last HOLD before TARGET → absorbs slack.
- Flight times (no HOLD): 15+20+25+10 = 70 NM / 200 kt = 21 min → slack = 35 - 21 = 14 min.
- H2 duration = 14 min. TARGET ETA = 12:35.

**Warning for H1:** `WP02 HOLD (HOLD): no __T and not last HOLD before WP05 constraint — duration 0`

---

### Example 8 — ENVELOPE_CLAMP (constraint impossible at any safe speed)

**Zones:**
```
01 TAKE_OFF  __T12:00 __S200 __A500
02 NAV       (15 NM)
03 TARGET    __T12:03  (10 NM from 02)
04 LANDING   (50 NM)
```

**Algorithm:** Segment [01..03] = 25 NM in 3 min → required GS ≈ 500 kt → IAS ≈ 498 kt.
Envelope max = 245 mph / 212.9 kt IAS → clamped to 212.9 kt IAS. TARGET `__T12:03` will not be met (actual
ETA ~12:05:46).

**Warning:** `segment [WP01..WP03]: required 498 IAS above maximum 213 IAS — clamped`

---

## 11. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| "Plan doesn't generate" / `ERROR: TAKE_OFF must have __T` | No `__T` on zone 01 | Add `__T12:00` (or actual time) to the TAKE_OFF zone name |
| GS / IAS shows `---` | TAKE_OFF row (no incoming leg) — this is correct | Expected behaviour |
| `HOLD duration 0` + warning | HOLD has no `__T` and is not the last HOLD before a downstream `__T` | Add `__T` on HOLD (arrival time) or add `__T` on a later WP |
| TARGET `__T` not met + clamp warning | Required speed outside Mosquito envelope | Increase time between anchor waypoints, or shorten route |
| All `__S` ignored + warning | All legs in a constrained segment are FIXED | Remove `__S` from intermediate WPs, or remove the downstream `__T` |
| Altitude shows `0*` everywhere | No `__A` on any zone | Add `__A<ft>` to TAKE_OFF |
| Wrong ETA | Group has ROLEX that shifts everything | Check `__R` suffix in the DCS group name |
| CSV missing `SPEED_KT` | Old format (pre-v2) | Re-export; new format always includes `SPEED_KT` column |

---

## 12. Token Reference

| Token | Location | Format | Meaning |
|---|---|---|---|
| `MN` | Zone prefix | literal | Marks a waypoint zone |
| `PLAN` | Zone position 2 | alphanumeric, no `_` | Plan identifier |
| `ORDER` | Zone position 3 | integer | Sort order within plan |
| `TYPE` | Zone position 4 | enum | Waypoint type (see §4) |
| `NAME` | Zone position 5+ | words joined by `_` | Display name |
| `__A<ft>` | After `__` | `__A500`, `__A500FT` | Altitude in feet |
| `__T<time>` | After `__` | `__T12:00`, `__T12:00:30` | ETA/TOT |
| `__S<kt>` | After `__` | `__S180`, `__S180KT` | Ground speed in knots |
| `MNB` | Zone prefix | literal | Marks a beacon zone |
| `[MN:PLAN]` | Group name | `[MN:JERICHO]` | Assigns group to plan |
| `__R<offset>` | Group name | `__R5`, `__R0:05`, `__R0:00:30` | ROLEX delay in min / H:MM / H:MM:SS |

**Zone → navlog column mapping:**

| Token | Navlog column |
|---|---|
| `ORDER` | ID |
| `TYPE` | TYPE |
| `__A` (resolved) | ALT |
| Algorithm | ETA |
| Algorithm (leg direction) | COG, WHDG, WTAS, HDG(T), VAR, HDG(M) |
| Algorithm (leg distance/time) | DIST, TIME |
| Algorithm (leg speed) | IAS(MPH), TAS(KN), SOG |

---

## 13. Warnings Glossary

| Warning text (partial) | Meaning |
|---|---|
| `TAKE_OFF must have __T` | Hard error — no T0 defined |
| `no __A defined anywhere` | All altitudes default to 0 ft MSL; IAS ≈ TAS |
| `all-FIXED segment … __S ignored` | All legs in a `__T`–`__T` segment have `__S`; `__T` overrides all |
| `required … IAS above/below … IAS — clamped` | Speed constraint outside envelope; plan continues with clamped value |
| `FIXED __S legs consume entire time budget` | `__S` on FIXED legs leaves no time for FREE legs |
| `HOLD … duration 0 … not last HOLD` | HOLD without `__T` that is not last before downstream `__T` |
| `HOLD … no downstream __T` | HOLD with neither own `__T` nor downstream `__T`; orbit = 0 |
| `HOLD … duration negative` | HOLD arrival ETA is later than downstream `__T` minus flight time |
| `FUEL: required … exceeds DCS max fuel` | Route + reserve + allowances exceed internal fuel plus `2x100 GAL` drop tanks |
