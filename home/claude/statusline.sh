#!/usr/bin/env bash
# Claude Code status line: model | effort | context | usage
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

# Subscription usage (absent for non-Claude.ai plans)
USAGE=""
[ "$FIVE_H" != "-" ] && USAGE="5h ${FIVE_H}%"
[ "$WEEK"   != "-" ] && USAGE="${USAGE:+$USAGE }7d ${WEEK}%"

LINE="${MODEL} | eff:${EFFORT} | ${PCT}% ctx"
[ -n "$USAGE" ] && LINE="${LINE} | ${USAGE}"
printf '%s\n' "$LINE"
