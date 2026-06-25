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

LINE="${MODEL} | ${EFFORT} effort | ${PCT}% context"
# Subscription usage segments are absent on non-Claude.ai plans
[ "$FIVE_H" != "-" ] && LINE="${LINE} | 5h usage ${FIVE_H}%"
[ "$WEEK"   != "-" ] && LINE="${LINE} | 7d usage ${WEEK}%"
printf '%s\n' "$LINE"
