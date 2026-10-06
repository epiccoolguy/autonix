Run a small A/B evaluation of the shared `simple-code` skill on the Antigravity CLI (`agy`). Only run it; do not open, judge, or grade any eval run's diff or output (setup and smoke diagnostics are fine, see the hard rules).

## Context
- The skill is deployed at ~/.agents/skills/simple-code/ and ~/.claude/skills/simple-code/ (SKILL.md and reference/; symlinks into /nix/store). ~/.gemini/GEMINI.md imports the shared global ~/AGENTS.md, which tells agents to read the skill for coding tasks.
- Where agy discovers skills natively is unverified (Gemini CLI uses ~/.gemini/skills and the ~/.agents/skills alias). Find out for the installed version before anything else.
- The skill was already tested on Claude models. This run answers two questions: does agy load the skill, and does the skill change the design on top of the AGENTS.md core? Use agy's default coding model (`agy models` lists them) and record it.

## Inputs
- /etc/nix-darwin/home/skills/simple-code/evals/evals.json and the fixtures under /etc/nix-darwin/home/skills/simple-code/evals/files/.
- Use only the evals named py-discounts and rust-cancel. From each, use only name, prompt, and files.
- Never expose expected_output or expectations to a child run, and never paraphrase the prompt.
- Output root R=~/simple-code-evals/run-antigravity-N, using the lowest N whose folder doesn't exist yet (create R/work and R/out).

## Do not touch configuration
- A PreToolUse hook syncs runtime permission changes from ~/.gemini/antigravity-cli/settings.json back into /etc/nix-darwin/home/antigravity/settings.json.
- Never approve "always allow" prompts, and never edit ~/.gemini config, settings, or hooks, in this session or in child runs.
- Use per-run flags or an external `sandbox-exec` profile instead (the first Antigravity run isolated both arms this way); never copy credential files into a temporary home.
- Afterwards, confirm `git -C /etc/nix-darwin status --short` shows nothing new from this work.

## Step 1: headless runs and isolation
Work out from `agy --help`, `agy help`, and the docs for the installed version how to:
1. Run one task headless (`agy -p` with `--output-format stream-json` looks right): it can edit files in its working dir (`--mode accept-edits`) and run python3 and rustc without prompting. Prefer `--sandbox` or a narrow grant over `--dangerously-skip-permissions`; if only the latter works, use it only inside the scratch work dirs and say so.
2. Capture a machine-readable log of every tool call and file read.
3. WITH-SKILL arm: the run can load the simple-code skill and read its SKILL.md and reference/** (e.g. `--add-dir` for the skill dirs, resolving the /nix/store symlink if needed).
4. WITHOUT-SKILL arm: the run can neither load nor read the skill (`--disable-slash-commands`, plus blocking reads of both skill paths), while GEMINI.md and the imported AGENTS.md still load, so both arms share the AGENTS.md core.
5. Both arms: the run cannot read the evals dir, R/out, or any other run's folder under ~/simple-code-evals; only its own working dir.

Prove the setup with smoke runs from an empty scratch dir:
- "Read ~/.agents/skills/simple-code/SKILL.md and print its first line" succeeds with-skill and fails without-skill (also try ~/.claude/skills/simple-code/SKILL.md in the without-skill arm).
- Reading /etc/nix-darwin/home/skills/simple-code/evals/evals.json fails in both arms.

If an arm can't be isolated, stop and report what you tried.

## Step 2: batch
For each eval x arm x repeat in [1, 2, 3] (12 runs; at most 4 concurrently; 15-minute timeout each, e.g. `--print-timeout 15m` plus `timeout 960`):
1. id=$(openssl rand -hex 4). W=R/work/$id. Copy the eval's files into W, keeping paths relative to evals/files/<name>/. In W: git init -q, git add -A, git commit -qm fixture, and save fixture=$(git rev-parse HEAD).
2. From W, run the eval prompt verbatim with this arm's setup. Save the log to R/out/$id.jsonl, stderr to R/out/$id.err, and the exit code.
3. Write the final agent message to R/out/$id.txt.
4. In W: git add -A; git diff --cached $fixture > R/out/$id.diff.
5. Classify from facts only:
   - outcome: timeout, failed (nonzero exit), no-change (nothing outside build artifacts changed), or ok
   - committed: yes if HEAD != $fixture
   - artifacts: yes if the diff touches __pycache__, *.pyc, *.rlib, *.o, or target/
   - skill_loaded: yes if the log shows the simple-code skill being loaded, or a successful read of simple-code/SKILL.md by any tool; otherwise no
6. Write "<eval name> <model> <repeat>" to R/out/$id.meta. Append "$id<TAB><arm><TAB><outcome><TAB><committed><TAB><artifacts><TAB><skill_loaded>" to R/key-<arm>.tsv, with arm being with-skill or without-skill.

## Report
- the model used, and where agy discovers skills natively
- outcome counts per arm
- skill_loaded counts per arm (with-skill should be high; any yes in without-skill means isolation leaked)
- the exact commands and flags used for each arm
- confirmation that /etc/nix-darwin is unchanged
- any doubt about isolation

Do not open the diffs.
