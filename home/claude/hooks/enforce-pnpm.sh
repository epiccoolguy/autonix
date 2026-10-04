#!/usr/bin/env bash
input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

if grep -qE '(^|[;&|(`]|\$\()[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*(npm|npx)([[:space:]]|$)' <<<"$command"; then
  # Habit guardrail, not a security boundary: matching command text can't see
  # through quoting, env, eval, etc. npm-based repos (package-lock.json committed
  # in HEAD, no pnpm-lock.yaml on disk or in HEAD) keep their own package manager.
  # Only the session cwd is checked, so commands that change directory or point
  # npm elsewhere (--prefix/-C, global) stay blocked.
  if ! grep -qE '(^|[;&|(`[:space:]])(cd|pushd)([[:space:]]|$)|(^|[[:space:]])(--prefix|-C|-g|--global|--location)(=|[[:space:]]|$)' <<<"$command" &&
    root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null) &&
    git -C "$root" cat-file -e HEAD:package-lock.json 2>/dev/null &&
    ! git -C "$root" cat-file -e HEAD:pnpm-lock.yaml 2>/dev/null &&
    [[ ! -e "$root/pnpm-lock.yaml" ]]; then
    exit 0
  fi
  echo "Blocked: use pnpm instead of npm (pnpm dlx or pnpx instead of npx). npm is allowed only in repos with a committed package-lock.json and no pnpm-lock.yaml, run from the repo itself without cd, --prefix/-C, or global flags." >&2
  exit 2
fi
