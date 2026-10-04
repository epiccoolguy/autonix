#!/usr/bin/env bash
input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

if grep -qE '(^|[;&|(`]|\$\()[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*(npm|npx)([[:space:]]|$)' <<<"$command"; then
  root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null || echo "${cwd:-.}")
  # npm-based repos (npm lockfile, no pnpm lockfile) keep their own package manager.
  if [[ -f "$root/package-lock.json" && ! -f "$root/pnpm-lock.yaml" ]]; then
    exit 0
  fi
  echo "Blocked: use pnpm instead of npm (pnpm dlx or pnpx instead of npx)" >&2
  exit 2
fi
