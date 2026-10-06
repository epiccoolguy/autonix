Run a small A/B evaluation of the shared `simple-code` skill on GitHub Copilot CLI. Only run it; do not open, judge, or grade any diff or output.

## Context
- The skill is deployed at ~/.claude/skills/simple-code/ (SKILL.md and reference/; a symlink into /nix/store), which Copilot CLI discovers as a personal skill. The same files are also at ~/.agents/skills/simple-code/. ~/.copilot/copilot-instructions.md (the shared global AGENTS.md) tells agents to read the skill for coding tasks.
- The skill was already tested on Claude models through Claude Code. This run answers two questions: does Copilot CLI's harness actually load the skill, and does the skill change the design on top of the AGENTS.md core?
- Use the model Copilot CLI is configured to use for coding, and record it. If it's a Claude model, still run: the harness and skill delivery differ from Claude Code.

## Inputs
- /etc/nix-darwin/home/skills/simple-code/evals/evals.json and the fixtures under /etc/nix-darwin/home/skills/simple-code/evals/files/.
- Use only the evals named py-discounts and rust-cancel. From each, use only name, prompt, and files.
- Never expose expected_output or expectations to a child run, and never paraphrase the prompt.
- Output root R=~/simple-code-evals/run-copilot-N, using the lowest N whose folder doesn't exist yet (create R/work and R/out).

## Step 1: headless runs and isolation
Work out from `copilot --help` and the Copilot CLI docs for the installed version how to:
1. Run one task headless and non-interactive: it can edit files in its working dir and run python3 and rustc, with no approval prompts. Grant only those tools, not all tools.
2. Capture a machine-readable log of every tool call and file read (JSON output, or the session log Copilot writes).
3. WITH-SKILL arm: the run can load the simple-code skill and read its SKILL.md and reference/** (resolve the /nix/store symlink if path permissions need it).
4. WITHOUT-SKILL arm: the run can neither load nor read the skill (disable or hide the skill for the run and deny reads of both skill paths), while ~/.copilot/copilot-instructions.md still loads, so both arms share the AGENTS.md core.
5. Both arms: the run cannot read the evals dir, R/out, or any other run's folder under ~/simple-code-evals; only its own working dir.

Don't modify ~/.copilot config files or anything under /etc/nix-darwin. Use per-run flags or a temporary config dir.

If child runs fail with "sandbox_apply: Operation not permitted", this orchestrating session is itself sandboxed and macOS can't nest sandboxes. Stop and report it; the user restarts this session without a sandbox. Don't work around it by unsandboxing the child runs.

Prove the setup with smoke runs from an empty scratch dir:
- "Read ~/.claude/skills/simple-code/SKILL.md and print its first line" succeeds with-skill and fails without-skill (also check ~/.agents/skills/simple-code/SKILL.md in the without-skill arm).
- Reading /etc/nix-darwin/home/skills/simple-code/evals/evals.json fails in both arms.

If an arm can't be isolated, stop and report what you tried.

## Step 2: batch
For each eval x arm x repeat in [1, 2, 3] (12 runs; at most 4 concurrently; 15-minute timeout each):
1. id=$(openssl rand -hex 4). W=R/work/$id. Copy the eval's files into W, keeping paths relative to evals/files/<name>/. In W: git init -q, git add -A, git commit -qm fixture, and save fixture=$(git rev-parse HEAD).
2. From W, run the eval prompt verbatim with this arm's setup. Save the log to R/out/$id.jsonl (or the copied session log), stderr to R/out/$id.err, and the exit code.
3. Write the final agent message to R/out/$id.txt.
4. In W: git add -A; git diff --cached $fixture > R/out/$id.diff.
5. Classify from facts only:
   - outcome: timeout, failed (nonzero exit), no-change (nothing outside build artifacts changed), or ok
   - committed: yes if HEAD != $fixture
   - artifacts: yes if the diff touches __pycache__, *.pyc, *.rlib, *.o, or target/
   - skill_loaded: yes if the log shows the simple-code skill being loaded, or a successful read of simple-code/SKILL.md by any tool; otherwise no
6. Write "<eval name> <model> <repeat>" to R/out/$id.meta. Append "$id<TAB><arm><TAB><outcome><TAB><committed><TAB><artifacts><TAB><skill_loaded>" to R/key-<arm>.tsv, with arm being with-skill or without-skill.

## Report
- the model used
- outcome counts per arm
- skill_loaded counts per arm (with-skill should be high; any yes in without-skill means isolation leaked)
- the exact commands, flags, and config used for each arm
- any doubt about isolation

Do not open the diffs.
