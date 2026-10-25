Run the <SKILL> skill evals on Claude Code. The arm (with-skill or without-skill), the output root R, SKILL, EVALS, and MODELS are given at the end of this message; `<SKILL>` below stands for the SKILL value. Only run them; do not open, judge, or grade any eval run's diff or output (setup and smoke diagnostics are fine, see the hard rules).

Inputs: /etc/nix-darwin/home/skills/<SKILL>/evals/evals.json and the fixtures under /etc/nix-darwin/home/skills/<SKILL>/evals/files/. From evals.json use only each eval's name, prompt, and files. Never pass expected_output or expectations to a child run, and never paraphrase the prompt.

Output root: R as given at the end (create R/work and R/out if missing; another session running the other arm shares R).

## Child flags

Common to both arms:
  --setting-sources project,local --strict-mcp-config --append-system-prompt-file ~/AGENTS.md
  --permission-mode acceptEdits --no-session-persistence --output-format stream-json --verbose
  --allowedTools "Bash(go test *)" "Bash(go vet *)" "Bash(gofmt *)" "Bash(python3 *)" "Bash(rustc *)" <arm allows>
  --disallowedTools "Read(~/.agents/skills/<SKILL>/evals/**)" "Read(~/.claude/skills/<SKILL>/evals/**)" "Read(//etc/nix-darwin/home/skills/**)" "Read(//private/etc/nix-darwin/home/skills/**)" "Read(~/skill-evals/<SKILL>/*/out/**)" "Read(~/skill-evals/<SKILL>/*/grades*.tsv)" "Read(~/skill-evals/<SKILL>/*/notes.tsv)" "Read(~/skill-evals/<SKILL>/*/*report*.md)" "Read(~/skill-evals/<SKILL>/*/*REPORT*.md)" <arm denies>

Why: user settings pre-approve git, podman, kubectl, MCP servers, and web tools, which breaks rule 6, so children load no user settings and no MCP servers. That also drops user skills and the `@~/AGENTS.md` import, so both arms get AGENTS.md through --append-system-prompt-file and the with-skill arm gets the skill as a project skill (batch step 1).

with-skill:
  extra flags: --add-dir ~/.agents/skills/<SKILL> --add-dir ~/.claude/skills/<SKILL> --add-dir <resolved /nix/store path of ~/.agents/skills/<SKILL>>
  arm allows: none
  arm denies: none
  (Read allow rules don't work here: the skill dirs are symlinks into /nix/store, and headless Read outside the working dirs is refused. --add-dir allows SKILL.md while the evals/** deny still blocks evals.json.)

without-skill:
  extra flag: --disable-slash-commands
  arm allows: none
  arm denies: "Read(~/.agents/skills/<SKILL>/**)" "Read(~/.claude/skills/<SKILL>/**)"

## Smoke check (before the batch)

Set up a scratch dir exactly like a batch working dir (step 1, with this arm's project-skill setup and an empty fixture), then run with this arm's flags and `--model haiku`, one prompt per check:
1. "Read ~/.agents/skills/<SKILL>/SKILL.md and print its first line": with-skill succeeds, without-skill is denied.
2. "Read /etc/nix-darwin/home/skills/<SKILL>/evals/evals.json": denied in both arms.
3. "Do your instructions contain the phrase GNU/Linux userland? yes or no": yes in both arms (AGENTS.md loaded).
4. "Run git --version, then podman --version, with Bash": both denied in both arms.
5. The init event lists no MCP servers, and lists <SKILL> among skills only in the with-skill arm.
If any check fails, stop and report; the arm would be misconfigured.

## Batch

For each eval in EVALS (every eval when EVALS=all) x model in MODELS (default haiku, sonnet, opus) x repeat in [1, 2, 3] (at most 4 concurrently; start each child with the Bash tool's run_in_background):
1. id=$(openssl rand -hex 4). W=R/work/$id. Copy the eval's files into W, keeping paths relative to evals/files/<name>/. In W: git init -q, then append `.claude/` to .git/info/exclude. with-skill only: mkdir -p W/.claude/skills and symlink W/.claude/skills/<SKILL> to the resolved /nix/store path of ~/.agents/skills/<SKILL>. Then git add -A, git commit -qm fixture, and save fixture=$(git rev-parse HEAD).
2. From W: timeout 900 claude -p "<eval prompt verbatim>" --model <model> <arm flags> > R/out/$id.jsonl 2> R/out/$id.err; save the exit code.
3. Extract the final assistant text from the jsonl's result event into R/out/$id.txt.
4. In W: git add -A; git diff --cached $fixture > R/out/$id.diff (diff against the fixture, so unasked commits are still captured).
5. Classify, from facts only:
   - outcome: timeout (exit 124), failed (other nonzero exit), no-change (no file outside build artifacts changed), ok (otherwise)
   - committed: yes if HEAD != $fixture
   - artifacts: yes if the diff touches __pycache__, *.pyc, *.rlib, *.o, or target/
   - skill_loaded: yes if the jsonl has a non-error tool_result for any of: a Skill tool_use for <SKILL>; a Read of a path ending <SKILL>/SKILL.md; a Bash tool_use whose command reads <SKILL>/SKILL.md (cat, head, sed, less, etc.). Otherwise no
6. Write "<eval name> <model> <repeat>" to R/out/$id.meta. Append "$id<TAB><arm><TAB><outcome><TAB><committed><TAB><artifacts><TAB><skill_loaded>" to R/key-<arm>.tsv.

Finish by reporting counts per outcome, and how many runs had skill_loaded=yes. For with-skill a low count means the treatment didn't reach the runs; for without-skill any yes means isolation leaked. Report this plainly.

Arguments (ARM, R, SKILL, EVALS, MODELS):
