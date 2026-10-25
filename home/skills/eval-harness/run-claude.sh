#!/usr/bin/env bash
# Usage: run-claude.sh <skill> with-skill|without-skill|grade [run-number]
# Env: EVALS (default all), MODELS (default haiku,sonnet,opus).
set -euo pipefail

S=${1:?skill, e.g. simple-testing}
MODE=${2:?with-skill, without-skill, or grade}
N=${3:-1}
P=/etc/nix-darwin/home/skills/eval-harness
R=$HOME/skill-evals/$S/run-claude-$N

for f in "$P/rules.md" "$P/claude-runner.md" "$P/grade.md" "/etc/nix-darwin/home/skills/$S/evals/evals.json"; do
  [[ -f $f ]] || { echo "missing $f" >&2; exit 1; }
done

mkdir -p "$R"
cd "$HOME/skill-evals/$S"

case $MODE in
  with-skill | without-skill)
    exec claude "$(cat "$P/rules.md" "$P/claude-runner.md") ARM=$MODE R=$R SKILL=$S EVALS=${EVALS:-all} MODELS=${MODELS:-haiku,sonnet,opus}"
    ;;
  grade)
    exec claude "$(cat "$P/grade.md") SKILL=$S R=$R"
    ;;
  *)
    echo "mode must be with-skill, without-skill, or grade" >&2
    exit 2
    ;;
esac
