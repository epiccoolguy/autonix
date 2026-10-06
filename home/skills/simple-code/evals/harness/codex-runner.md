Run a small A/B evaluation of the shared `simple-code` skill on Codex. Only run it; do not open, judge, or grade any eval run's diff or output (setup and smoke diagnostics are fine, see the hard rules).

## Context
- The skill is deployed at ~/.agents/skills/simple-code/ (SKILL.md and reference/; a symlink into /nix/store). ~/.codex/AGENTS.md (the shared global AGENTS.md) tells agents to read it for coding tasks.
- The skill was already tested on Claude models. This run answers two questions for Codex with its configured model (see ~/.codex/config.toml): does Codex actually load the skill, and does the skill change the design on top of the AGENTS.md core?

## Inputs
- /etc/nix-darwin/home/skills/simple-code/evals/evals.json and the fixtures under /etc/nix-darwin/home/skills/simple-code/evals/files/.
- Use only the evals named py-discounts and rust-cancel. From each, use only name, prompt, and files.
- Never expose expected_output or expectations to a child run, and never paraphrase the prompt.
- Output root R=~/simple-code-evals/run-codex-N, using the lowest N whose folder doesn't exist yet (create R/work and R/out).

## Step 1: headless runs and isolation
This orchestrating session is started with `-s danger-full-access` on purpose: macOS can't nest sandboxes, so a sandboxed orchestrator makes every child `codex sandbox`/`codex exec` fail with "sandbox_apply: Operation not permitted" (seen in the first Codex run, and confirmed to work outside a sandbox). Your own commands are therefore unsandboxed, so keep them to setup and bookkeeping inside ~/simple-code-evals. Every child eval run must apply its own sandbox; no child may use danger-full-access or a bypass flag.

Work out from `codex --help`, `codex exec --help`, and the Codex docs for the installed version how to:
1. Run one task headless and non-interactive: it can edit files in its working dir and run python3 and rustc, with no approval prompts and no network.
2. Capture a machine-readable log of every command and file read (e.g. JSON event output).
3. WITH-SKILL arm: the run can load and read ~/.agents/skills/simple-code/SKILL.md and reference/** (resolve the /nix/store symlink if the sandbox needs it).
4. WITHOUT-SKILL arm: the run can neither load nor read the skill (disable skill discovery for the run and block reads of the skill dir), while ~/.codex/AGENTS.md still loads, so both arms share the AGENTS.md core.
5. Both arms: the run cannot read the evals dir, R/out, or any other run's folder under ~/simple-code-evals; only its own working dir.

Don't modify ~/.codex/config.toml or anything under /etc/nix-darwin. Use per-run flags or `-c` overrides (the first Codex run isolated both arms this way, without a temporary CODEX_HOME).

Prove the setup with smoke runs from an empty scratch dir:
- "Read ~/.agents/skills/simple-code/SKILL.md and print its first line" succeeds with-skill and fails without-skill.
- Reading /etc/nix-darwin/home/skills/simple-code/evals/evals.json fails in both arms.

If an arm can't be isolated, stop and report what you tried.

## Step 2: batch
For each eval x arm x repeat in [1, 2, 3] (12 runs; at most 4 concurrently; 15-minute timeout each):
1. id=$(openssl rand -hex 4). W=R/work/$id. Copy the eval's files into W, keeping paths relative to evals/files/<name>/. In W: git init -q, git add -A, git commit -qm fixture, and save fixture=$(git rev-parse HEAD).
2. From W, run the eval prompt verbatim with this arm's setup. Save the event log to R/out/$id.jsonl, stderr to R/out/$id.err, and the exit code.
3. Write the final agent message to R/out/$id.txt.
4. In W: git add -A; git diff --cached $fixture > R/out/$id.diff.
5. Classify from facts only:
   - outcome: timeout, failed (nonzero exit), no-change (nothing outside build artifacts changed), or ok
   - committed: yes if HEAD != $fixture
   - artifacts: yes if the diff touches __pycache__, *.pyc, *.rlib, *.o, or target/
   - skill_loaded: yes if the log shows a successful read of simple-code/SKILL.md by any tool, or Codex's skill mechanism loading simple-code; otherwise no
6. Write "<eval name> <model> <repeat>" to R/out/$id.meta. Append "$id<TAB><arm><TAB><outcome><TAB><committed><TAB><artifacts><TAB><skill_loaded>" to R/key-<arm>.tsv, with arm being with-skill or without-skill.

## Report
- outcome counts per arm
- skill_loaded counts per arm (with-skill should be high; any yes in without-skill means isolation leaked)
- the exact commands, flags, and profile used for each arm
- any doubt about isolation

Do not open the diffs.
