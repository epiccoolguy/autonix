#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Commit flake.lock to a bot branch and create or update a pull request."
    )
    parser.add_argument(
        "--branch",
        default=os.environ.get("BRANCH", "bot/daily-nix-flake-update"),
        help="Bot branch name (default: $BRANCH env var or bot/daily-nix-flake-update).",
    )
    parser.add_argument(
        "--base-branch",
        default=os.environ.get("BASE_BRANCH", "master"),
        help="Target base branch (default: $BASE_BRANCH env var or master).",
    )
    parser.add_argument(
        "--lockfile",
        default="flake.lock",
        help="Path to the updated flake.lock (default: flake.lock).",
    )
    parser.add_argument(
        "--commit-message",
        default="chore: daily nix flake update",
        help="Commit message.",
    )
    parser.add_argument(
        "--pr-title",
        default="chore: daily nix flake update",
        help="Pull request title.",
    )
    parser.add_argument(
        "--warnings-file",
        default=os.environ.get("NIX_WARNINGS_FILE", ""),
        help="Optional path to a file containing nix warnings to include in the PR body.",
    )
    return parser.parse_args()


def run(cmd: list[str], **kwargs: Any) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, check=True, text=True, **kwargs)


def run_output(cmd: list[str]) -> str:
    return subprocess.run(cmd, check=True, text=True, capture_output=True).stdout.strip()


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


def load_warnings(warnings_file: Path | None) -> list[str]:
    if not warnings_file:
        return []
    if not warnings_file.exists():
        return []
    return parse_warning_lines(warnings_file.read_text(encoding="utf-8"))


def build_body(lockfile: Path, warnings: list[str], old_ref: str = "HEAD") -> str:
    result = subprocess.run(
        ["git", "show", f"{old_ref}:{lockfile}"],
        capture_output=True,
        text=True,
    )
    try:
        old_nodes: dict[str, Any] = json.loads(result.stdout).get("nodes", {}) if result.returncode == 0 else {}
    except json.JSONDecodeError:
        old_nodes = {}

    with lockfile.open() as f:
        new_nodes: dict[str, Any] = json.load(f).get("nodes", {})

    lines: list[str] = []
    for name in sorted(new_nodes):
        if name == "root":
            continue
        old_rev = old_nodes.get(name, {}).get("locked", {}).get("rev", "")
        new_rev = new_nodes[name].get("locked", {}).get("rev", "")
        if old_rev and new_rev and old_rev != new_rev:
            lines.append(f"- **{name}**: `{short(old_rev)}` → `{short(new_rev)}`")

    prefix = "Automated daily nix flake update."
    sections: list[str] = []

    if lines:
        sections.append("## Changes\n\n" + "\n".join(lines))

    if warnings:
        sections.append("## Warnings\n\n```text\n" + "\n".join(warnings) + "\n```")

    if sections:
        return prefix + "\n\n" + "\n\n".join(sections)

    return prefix


def main() -> int:
    args = parse_args()
    branch: str = args.branch
    base_branch: str = args.base_branch
    lockfile = Path(args.lockfile)
    warnings_file = Path(args.warnings_file) if args.warnings_file else None

    if branch == base_branch:
        print(
            f"Refusing to push: automation branch equals default branch ({base_branch}).",
            file=sys.stderr,
        )
        return 1

    if not branch.startswith("bot/"):
        print(
            "Refusing to push: automation branch must start with bot/.",
            file=sys.stderr,
        )
        return 1

    if not lockfile.exists():
        print(f"error: {lockfile} does not exist", file=sys.stderr)
        return 1

    # Build body before switching branches so HEAD still points to base.
    warnings = load_warnings(warnings_file)
    body = build_body(lockfile, warnings)

    try:
        run(["git", "config", "user.name", "github-actions[bot]"])
        run(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"])
        run(["git", "checkout", "-B", branch])
        run(["git", "add", str(lockfile)])
        run(["git", "commit", "-m", args.commit_message])
        run(["git", "push", "--force-with-lease", "--set-upstream", "origin", branch])
    except subprocess.CalledProcessError as e:
        print(f"error: git operation failed with exit code {e.returncode}", file=sys.stderr)
        return e.returncode

    try:
        existing_pr = run_output([
            "gh", "pr", "list",
            "--head", branch,
            "--base", base_branch,
            "--state", "open",
            "--json", "number",
            "--jq", ".[0].number",
        ])

        if existing_pr:
            print(f"Updating pull request #{existing_pr}")
            run(["gh", "pr", "edit", existing_pr, "--body", body])
        else:
            run([
                "gh", "pr", "create",
                "--head", branch,
                "--base", base_branch,
                "--title", args.pr_title,
                "--body", body,
            ])
    except subprocess.CalledProcessError as e:
        print(f"error: gh operation failed with exit code {e.returncode}", file=sys.stderr)
        return e.returncode

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
