# Skill eval harness

Prompts that run a skill's A/B eval (with the skill vs without it, on top of the shared AGENTS.md) on each agent, then grade the results blind. Each skill keeps its evals in `home/skills/<skill>/evals/` (`evals.json` plus `files/`); this folder is not a skill and is not deployed. Nothing under a skill's `evals/` is deployed either, and every runner blocks eval runs from reading the evals folder.

| Agent | Prompt | Scope |
| --- | --- | --- |
| Claude Code | `claude-runner.md` | EVALS x MODELS (default Haiku, Sonnet, Opus), 3 repeats; one session per arm |
| Codex | `codex-runner.md` | EVALS, 3 repeats, both arms in one session |
| Antigravity (agy) | `antigravity-runner.md` | same as Codex |
| Copilot CLI | delivery check below | does Copilot load the skill in normal use? |

Every runner takes `SKILL` (for example `simple-testing`) and `EVALS` (comma-separated eval names, or `all`); the Claude runner also takes `ARM`, `R`, and optional `MODELS`. `rules.md` holds the hard rules every runner must follow: no delegation, a smoke-check gate per arm (`R/SMOKE_PASSED-<arm>`), setup diagnostics allowed, no credential copies, exact output layout, and narrow child tools. Always pass it before the runner. Each runner proves its isolation before the batch and writes to `~/skill-evals/<skill>/run-<agent>-N`. Grade with Claude: a different model grading avoids self-grading. For Codex and agy, pick 2-3 evals per round to keep runs short.

## Run

Pull and switch first so the deployed skill is current:

```
cd /etc/nix-darwin && git pull --ff-only && sudo darwin-rebuild switch --flake .
```

Claude Code: two sessions in parallel, one per terminal. `run-claude.sh` builds the whole prompt (rules, runner, arguments), so nothing has to be set in the terminal first. Add a run number as the third argument when run-claude-1 exists; override `EVALS` or `MODELS` from the environment.

```
/etc/nix-darwin/home/skills/eval-harness/run-claude.sh simple-testing with-skill
/etc/nix-darwin/home/skills/eval-harness/run-claude.sh simple-testing without-skill
```

The Claude children load no user settings or MCP servers (the user allow-list would pre-approve git, podman, kubectl, and web tools); AGENTS.md comes in through `--append-system-prompt-file`, and the with-skill arm gets the skill as a project skill. See `claude-runner.md`.

For Codex, agy, and grading other runs, set the variables in the same terminal as the command:

```
S=simple-testing; P=/etc/nix-darwin/home/skills/eval-harness
mkdir -p ~/skill-evals/$S && cd ~/skill-evals/$S
```

Codex (the orchestrator must be unsandboxed; macOS can't nest sandboxes, and child runs keep their own):

```
codex -s danger-full-access -a on-request "$(cat $P/rules.md $P/codex-runner.md) SKILL=$S EVALS=py-order-tests,go-flaky-worker"
```

Antigravity:

```
agy -i "$(cat $P/rules.md $P/antigravity-runner.md) SKILL=$S EVALS=py-order-tests,go-flaky-worker"
```

## Copilot delivery check

Copilot's model family is already covered by the Codex run; what's specific to Copilot is whether it discovers the skill (from `~/.claude/skills`) in a normal session. No isolation needed. Copy one eval's fixture and give Copilot that eval's prompt from `evals.json`:

```
E=py-order-tests
mkdir -p ~/skill-evals/$S/copilot-delivery && cd ~/skill-evals/$S/copilot-delivery
cp -R /etc/nix-darwin/home/skills/$S/evals/files/$E/. . && git init -q && git add -A && git commit -qm fixture
copilot
```

The skill loaded if the transcript shows Copilot invoking the skill or reading its `SKILL.md`. To confirm from the session logs afterwards:

```
grep -rIl "$S/SKILL.md" ~/.copilot 2>/dev/null
```

## Grade

```
/etc/nix-darwin/home/skills/eval-harness/run-claude.sh simple-testing grade    # Claude run 1
claude "$(cat $P/grade.md) SKILL=$S R=~/skill-evals/$S/run-codex-1"         # other runs, S and P set
```

To grade a run from another machine, package it there, copy it over, and grade it here:

```
tar czf ~/run-codex-1.tgz -C ~/skill-evals/$S run-codex-1                          # on the run machine
mkdir -p ~/skill-evals/$S && tar xzf run-codex-1.tgz -C ~/skill-evals/$S           # on the grading machine
```
