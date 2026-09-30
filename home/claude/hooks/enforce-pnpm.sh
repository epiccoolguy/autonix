#!/usr/bin/env bash
command=$(jq -r '.tool_input.command // empty')

if grep -qE '(^|[;&|(`]|\$\()[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*(npm|npx)([[:space:]]|$)' <<<"$command"; then
  echo "Blocked: use pnpm instead of npm (pnpm dlx or pnpx instead of npx)" >&2
  exit 2
fi
