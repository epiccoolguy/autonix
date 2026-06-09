#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Update flake.lock and revert nodes newer than a minimum age."
    )
    parser.add_argument(
        "--lockfile",
        default="flake.lock",
        help="Path to flake.lock relative to the current working directory.",
    )
    parser.add_argument(
        "--min-age-hours",
        type=float,
        default=24.0,
        help="Minimum age a changed source must have before it is kept.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def last_modified(node: dict[str, Any]) -> int | None:
    locked = node.get("locked")
    if not isinstance(locked, dict):
        return None
    value = locked.get("lastModified")
    return value if isinstance(value, int) else None


def node_age_hours(node: dict[str, Any], now_ts: float) -> float | None:
    modified = last_modified(node)
    if modified is None:
        return None
    return (now_ts - modified) / 3600.0


def main() -> int:
    args = parse_args()
    lockfile = Path(args.lockfile)
    if not lockfile.exists():
        print(f"error: {lockfile} does not exist", file=sys.stderr)
        return 1

    before = load_json(lockfile)

    try:
        subprocess.run(["nix", "flake", "update"], check=True)
        after = load_json(lockfile)

        if not isinstance(before.get("nodes"), dict) or not isinstance(after.get("nodes"), dict):
            print("error: unexpected flake.lock structure", file=sys.stderr)
            return 1

        before_nodes = before["nodes"]
        after_nodes = after["nodes"]
        now_ts = datetime.now(timezone.utc).timestamp()
        min_age_hours = args.min_age_hours
        updated = False

        for node_name in sorted(set(before_nodes) | set(after_nodes)):
            old_node = before_nodes.get(node_name)
            new_node = after_nodes.get(node_name)

            if old_node == new_node:
                continue

            if new_node is None:
                if isinstance(old_node, dict):
                    old_age = node_age_hours(old_node, now_ts)
                    if old_age is None:
                        print(
                            f"error: node '{node_name}' was removed and has no lastModified to evaluate",
                            file=sys.stderr,
                        )
                        return 1
                    if old_age < min_age_hours:
                        after_nodes[node_name] = old_node
                        updated = True
                continue

            if not isinstance(new_node, dict):
                print(f"error: node '{node_name}' has unexpected structure", file=sys.stderr)
                return 1

            age_hours = node_age_hours(new_node, now_ts)
            if age_hours is None:
                print(
                    f"error: node '{node_name}' changed but has no lastModified timestamp",
                    file=sys.stderr,
                )
                return 1

            if age_hours < min_age_hours:
                if isinstance(old_node, dict):
                    after_nodes[node_name] = old_node
                else:
                    del after_nodes[node_name]
                updated = True

        if updated:
            write_json(lockfile, after)

        return 0
    except subprocess.CalledProcessError as error:
        print(f"error: nix flake update failed with exit code {error.returncode}", file=sys.stderr)
        return error.returncode


if __name__ == "__main__":
    raise SystemExit(main())