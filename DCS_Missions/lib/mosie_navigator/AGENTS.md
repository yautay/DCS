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

`__R...` is an optional group ROLEX delay that shifts all displayed/exported TOT values for that group only. Accepted formats:

- `__R<M>` — plain minutes, any non-negative integer (e.g. `__R5`, `__R120`).
- `__R<H:MM>` — hours and minutes, `MM` must be `00..59` (e.g. `__R0:05`, `__R2:30`).
- `__R<H:MM:SS>` — hours, minutes, seconds; `MM` and `SS` must be `00..59` (e.g. `__R0:00:30`).

It must not change calculated TAS because the whole plan is shifted by the same amount.

## Flight Plan Trigger Zone Contract

Flight plans are discovered from trigger zone names.

Required format:

```text
MN_<PLAN>_<ORDER>_<TYPE>[_<NAME>][__A<ALT_FT>][__T<HH:MM[:SS]>][__S<GS_KT>]
```

Fields:

- `MN`: literal prefix.
- `PLAN`: plan identifier without underscores.
- `ORDER`: zero-padded waypoint order.
- `TYPE`: waypoint type enum.
- `NAME`: optional human-readable waypoint name without spaces. If omitted, the waypoint type is used as the display name.
- `__A<ALT_FT>`: optional planned altitude in feet, for example `__A500` or `__A500FT`. On `TAKE_OFF` this sets the default cruise altitude for the whole plan; individual waypoints may override it.
- `__T<HH:MM[:SS]>`: planned time (ETA) at this waypoint, for example `__T14:30` or `__T14:30:15`. **Mandatory on `TAKE_OFF`** (brake release time). On other waypoints it acts as a timing constraint for the flight plan algorithm (see Flight Plan Semantics).
- `__S<GS_KT>`: planned ground speed (no-wind TAS at MSL) in knots for the leg **arriving at** this waypoint, for example `__S180`. On `TAKE_OFF` this sets the default cruise GS for the whole plan.

Only the suffixes `__A` and `__T` and `__S` are recognised. The legacy aliases `__ALT`, `__TOT` are **not** supported and will be logged as unknown tokens and ignored.

A `TAKE_OFF` waypoint **must** have `__T`. A plan without `__T` on `TAKE_OFF` will not generate a flight plan. A plan without `__S` on `TAKE_OFF` and without any downstream `__T` pair to derive speed from will also fail to generate.

Example:

```text
MN_JERICHO_01_TAKE_OFF_Tangmere__T12:00__S180__A500
MN_JERICHO_02_NAV
MN_JERICHO_03_RENDEZVOUS_Rendezvous
MN_JERICHO_04_HOLD_Hold
MN_JERICHO_05_INGRESS_IP__A50__S200
MN_JERICHO_06_TARGET_Prison__A50__T14:30
MN_JERICHO_07_EGRESS_Egress
MN_JERICHO_08_LANDING_Tangmere__A200
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

## Flight Plan Semantics

For prose, examples, and a worked tutorial see **[FLIGHT_PLANS.md](FLIGHT_PLANS.md)**.

The flight plan algorithm (`_ComputePlan`) runs on every navlog / F10 / CSV generation.

**Altitude cascade.** `__A` on `TAKE_OFF` is the default cruise altitude. Each waypoint without its own `__A` inherits the previous waypoint's resolved altitude. Inherited values are marked with `*` in the navlog.

**Speed resolution (per leg).** Each leg is classified relative to `__T` anchors:

1. Segment with a HOLD anywhere in it (HOLD at `segStart`, in the interior, or at `segEnd`): each leg uses its `__S` override or the plan default GS. The HOLD absorbs any slack — legs are **not** re-derived from the time budget.
2. Segment between two `__T` anchors with **no HOLD** at any position:
   - If all legs are FIXED (`__S` declared): `__T` wins — uniform derived GS used for all legs; any `__S` values are ignored (warning emitted).
   - If some legs are FIXED, others FREE: FIXED legs use their `__S`; FREE legs share the remaining time budget proportionally (averaged GS, clamped to envelope).
   - If all legs are FREE: uniform derived GS from `(dist / Δtime)`.
3. After the last `__T` anchor: each leg uses its `__S` override or the plan default GS.

**HOLD duration.**
- `__T` on a HOLD only pins the arrival ETA at the holding — it has **no** effect on hold duration.
- For duration, all HOLDs are treated uniformly:
  - The **last HOLD before its next downstream `__T`** absorbs the slack. Flight time between that HOLD and its downstream anchor is computed using declared speeds (`__S` or plan default); the leftover becomes the hold duration.
  - Earlier HOLDs sharing the same downstream anchor get duration 0 + warning.
  - A HOLD with no downstream `__T` at all gets duration 0 + warning.
- If the slack works out negative (constraint physically infeasible at declared speeds): duration 0 + warning; downstream ETAs will drift past their `__T` values.

**ETA = TOT.** There is no distinction. `__T` is an ETA constraint, not a separate concept.

**ROLEX.** Applied to all ETAs for that group (shifts T0 and all downstream times).

**Speed envelope.** Speeds are expressed and clamped in IAS (converted from GS using `__A`). The Mosquito envelope is defined in `MosieNavigator.Aircraft.envelope` (`minIasKt` / `maxIasKt`). Violations emit a warning and clamp to the nearest bound.

## Aircraft Profiles & Fuel

`MosieNavigator.Aircraft` defines the Mosquito FB Mk VI performance table used for fuel estimation. Each profile covers an IAS range and altitude band and specifies a burn rate in Imperial gallons per hour. The flight plan algorithm matches each leg to a profile and accumulates fuel across the route.

Fuel summary components: taxi allowance + route burn + HOLD orbit burn + reserve (30 min at lowest-burn profile) + landing allowance. A warning is emitted if the total exceeds tank capacity (546 IMP GAL).

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
ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT
```

- `LAT`, `LON` are signed decimal degrees to 6 dp.
- `NAME` is empty when the source zone had no explicit `_<NAME>` token (the display name defaulted to the type).
- `ALT_FT` is empty when the source zone had no `__A` token.
- `TOT` is empty when the source zone had no `__T` token. When present, format is `HH:MM` or `HH:MM:SS`. TOT is the raw planned value; ROLEX shift is not applied in CSV (the group ROLEX is recorded in the header comment).
- `SPEED_KT` is the raw `__S` value in knots (ground speed). Empty when the source zone had no `__S` token. Computed ETA and IAS values are **not** written to CSV — they are output-only in the navlog and F10 message.

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

## Source Layout & Build

`MosieNavigator.lua` is a **generated bundle**. Do not edit it directly.

- Edit source modules under `src/*.lua`. Load order follows the numeric prefix
  (`01_config.lua` → `13_main.lua`); `13_main.lua` must remain last because it
  calls `MosieNavigator:Start()`.
- Regenerate the bundle before committing: `python3 build.py`
- CI / pre-commit sanity: `python3 build.py --check` (exits 1 if bundle drifts
  from source).
- Tests load `src/*.lua` directly via `dofile` and include one smoke test that
  also `dofile`s the bundle to catch syntax errors.

## Testing

Unit tests live in `MosieNavigator.spec.lua`. They load the real `lib/Moose.lua` behind a minimal DCS API shim, then exercise the parsers, formatters, math helpers, and zone discovery flow.

Run from this directory:

```bash
lua MosieNavigator.spec.lua
```

Requires Lua 5.1 (or LuaJIT) — matches the DCS runtime. Exit code is 0 on success, 1 on any failure. Tests must remain compatible with Lua 5.1 semantics (no `goto`, no integer-only `//`, no bitwise operators).
