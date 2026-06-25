#!/usr/bin/env bash
# Claude Code status line: model · effort · context · usage
# Receives session JSON on stdin. See https://code.claude.com/docs/en/statusline
input=$(cat)

IFS=$'\t' read -r MODEL EFFORT PCT FIVE_H WEEK < <(
  echo "$input" | jq -r '
    [ .model.display_name,
      (.effort.level // "-"),
      ((.context_window.used_percentage // 0) | floor | tostring),
      (.rate_limits.five_hour.used_percentage // "" | if . == "" then "-" else (round | tostring) end),
      (.rate_limits.seven_day.used_percentage // "" | if . == "" then "-" else (round | tostring) end)
    ] | @tsv'
)

CYAN='\033[36m'; DIM='\033[2m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# Context bar, colored by fill
if   [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi
FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

# Subscription usage (absent for non-Claude.ai plans)
USAGE=""
[ "$FIVE_H" != "-" ] && USAGE="5h ${FIVE_H}%"
[ "$WEEK"   != "-" ] && USAGE="${USAGE:+$USAGE }7d ${WEEK}%"

LINE="${CYAN}${MODEL}${RESET} ${DIM}·${RESET} ⚡${EFFORT} ${DIM}·${RESET} ${BAR_COLOR}${BAR}${RESET} ${PCT}% ctx"
[ -n "$USAGE" ] && LINE="${LINE} ${DIM}·${RESET} ${USAGE}"
printf '%b\n' "$LINE"
