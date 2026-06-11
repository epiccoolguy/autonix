#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
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
    parser.add_argument(
        "--warnings-file",
        default="",
        help="Optional path to a file containing nix warnings to include in the PR body.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def short(rev: str) -> str:
    return rev[:7] if rev else rev


def parse_warning_lines(text: str) -> list[str]:
    warning_re = re.compile(r"(^|\s)warning:\s", re.IGNORECASE)
    seen: set[str] = set()
    warnings: list[str] = []

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if not warning_re.search(line):
            continue
        if line in seen:
            continue
        seen.add(line)
        warnings.append(line)

    return warnings


def load_warnings(path: Path | None) -> list[str]:
    if not path:
        return []
    if not path.exists():
        return []
    return parse_warning_lines(path.read_text(encoding="utf-8"))


def main() -> int:
    args = parse_args()
    lockfile = Path(args.lockfile)
    warnings_path = Path(args.warnings_file) if args.warnings_file else None
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
    warnings = load_warnings(warnings_path)

    sections: list[str] = []
    if lines:
        sections.append("## Changes\n\n" + "\n".join(lines))

    if warnings:
        sections.append("## Warnings\n\n```text\n" + "\n".join(warnings) + "\n```")

    if sections:
        print(prefix + "\n\n" + "\n\n".join(sections))
    else:
        print(prefix)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
