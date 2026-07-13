#!/usr/bin/env python3
"""Bundle src/*.lua into MosieAiPlanner.lua for the DCS runtime.

Edit source files under src/. The bundle is the deployed artefact;
commit it alongside source changes so mission builders always have a
working file at the expected path.

    python3 build.py             # regenerate bundle
    python3 build.py --check     # exit 1 if bundle is out of sync with src/
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
SRC_DIR = HERE / "src"
BUNDLE = HERE / "MosieAiPlanner.lua"

HEADER = (
    "-- ============================================================\n"
    "-- MosieAiPlanner.lua — GENERATED FILE. DO NOT EDIT DIRECTLY.\n"
    "-- Edit source modules under src/ and run: python3 build.py\n"
    "-- ============================================================\n"
)


def build() -> str:
    parts = sorted(SRC_DIR.glob("*.lua"))
    if not parts:
        raise SystemExit(f"no source files found in {SRC_DIR}")
    chunks = [HEADER]
    for path in parts:
        chunks.append(f"\n-- ==== {path.name} ====\n\n")
        text = path.read_text(encoding="utf-8")
        chunks.append(text if text.endswith("\n") else text + "\n")
    return "".join(chunks)


def main() -> int:
    content = build()
    if "--check" in sys.argv:
        current = BUNDLE.read_text(encoding="utf-8") if BUNDLE.exists() else ""
        if current != content:
            print(
                "MosieAiPlanner.lua is out of sync with src/ — run: python3 build.py",
                file=sys.stderr,
            )
            return 1
        print("bundle in sync")
        return 0
    BUNDLE.write_text(content, encoding="utf-8")
    src_count = len(list(SRC_DIR.glob("*.lua")))
    print(f"wrote {BUNDLE.name} from {src_count} source modules")
    return 0


if __name__ == "__main__":
    sys.exit(main())
