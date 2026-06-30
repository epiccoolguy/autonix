#!/usr/bin/env bash
# Claude Code status line: [worktree name] model | effort | context | usage
# Receives session JSON on stdin. See https://code.claude.com/docs/en/statusline
input=$(cat)

IFS=$'\t' read -r MODEL EFFORT PCT FIVE_H FIVE_RESET WEEK WEEK_RESET CWD < <(
  echo "$input" | jq -r '
    [ .model.display_name,
      (.effort.level // "-"),
      ((.context_window.used_percentage // 0) | floor | tostring),
      (.rate_limits.five_hour.used_percentage // "" | if . == "" then "-" else (round | tostring) end),
      (.rate_limits.five_hour.resets_at // "-" | tostring),
      (.rate_limits.seven_day.used_percentage // "" | if . == "" then "-" else (round | tostring) end),
      (.rate_limits.seven_day.resets_at // "-" | tostring),
      (.workspace.current_dir // .cwd // "")
    ] | @tsv'
)

# Worktree name: only set inside a linked git worktree (git-dir != git-common-dir)
WORKTREE=$(
  cd "$CWD" 2>/dev/null || exit
  top=$(git rev-parse --show-toplevel 2>/dev/null) || exit
  [ "$(git rev-parse --git-dir 2>/dev/null)" != "$(git rev-parse --git-common-dir 2>/dev/null)" ] \
    && basename "$top"
)

NOW=$(date +%s)

# Compact "time remaining" from a future epoch: 4d3h, 2h10m, or 9m
fmt_left() {
  local secs=$(( $1 - NOW ))
  [ "$secs" -lt 0 ] && secs=0
  local d=$(( secs / 86400 )) h=$(( (secs % 86400) / 3600 )) m=$(( (secs % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then echo "${d}d${h}h"
  elif [ "$h" -gt 0 ]; then echo "${h}h${m}m"
  else echo "${m}m"; fi
}

LINE="${MODEL} | ${EFFORT} effort | ${PCT}% context"
[ -n "$WORKTREE" ] && LINE="worktree ${WORKTREE} | ${LINE}"
# Subscription usage segments are absent on non-Claude.ai plans
if [ "$FIVE_H" != "-" ]; then
  SEG="5h usage ${FIVE_H}%"
  [ "$FIVE_RESET" != "-" ] && SEG="${SEG} (resets in $(fmt_left "$FIVE_RESET"))"
  LINE="${LINE} | ${SEG}"
fi
if [ "$WEEK" != "-" ]; then
  SEG="7d usage ${WEEK}%"
  [ "$WEEK_RESET" != "-" ] && SEG="${SEG} (resets in $(fmt_left "$WEEK_RESET"))"
  LINE="${LINE} | ${SEG}"
fi
printf '%s\n' "$LINE"
