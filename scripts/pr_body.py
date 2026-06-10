#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a pull request body summarising flake.lock changes."
    )
    parser.add_argument(
        "--lockfile",
        default="flake.lock",
        help="Path to the updated flake.lock.",
    )
    parser.add_argument(
        "--old-ref",
        default="HEAD",
        help="Git ref to read the previous flake.lock from (default: HEAD).",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def short(rev: str) -> str:
    return rev[:7] if rev else rev


def main() -> int:
    args = parse_args()
    lockfile = Path(args.lockfile)
    if not lockfile.exists():
        print(f"error: {lockfile} does not exist", file=sys.stderr)
        return 1

    result = subprocess.run(
        ["git", "show", f"{args.old_ref}:{lockfile}"],
        capture_output=True,
        text=True,
    )
    try:
        old_nodes: dict[str, Any] = json.loads(result.stdout).get("nodes", {}) if result.returncode == 0 else {}
    except json.JSONDecodeError:
        old_nodes = {}

    new_nodes: dict[str, Any] = load_json(lockfile).get("nodes", {})

    lines: list[str] = []
    for name in sorted(new_nodes):
        if name == "root":
            continue
        old_rev = old_nodes.get(name, {}).get("locked", {}).get("rev", "")
        new_rev = new_nodes[name].get("locked", {}).get("rev", "")
        if old_rev and new_rev and old_rev != new_rev:
            lines.append(f"- **{name}**: `{short(old_rev)}` → `{short(new_rev)}`")

    prefix = "Automated daily nix flake update."
    if lines:
        print(prefix + "\n\n## Changes\n\n" + "\n".join(lines))
    else:
        print(prefix)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
