#!/usr/bin/env bash
# Claude Code status line: worktree | branch | changes | model | effort | context | usage
# Receives session JSON on stdin. See https://code.claude.com/docs/en/statusline
input=$(tr -d '\n')

# Minimal JSON extraction without jq. obj returns the body of the first object
# under key $1 with nested objects replaced by null, so keys like
# used_percentage are scoped to the right parent.
obj() {
  grep -oE "\"$1\": *\{([^{}]|\{[^{}]*\})*\}" <<<"$2" | head -n1 |
    sed -E "s/^\"$1\": *\{//; s/\}\$//; s/\{[^{}]*\}/null/g"
}
str() { sed -nE "s/.*\"$1\": *\"([^\"]*)\".*/\1/p" <<<"$2"; }
num() { sed -nE "s/.*\"$1\": *(-?[0-9.]+).*/\1/p" <<<"$2"; }

MODEL=$(str display_name "$(obj model "$input")")
EFFORT=$(str level "$(obj effort "$input")")
PCT=$(num used_percentage "$(obj context_window "$input")")
FIVE=$(obj five_hour "$input")
WEEK=$(obj seven_day "$input")
FIVE_H=$(num used_percentage "$FIVE")
FIVE_RESET=$(num resets_at "$FIVE")
WEEK_PCT=$(num used_percentage "$WEEK")
WEEK_RESET=$(num resets_at "$WEEK")
CWD=$(str current_dir "$input")
[ -z "$CWD" ] && CWD=$(str cwd "$input")

# Git: worktree name (only inside a linked worktree), branch, and
# staged/unstaged/untracked file counts
IFS=$'\t' read -r WORKTREE BRANCH STAGED UNSTAGED ADDED < <(
  cd "$CWD" 2>/dev/null || exit
  top=$(git rev-parse --show-toplevel 2>/dev/null) || exit
  wt=-
  [ "$(git rev-parse --git-dir)" != "$(git rev-parse --git-common-dir)" ] && wt=$(basename "$top")
  branch=$(git branch --show-current)
  [ -z "$branch" ] && branch=$(git rev-parse --short HEAD 2>/dev/null)
  counts=$(git --no-optional-locks status --porcelain --untracked-files=all | awk '
    { x = substr($0, 1, 1); y = substr($0, 2, 1) }
    x y == "??" { a++; next }
    x != " " { s++ }
    y != " " { u++ }
    END { printf "%d\t%d\t%d", s, u, a }')
  printf '%s\t%s\t%s\n' "$wt" "${branch:--}" "$counts"
)

NOW=$(date +%s)

# Compact "time remaining" from a future epoch: 4d3h, 2h10m, or 9m
fmt_left() {
  local secs=$(( ${1%.*} - NOW ))
  [ "$secs" -lt 0 ] && secs=0
  local d=$(( secs / 86400 )) h=$(( (secs % 86400) / 3600 )) m=$(( (secs % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then echo "${d}d${h}h"
  elif [ "$h" -gt 0 ]; then echo "${h}h${m}m"
  else echo "${m}m"; fi
}

PCT=${PCT%.*}
LINE="${MODEL} | ${EFFORT:--} effort | ${PCT:-0}% context"
[ -n "$BRANCH" ] && LINE="${BRANCH} | S: ${STAGED} U: ${UNSTAGED} A: ${ADDED} | ${LINE}"
[ -n "$WORKTREE" ] && [ "$WORKTREE" != "-" ] && LINE="worktree ${WORKTREE} | ${LINE}"
# Subscription usage segments are absent on non-Claude.ai plans
if [ -n "$FIVE_H" ]; then
  SEG="5h usage $(printf '%.0f' "$FIVE_H")%"
  [ -n "$FIVE_RESET" ] && SEG="${SEG} (resets in $(fmt_left "$FIVE_RESET"))"
  LINE="${LINE} | ${SEG}"
fi
if [ -n "$WEEK_PCT" ]; then
  SEG="7d usage $(printf '%.0f' "$WEEK_PCT")%"
  [ -n "$WEEK_RESET" ] && SEG="${SEG} (resets in $(fmt_left "$WEEK_RESET"))"
  LINE="${LINE} | ${SEG}"
fi
printf '%s\n' "$LINE"
