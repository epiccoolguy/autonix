#!/usr/bin/env bash
input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

if grep -qE '(^|[;&|(`]|\$\()[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*(npm|npx)([[:space:]]|$)' <<<"$command"; then
  # npm-based repos (lockfile committed in HEAD, no pnpm lockfile) keep their own
  # package manager. The check covers the session cwd only, so commands that
  # change directory or point npm elsewhere (--prefix/-C, global) stay blocked;
  # a committed lockfile stops an agent from creating or staging one to unlock npm.
  if ! grep -qE '(^|[;&|(`[:space:]])(cd|pushd)([[:space:]]|$)|(^|[[:space:]])(--prefix|-C|-g|--global|--location)(=|[[:space:]]|$)' <<<"$command" &&
    root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null) &&
    git -C "$root" cat-file -e HEAD:package-lock.json 2>/dev/null &&
    [[ ! -e "$root/pnpm-lock.yaml" ]]; then
    exit 0
  fi
  echo "Blocked: use pnpm instead of npm (pnpm dlx or pnpx instead of npx). npm is allowed only in repos with a committed package-lock.json and no pnpm-lock.yaml, run from the repo itself without cd, --prefix/-C, or global flags." >&2
  exit 2
fi
