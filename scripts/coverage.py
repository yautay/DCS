#!/usr/bin/env python3
"""Run test coverage for MosieNavigator and MosieAiPlanner.

Prerequisites:
  luarocks install luacov          # or: hererocks /tmp/luaenv -l 5.3 --luarocks latest
                                   #     /tmp/luaenv/bin/luarocks install luacov

Usage:
  python3 scripts/coverage.py                     # all modules, threshold 80%
  python3 scripts/coverage.py --module navigator  # only navigator
  python3 scripts/coverage.py --module planner    # only ai_planner
  python3 scripts/coverage.py --threshold 90      # override threshold
  python3 scripts/coverage.py --no-build-check    # skip bundle sync check
  python3 scripts/coverage.py --format json       # also write .coverage/summary.json
  python3 scripts/coverage.py --verbose           # print raw luacov report

Exit codes:
  0 — all modules at or above threshold
  1 — one or more modules below threshold
  2 — missing dependency (lua or luacov not found)
  3 — bundle out of sync with src/
  4 — test suite crashed
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).parent.parent
LIB = REPO_ROOT / "DCS_Missions" / "lib"
COVERAGE_DIR = REPO_ROOT / ".coverage"

MODULES = {
    "navigator": LIB / "mosie_navigator",
    "planner":   LIB / "mosie_ai_planner",
}
SPEC_FILES = {
    "navigator": "MosieNavigator.spec.lua",
    "planner":   "MosieAiPlanner.spec.lua",
}

# ---------------------------------------------------------------------------
# ANSI colour helpers (TTY-aware)
# ---------------------------------------------------------------------------

USE_COLOUR = sys.stdout.isatty()

def _c(code: str, text: str) -> str:
    return f"\033[{code}m{text}\033[0m" if USE_COLOUR else text

def green(t: str)  -> str: return _c("32", t)
def yellow(t: str) -> str: return _c("33", t)
def red(t: str)    -> str: return _c("31", t)
def bold(t: str)   -> str: return _c("1",  t)

# ---------------------------------------------------------------------------
# Tool detection
# ---------------------------------------------------------------------------

def _find_exe(name: str, extra_paths: list[str] = ()) -> Optional[str]:
    """Return full path to *name* or None."""
    if shutil.which(name):
        return name
    for p in extra_paths:
        candidate = Path(p) / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return None

EXTRA_BIN_PATHS = ["/tmp/luaenv/bin", str(Path.home() / ".local" / "bin")]

def preflight() -> tuple[str, str]:
    """Return (lua_exe, luacov_exe) or print error and exit 2."""
    lua = _find_exe("lua", EXTRA_BIN_PATHS)
    if not lua:
        print(red("ERROR: 'lua' interpreter not found."))
        print("  Install Lua 5.1+ and ensure it is on PATH.")
        sys.exit(2)

    luacov = _find_exe("luacov", EXTRA_BIN_PATHS)
    if not luacov:
        # Try requiring it from found lua
        r = subprocess.run([lua, "-e", "require('luacov')"], capture_output=True)
        if r.returncode != 0:
            print(red("ERROR: luacov not found."))
            print("  Install it with:  luarocks install luacov")
            print("  Or:  hererocks /tmp/luaenv -l 5.3 --luarocks latest")
            print("       /tmp/luaenv/bin/luarocks install luacov")
            sys.exit(2)
        # If lua can require it, we don't need a separate binary — point to a no-op
        luacov = lua  # will invoke luacov module via -lluacov; separate binary found later

    # Verify luacov is loadable via the chosen lua
    r = subprocess.run([lua, "-e", "require('luacov')"], capture_output=True)
    if r.returncode != 0:
        print(red(f"ERROR: 'luacov' is not accessible from '{lua}'."))
        print(f"  stderr: {r.stderr.decode().strip()}")
        print("  Ensure luarocks installed luacov for this Lua version.")
        sys.exit(2)

    return lua, luacov

# ---------------------------------------------------------------------------
# Build check
# ---------------------------------------------------------------------------

def build_check(module_dir: Path) -> None:
    build_py = module_dir / "build.py"
    if not build_py.exists():
        return
    r = subprocess.run(
        [sys.executable, str(build_py), "--check"],
        cwd=module_dir,
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        name = module_dir.name
        print(red(f"ERROR: {name}/MosieAiPlanner.lua or MosieNavigator.lua is out of sync."))
        print(f"  Run:  python3 {build_py.relative_to(REPO_ROOT)} build.py")
        sys.exit(3)

# ---------------------------------------------------------------------------
# Run spec with luacov
# ---------------------------------------------------------------------------

def run_spec(lua: str, module_dir: Path, spec_file: str) -> None:
    """Run spec under luacov; exit 4 on failure."""
    stats = module_dir / "luacov.stats.out"
    stats.unlink(missing_ok=True)

    env = dict(os.environ)
    # Propagate luarocks path if luaenv is present
    luarocks = _find_exe("luarocks", EXTRA_BIN_PATHS)
    if luarocks:
        r = subprocess.run([luarocks, "path"], capture_output=True, text=True)
        if r.returncode == 0:
            for line in r.stdout.splitlines():
                line = line.strip()
                if line.startswith("export "):
                    key, _, val = line[7:].partition("=")
                    val = val.strip("'\"")
                    existing = env.get(key, "")
                    env[key] = (val + ";" + existing).rstrip(";") if existing else val

    r = subprocess.run(
        [lua, "-lluacov", spec_file],
        cwd=module_dir,
        env=env,
        capture_output=False,  # let output stream to terminal
    )
    if r.returncode != 0:
        print(red(f"ERROR: {spec_file} exited with code {r.returncode}"))
        sys.exit(4)

# ---------------------------------------------------------------------------
# Generate report
# ---------------------------------------------------------------------------

def generate_report(luacov: str, module_dir: Path, lua: str) -> str:
    """Run luacov reporter; return report text."""
    report_file = module_dir / "luacov.report.out"
    report_file.unlink(missing_ok=True)

    # luacov binary or fall back to: lua luacov_script
    if luacov == lua:
        # No separate binary — try common paths
        luacov_bin = _find_exe("luacov", EXTRA_BIN_PATHS)
        if not luacov_bin:
            print(yellow("WARNING: luacov binary not found; report may be incomplete."))
            return ""
    else:
        luacov_bin = luacov

    subprocess.run([luacov_bin], cwd=module_dir, capture_output=True)
    if report_file.exists():
        return report_file.read_text(encoding="utf-8")
    return ""

# ---------------------------------------------------------------------------
# Parse report
# ---------------------------------------------------------------------------

_LINE_RE = re.compile(r"^(src/\S+\.lua)\s+(\d+)\s+(\d+)\s+([\d.]+)%")

def parse_report(report: str) -> list[dict]:
    """Return list of {file, hit, miss, pct} dicts."""
    rows = []
    for line in report.splitlines():
        m = _LINE_RE.match(line.strip())
        if m:
            rows.append({
                "file": m.group(1),
                "hit":  int(m.group(2)),
                "miss": int(m.group(3)),
                "pct":  float(m.group(4)),
            })
    return rows

def parse_total(report: str) -> Optional[float]:
    for line in report.splitlines():
        line = line.strip()
        if line.startswith("Total"):
            m = re.search(r"([\d.]+)%", line)
            if m:
                return float(m.group(1))
    return None

# ---------------------------------------------------------------------------
# Print table
# ---------------------------------------------------------------------------

def colour_pct(pct: float, threshold: float) -> str:
    s = f"{pct:6.2f}%"
    if pct >= threshold:
        return green(s)
    elif pct >= threshold - 15:
        return yellow(s)
    return red(s)

def print_table(module_name: str, rows: list[dict], total: Optional[float], threshold: float) -> None:
    W_FILE = 30
    print(bold(f"\n{'Module':<12} {'File':<{W_FILE}} {'Hit':>6} {'Miss':>6} {'Total':>6}  Coverage"))
    print("-" * 72)
    for r in rows:
        col = colour_pct(r["pct"], threshold)
        print(f"  {module_name:<10} {r['file']:<{W_FILE}} {r['hit']:>6} {r['miss']:>6} {r['hit']+r['miss']:>6}  {col}")
    if total is not None:
        col = colour_pct(total, threshold)
        print("-" * 72)
        print(f"  {'':10} {'TOTAL':<{W_FILE}} {'':<6} {'':<6} {'':<6}  {col}")

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--module", choices=["navigator", "planner"],
                        help="Run only one module (default: both)")
    parser.add_argument("--threshold", type=float, default=80.0,
                        help="Minimum coverage percent per module and total (default: 80)")
    parser.add_argument("--no-build-check", action="store_true",
                        help="Skip build.py --check")
    parser.add_argument("--format", choices=["text", "json"], default="text",
                        help="Output format; 'json' additionally writes .coverage/summary.json")
    parser.add_argument("--verbose", action="store_true",
                        help="Print raw luacov report text")
    args = parser.parse_args()

    # 1. Preflight
    lua, luacov = preflight()

    # 2. Select modules
    selected = {args.module: MODULES[args.module]} if args.module else dict(MODULES)

    # 3. Build check
    if not args.no_build_check:
        for mod_dir in selected.values():
            build_check(mod_dir)

    # 4. Ensure output dir
    COVERAGE_DIR.mkdir(parents=True, exist_ok=True)

    # 5. Run + report for each module
    all_ok = True
    summary: dict[str, dict] = {}

    for name, mod_dir in selected.items():
        spec = SPEC_FILES[name]
        print(bold(f"\n{'='*60}"))
        print(bold(f"  {name}  ({spec})"))
        print(bold(f"{'='*60}"))

        run_spec(lua, mod_dir, spec)
        report = generate_report(luacov, mod_dir, lua)

        if args.verbose:
            print(report)

        rows = parse_report(report)
        total = parse_total(report)

        print_table(name, rows, total, args.threshold)

        # Copy artefacts to .coverage/
        for suffix in ("stats.out", "report.out"):
            src = mod_dir / f"luacov.{suffix}"
            if src.exists():
                shutil.copy(src, COVERAGE_DIR / f"luacov.{name}.{suffix}")

        low_files = [r for r in rows if r["pct"] < args.threshold]
        mod_ok = total is not None and total >= args.threshold

        summary[name] = {
            "total": total,
            "threshold": args.threshold,
            "passed": mod_ok,
            "files": rows,
        }

        if low_files:
            print(yellow(f"\n  Warning — files below {args.threshold:.0f}% (total still counts):"))
            for r in low_files:
                print(yellow(f"    {name}/{r['file']}: {r['pct']:.2f}%"))

        if not mod_ok:
            all_ok = False
            print(red(f"\n  {name}: total {total:.2f}% < {args.threshold:.0f}% threshold"))

    # 6. JSON output
    if args.format == "json":
        out = COVERAGE_DIR / "summary.json"
        out.write_text(json.dumps(summary, indent=2), encoding="utf-8")
        print(f"\nJSON summary → {out}")

    # 7. Final verdict
    print()
    if all_ok:
        print(green(bold(f"Coverage OK — all modules ≥ {args.threshold:.0f}%")))
        return 0
    else:
        print(red(bold(f"Coverage FAILED — one or more modules below {args.threshold:.0f}%")))
        return 1


if __name__ == "__main__":
    sys.exit(main())
