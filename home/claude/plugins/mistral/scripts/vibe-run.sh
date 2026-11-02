#!/usr/bin/env bash
# Thin wrapper around headless `vibe -p` for the mistral plugin. Progress goes to stderr,
# the final answer to stdout.
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

# Usage: need_value "$#" "$1" - for flags that consume the next argument.
need_value() {
  [ "$1" -ge 2 ] || die "$2 needs a value"
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

# Read-only runs still get a shell; the sandbox is what keeps them read-only.
read_only_tools=(--auto-approve --enabled-tools bash --enabled-tools read_file)

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/mistral.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT

# Usage: sandbox_cmd <write-root> [<protected-path>...]
# Vibe has no sandbox of its own (Codex ships one per OS), so wrap it: Seatbelt on macOS,
# bubblewrap on Linux/WSL2. Both allow reads everywhere and writes only to <write-root>,
# Vibe's state, and temp dirs; the network stays open for Mistral's API. Protected paths
# are made read-only last, so they win over the writable dirs that contain them.
sandbox_cmd() {
  local write_root vibe_home p
  write_root="$(realpath "$1")"
  shift
  vibe_home="${VIBE_HOME:-$HOME/.vibe}"
  mkdir -p "$vibe_home"
  vibe_home="$(realpath "$vibe_home")"
  # Vibe must write its logs, but a tool call must not change the config, agents, or
  # skills that a later unsandboxed interactive vibe would load.
  local protected=()
  for p in "$@" "$vibe_home"/{config.toml,trusted_folders.toml,.env,agents,skills,prompts,tools,plugins}; do
    [ -e "$p" ] && protected+=("$(realpath "$p")")
  done
  case "$(uname -s)" in
    Darwin)
      local profile i
      profile="$(cat "$plugin_root/scripts/vibe.sb")"
      sandbox=(sandbox-exec -D WRITE_ROOT="$write_root" -D VIBE_HOME="$vibe_home")
      for i in "${!protected[@]}"; do
        profile+=$'\n'"(deny file-write* (subpath (param \"PROTECTED_$i\")))"
        sandbox+=(-D "PROTECTED_$i=${protected[$i]}")
      done
      sandbox+=(-p "$profile")
      ;;
    Linux)
      command -v bwrap >/dev/null || die "bwrap not found; install bubblewrap (e.g. apt install bubblewrap)"
      sandbox=(bwrap --die-with-parent --ro-bind / / --dev /dev --proc /proc --bind /tmp /tmp
        --bind "$vibe_home" "$vibe_home" --bind "$write_root" "$write_root")
      [ -z "${TMPDIR:-}" ] || sandbox+=(--bind "$(realpath "$TMPDIR")" "$(realpath "$TMPDIR")")
      for p in "${protected[@]}"; do
        sandbox+=(--ro-bind "$p" "$p")
      done
      sandbox+=(--)
      ;;
    *) die "no sandbox for $(uname -s); supported: macOS, Linux" ;;
  esac
}

# Usage: run_vibe <write-root> <protected-path> <vibe args...>
# Runs Vibe in the sandbox with writes allowed only under <write-root>, never under
# <protected-path>. Streams one "[mistral] ..." line per event to stderr, prints the final
# answer, and sets $session. Exit 3 means Vibe stopped at its turn, cost, or time limit.
run_vibe() {
  local log="$work_dir/stream.jsonl" rc sandbox
  sandbox_cmd "$1" "$2"
  shift 2
  # The whole script must finish inside Claude's 600 s Bash timeout so the answer and
  # session id survive; SECONDS already covers the git work done before this.
  local time_limit=$((560 - SECONDS))
  [ "$time_limit" -ge 60 ] || time_limit=60
  set +e
  "${sandbox[@]}" vibe --trust --disabled-tools ask_user_question --output streaming --time-limit "$time_limit" "$@" |
    tee "$log" |
    jq --unbuffered -rR '
      fromjson? | objects |
      if .type == "message" and .role == "user" then
        "[mistral] session \(.sessionId) started; model is reading the prompt"
      elif .type == "reasoning" and (.text | type) == "string" then
        "[mistral] thinking: \(.text | gsub("\\s+"; " ") | .[0:120])"
      elif .type == "effect" and .title != "Searching for relevant tools" then
        "[mistral] \((.detail | objects | .display.summary) // .title)"
          + (if .state.status == "failed" then " - \(.state.error.message // "failed")" else "" end)
      else empty end' >&2
  rc=${PIPESTATUS[0]}
  set -e

  # Per-line parsing, so a truncated last line can't discard the whole run.
  session="$(jq -rRn '[inputs | fromjson? | objects | .sessionId // empty] | last // empty' "$log")"
  local answer
  answer="$(jq -rRn '[inputs | fromjson? | objects | select(.type == "message" and .role == "assistant")] | last | .content // [] | map(select(.type == "text") | .text) | join("")' "$log")"
  [ "$rc" -eq 3 ] && echo "mistral: Vibe stopped at its turn, cost, or time limit; the answer may be incomplete." >&2
  if [ -n "$answer" ]; then
    printf '%s\n' "$answer"
  else
    echo "mistral: Vibe returned no answer (exit $rc). Last events:" >&2
    tail -n 3 "$log" | cut -c1-500 >&2
    [ "$rc" -ne 0 ] || rc=1
  fi
  return "$rc"
}

