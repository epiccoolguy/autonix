#!/usr/bin/env bash
# Thin wrapper around headless `vibe -p` for the mistral plugin.
#   vibe-run.sh review [--base <ref>] [--scope auto|working-tree|branch]
#   vibe-run.sh adversarial-review [--base <ref>] [--scope ...] [focus text]
#   vibe-run.sh task [--read-only] [--resume|--resume-last|--fresh] <task text>
#   vibe-run.sh last-session
set -euo pipefail

plugin_root="$(cd "$(dirname "$0")/.." && pwd)"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-mistral-plugin"

die() {
  echo "mistral: $*" >&2
  exit 1
}

command -v vibe >/dev/null || die "vibe not found; install the mistral-vibe formula and run /mistral:setup"

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

session_file() {
  printf '%s/%s' "$state_dir" "$(repo_root | sha256sum | cut -c1-16)"
}

default_base() {
  local ref
  ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)" && {
    echo "$ref"
    return
  }
  for ref in origin/main origin/master main master; do
    git rev-parse --verify --quiet "$ref" >/dev/null && {
      echo "$ref"
      return
    }
  done
  die "cannot determine a base branch; pass --base <ref>"
}

# Exit 3 is vibe's --time-limit stop.
run_vibe() {
  local rc=0
  vibe --trust --disabled-tools ask_user_question "$@" || rc=$?
  [ "$rc" -eq 3 ] && echo "mistral: Vibe hit its time limit; output may be incomplete." >&2
  return "$rc"
}

working_tree_context() {
  echo "## git status"
  git status --short --untracked-files=all
  if git rev-parse --quiet --verify HEAD >/dev/null; then
    echo
    echo "## Tracked changes (git diff HEAD)"
    git diff HEAD
  fi
  local f
  git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do
    echo
    echo "## Untracked file: $f"
    git diff --no-index -- /dev/null "$f" || true
  done
}

branch_context() {
  local base="$1"
  echo "## Commits ($base..HEAD)"
  git log --oneline "$base..HEAD"
  echo
  echo "## Diff ($base...HEAD)"
  git diff "$base...HEAD"
}

review() {
  local kind="$1"
  shift
  local base="" scope="auto" focus=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --base) base="$2"; shift 2 ;;
      --scope) scope="$2"; shift 2 ;;
      --wait | --background) shift ;;
      --model | --effort) shift 2 ;;
      *) focus+=("$1"); shift ;;
    esac
  done
  [ "$kind" = review ] && [ ${#focus[@]} -gt 0 ] &&
    die "/mistral:review takes no focus text; use /mistral:adversarial-review"

  git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git repository"
  if [ "$scope" = auto ]; then
    if [ -n "$base" ]; then
      scope=branch
    elif [ -n "$(git status --porcelain --untracked-files=all)" ]; then
      scope=working-tree
    else
      scope=branch
    fi
  fi

  local context target
  case "$scope" in
    working-tree)
      [ -n "$(git status --porcelain --untracked-files=all)" ] || die "nothing to review"
      target="uncommitted working-tree changes"
      context="$(working_tree_context)"
      ;;
    branch)
      base="${base:-$(default_base)}"
      [ -n "$(git diff --stat "$base...HEAD")" ] || die "nothing to review against $base"
      target="branch diff against $base"
      context="$(branch_context "$base")"
      ;;
    *) die "unknown scope: $scope (auto, working-tree or branch)" ;;
  esac

  # Large diffs: send the stat and let Vibe read the files itself.
  if [ "${#context}" -gt 300000 ]; then
    if [ "$scope" = branch ]; then
      context="$(git log --oneline "$base..HEAD"; echo; git diff --stat "$base...HEAD")"
    else
      context="$(git status --short --untracked-files=all; echo; git diff --stat HEAD)"
    fi
    context="The full diff is too large to inline. Read the changed files with your tools.
$context"
  fi

  prompt_file="$(mktemp "${TMPDIR:-/tmp}/mistral-review.XXXXXX")"
  trap 'rm -f "$prompt_file"' EXIT
  {
    cat "$plugin_root/prompts/$kind.md"
    echo
    echo "Target: $target"
    echo "User focus: ${focus[*]:-none}"
    echo
    echo "<repository_context>"
    echo "$context"
    echo "</repository_context>"
  } >"$prompt_file"

  echo "Mistral $kind of $target" >&2
  run_vibe --output text --max-turns 40 --max-price 2 --time-limit 900 \
    --enabled-tools read_file --enabled-tools grep \
    --prompt-file "$prompt_file"
}

task() {
  local mode=write resume="" text=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --read-only) mode=read-only; shift ;;
      --write) mode="write"; shift ;;
      --resume | --resume-last) resume=last; shift ;;
      --fresh) resume=""; shift ;;
      --wait | --background) shift ;;
      --model | --effort) shift 2 ;;
      *) text+=("$1"); shift ;;
    esac
  done
  [ ${#text[@]} -gt 0 ] || die "no task text given"

  local args=(--output json --max-turns 80 --max-price 5 --time-limit 1800)
  if [ "$mode" = write ]; then
    args+=(--auto-approve)
  else
    args+=(--enabled-tools read_file --enabled-tools grep --enabled-tools web_search --enabled-tools web_fetch)
  fi
  if [ "$resume" = last ]; then
    local id
    id="$(cat "$(session_file)" 2>/dev/null)" || die "no previous Mistral task for this repository; start a fresh one"
    args+=(--resume "$id")
  fi

  local out rc=0
  out="$(run_vibe "${args[@]}" -p "${text[*]}")" || rc=$?
  local session
  session="$(jq -r 'last(.[] | .sessionId // empty) // empty' <<<"$out" 2>/dev/null || true)"
  if [ -n "$session" ]; then
    mkdir -p "$state_dir"
    echo "$session" >"$(session_file)"
  fi
  jq -r 'last(.[] | select(.role == "assistant" and .type == "message")) | [.content[] | select(.type == "text") | .text] | join("")' <<<"$out" 2>/dev/null ||
    printf '%s\n' "$out"
  [ -n "$session" ] && printf '\n---\nVibe session %s (%s). Continue with /mistral:rescue --resume.\n' "$session" "$mode"
  return "$rc"
}

case "${1:-}" in
  review | adversarial-review)
    kind="$1"
    shift
    review "$kind" "$@"
    ;;
  task)
    shift
    task "$@"
    ;;
  last-session) cat "$(session_file)" 2>/dev/null || true ;;
  *) die "usage: vibe-run.sh review|adversarial-review|task|last-session ..." ;;
esac
