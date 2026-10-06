Run the simple-code skill evals on Claude Code. The arm (with-skill or without-skill) and the output root R are given at the end of this message. Only run them; do not open, judge, or grade any eval run's diff or output (setup and smoke diagnostics are fine, see the hard rules).

Inputs: /etc/nix-darwin/home/skills/simple-code/evals/evals.json and the fixtures under /etc/nix-darwin/home/skills/simple-code/evals/files/. From evals.json use only each eval's name, prompt, and files. Never pass expected_output or expectations to a child run, and never paraphrase the prompt.

Output root: R as given at the end (create R/work and R/out if missing; another session running the other arm shares R).

## Child flags

Common to both arms:
  --permission-mode acceptEdits --no-session-persistence --output-format stream-json --verbose
  --allowedTools "Bash(go test *)" "Bash(go vet *)" "Bash(gofmt *)" "Bash(python3 *)" "Bash(rustc *)" <arm allows>
  --disallowedTools "Read(~/.agents/skills/simple-code/evals/**)" "Read(~/.claude/skills/simple-code/evals/**)" "Read(//etc/nix-darwin/home/skills/**)" "Read(//private/etc/nix-darwin/home/skills/**)" "Read(~/simple-code-evals/*/out/**)" "Read(~/simple-code-evals/*/grades*.tsv)" "Read(~/simple-code-evals/*/notes.tsv)" "Read(~/simple-code-evals/*/*report*.md)" "Read(~/simple-code-evals/*/*REPORT*.md)" <arm denies>

with-skill:
  extra flags: --add-dir ~/.agents/skills/simple-code --add-dir ~/.claude/skills/simple-code
  arm allows: none
  arm denies: none
  (Read allow rules don't work here: the skill dirs are symlinks into /nix/store, and headless Read outside the working dirs is refused. --add-dir was verified to allow SKILL.md while the evals/** deny still blocks evals.json.)

without-skill:
  extra flag: --disable-slash-commands
  arm allows: none
  arm denies: "Read(~/.agents/skills/simple-code/**)" "Read(~/.claude/skills/simple-code/**)"

## Smoke check (before the batch)

From an empty scratch dir, run with this arm's flags:
  claude -p "Read ~/.agents/skills/simple-code/SKILL.md and print its first line"
- with-skill: the read must succeed. without-skill: it must be denied.
If not, stop and report; the arm would be misconfigured.

## Batch

For each eval x model in [sonnet, opus] x repeat in [1, 2, 3] (30 runs; at most 4 concurrently; start each child with the Bash tool's run_in_background):
1. id=$(openssl rand -hex 4). W=R/work/$id. Copy the eval's files into W, keeping paths relative to evals/files/<name>/. In W: git init -q, git add -A, git commit -qm fixture, and save fixture=$(git rev-parse HEAD).
2. From W: timeout 900 claude -p "<eval prompt verbatim>" --model <model> <arm flags> > R/out/$id.jsonl 2> R/out/$id.err; save the exit code.
3. Extract the final assistant text from the jsonl's result event into R/out/$id.txt.
4. In W: git add -A; git diff --cached $fixture > R/out/$id.diff (diff against the fixture, so unasked commits are still captured).
5. Classify, from facts only:
   - outcome: timeout (exit 124), failed (other nonzero exit), no-change (no file outside build artifacts changed), ok (otherwise)
   - committed: yes if HEAD != $fixture
   - artifacts: yes if the diff touches __pycache__, *.pyc, *.rlib, *.o, or target/
   - skill_loaded: yes if the jsonl has a non-error tool_result for any of: a Skill tool_use for simple-code; a Read of a path ending simple-code/SKILL.md; a Bash tool_use whose command reads simple-code/SKILL.md (cat, head, sed, less, etc.). Otherwise no
6. Write "<eval name> <model> <repeat>" to R/out/$id.meta. Append "$id<TAB><arm><TAB><outcome><TAB><committed><TAB><artifacts><TAB><skill_loaded>" to R/key-<arm>.tsv.

Finish by reporting counts per outcome, and how many runs had skill_loaded=yes. For with-skill a low count means the treatment didn't reach the runs; for without-skill any yes means isolation leaked. Report this plainly.

Arguments (ARM and R):