working_tree_context() {
  echo "## git status"
  git status --short --untracked-files=all
  echo
  if git rev-parse --quiet --verify HEAD >/dev/null; then
    echo "## Tracked changes (git diff HEAD)"
    git diff HEAD
  else
    echo "## Staged changes (no commits yet)"
    git diff --cached
    echo
    echo "## Unstaged changes"
    git diff
  fi
  local f
  git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do
    echo
    echo "## Untracked file: $f"
    # Exit 1 just means "differs"; anything higher means the file couldn't be read.
    git diff --no-index -- /dev/null "$f" || [ $? -eq 1 ] ||
      echo "mistral: could not diff untracked file $f; it is listed without contents" >&2
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
      --base) need_value $# "$1"; base="$2"; shift 2 ;;
      --scope) need_value $# "$1"; scope="$2"; shift 2 ;;
      --wait | --background) shift ;;
      --model | --effort) need_value $# "$1"; shift 2 ;;
      *) focus+=("$1"); shift ;;
    esac
  done
  [ "$kind" = review ] && [ ${#focus[@]} -gt 0 ] &&
    die "/mistral:review takes no focus text; use /mistral:adversarial-review"

  git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git repository"
  # Diffs and untracked-file listings must cover the whole repository, not the cwd subtree.
  cd "$(repo_root)"
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

  # Large diffs: keep the full diff in a file Vibe can read in chunks.
  if [ "${#context}" -gt 300000 ]; then
    printf '%s\n' "$context" >"$work_dir/full-diff.txt"
    context="The full diff is too large to inline; it is saved at $work_dir/full-diff.txt.
Read it in chunks with read_file, and read the changed files for surrounding context.
Summary:
$(if [ "$scope" = branch ]; then git diff --stat "$base...HEAD"; else git status --short --untracked-files=all; fi)"
  fi

  local root prompt_file="$work_dir/prompt.md"
  root="$(repo_root)"
  {
    cat "$plugin_root/prompts/$kind.md"
    echo
    echo "Target: $target"
    echo "User focus: ${focus[*]:-none}"
    echo "Repository root and working directory: $root. Use paths relative to it."
    echo "You have read_file and a shell (git, rg, ls, ...). A sandbox blocks all writes to the repository; do not try to modify anything."
    echo
    echo "<repository_context>"
    echo "$context"
    echo "</repository_context>"
  } >"$prompt_file"

  echo "Mistral $kind of $target" >&2
  run_vibe "$work_dir" "$root" --workdir "$root" --max-turns 40 --max-price 2 \
    "${read_only_tools[@]}" --add-dir "$work_dir" \
    --prompt-file "$prompt_file"
}

task() {
  local mode="write" resume="" text=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --read-only) mode=read-only; shift ;;
      --write) mode="write"; shift ;;
      --resume | --resume-last) resume=last; shift ;;
      --fresh) resume=""; shift ;;
      --wait | --background) shift ;;
      --model | --effort) need_value $# "$1"; shift 2 ;;
      *) text+=("$1"); shift ;;
    esac
  done
  [ ${#text[@]} -gt 0 ] || die "no task text given"

  local root write_root protected
  root="$(repo_root)"
  cd "$root"
  local args=(--workdir "$root" --max-turns 80 --max-price 5)
  if [ "$mode" = write ]; then
    args+=(--auto-approve)
    write_root="$root"
    # Like Codex: the task may edit the work tree but not plant hooks or rewrite history.
    protected="$root/.git"
  else
    args+=("${read_only_tools[@]}")
    write_root="$work_dir"
    protected="$root"
  fi
  if [ "$resume" = last ]; then
    local id
    id="$(cat "$(session_file)" 2>/dev/null || true)"
    [ -n "$id" ] || die "no previous Mistral task for this repository; start a fresh one"
    args+=(--resume "$id")
  fi

  local rc=0
  session=""
  run_vibe "$write_root" "$protected" "${args[@]}" -p "${text[*]}" || rc=$?
  # Exit 3 (stopped at a limit) is worth resuming; other failures are not.
  if [ -n "$session" ] && { [ "$rc" -eq 0 ] || [ "$rc" -eq 3 ]; }; then
    mkdir -p "$state_dir"
    echo "$session" >"$(session_file)"
    printf '\n---\nVibe session %s (%s). Continue with /mistral:rescue --resume.\n' "$session" "$mode"
  fi
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
