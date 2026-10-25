# Skill eval harness

Prompts that run a skill's A/B eval (with the skill vs without it, on top of the shared AGENTS.md) on each agent, then grade the results blind. Each skill keeps its evals in `home/skills/<skill>/evals/` (`evals.json` plus `files/`); this folder is not a skill and is not deployed. Nothing under a skill's `evals/` is deployed either, and every runner blocks eval runs from reading the evals folder.

| Agent | Prompt | Scope |
| --- | --- | --- |
| Claude Code | `claude-runner.md` | EVALS x MODELS (default Haiku, Sonnet, Opus), 3 repeats; one session per arm |
| Codex | `codex-runner.md` | EVALS, 3 repeats, both arms in one session |
| Antigravity (agy) | `antigravity-runner.md` | same as Codex |
| Copilot CLI | delivery check below | does Copilot load the skill in normal use? |

Every runner takes `SKILL` (for example `simple-testing`) and `EVALS` (comma-separated eval names, or `all`); the Claude runner also takes `ARM`, `R`, and optional `MODELS`. `rules.md` holds the hard rules every runner must follow: no delegation, a smoke-check gate (`R/SMOKE_PASSED`), setup diagnostics allowed, no credential copies, exact output layout, and narrow child tools. Always pass it before the runner. Each runner proves its isolation before the batch and writes to `~/skill-evals/<skill>/run-<agent>-N`. Grade with Claude: a different model grading avoids self-grading. For Codex and agy, pick 2-3 evals per round to keep runs short.

## Run

Pull and switch first so the deployed skill is current:

```
cd /etc/nix-darwin && git pull --ff-only && sudo darwin-rebuild switch --flake .
S=simple-testing
mkdir -p ~/skill-evals/$S && cd ~/skill-evals/$S
P=/etc/nix-darwin/home/skills/eval-harness
```

Claude Code (two sessions, in parallel, same R):

```
claude "$(cat $P/rules.md $P/claude-runner.md) ARM=with-skill R=~/skill-evals/$S/run-claude-1 SKILL=$S EVALS=all"
claude "$(cat $P/rules.md $P/claude-runner.md) ARM=without-skill R=~/skill-evals/$S/run-claude-1 SKILL=$S EVALS=all"
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
claude "$(cat $P/grade.md) SKILL=$S R=~/skill-evals/$S/run-codex-1"
```

To grade a run from another machine, package it there, copy it over, and grade it here:

```
tar czf ~/run-codex-1.tgz -C ~/skill-evals/$S run-codex-1                          # on the run machine
mkdir -p ~/skill-evals/$S && tar xzf run-codex-1.tgz -C ~/skill-evals/$S           # on the grading machine
```
