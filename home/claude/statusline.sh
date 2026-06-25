#!/usr/bin/env bash
# Claude Code status line: model | effort | context | usage
# Receives session JSON on stdin. See https://code.claude.com/docs/en/statusline
input=$(cat)

IFS=$'\t' read -r MODEL EFFORT PCT FIVE_H FIVE_RESET WEEK WEEK_RESET < <(
  echo "$input" | jq -r '
    [ .model.display_name,
      (.effort.level // "-"),
      ((.context_window.used_percentage // 0) | floor | tostring),
      (.rate_limits.five_hour.used_percentage // "" | if . == "" then "-" else (round | tostring) end),
      (.rate_limits.five_hour.resets_at // "-" | tostring),
      (.rate_limits.seven_day.used_percentage // "" | if . == "" then "-" else (round | tostring) end),
      (.rate_limits.seven_day.resets_at // "-" | tostring)
    ] | @tsv'
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
