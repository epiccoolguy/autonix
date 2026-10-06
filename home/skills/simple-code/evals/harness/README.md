# simple-code eval harness

Prompts that run the simple-code A/B eval (with the skill vs without it, on top of the shared AGENTS.md) on each agent, then grade the results blind. Nothing under `evals/` is deployed, so agents never see these files unless they work in this repo, and every runner blocks eval runs from reading the evals folder.

| Agent | Prompt | Scope |
| --- | --- | --- |
| Claude Code | `claude-runner.md` | all 5 evals, Sonnet and Opus, 3 repeats; one session per arm |
| Codex | `codex-runner.md` | py-discounts and rust-cancel, 3 repeats, both arms in one session |
| Antigravity (agy) | `antigravity-runner.md` | same as Codex |
| Copilot CLI | delivery check below | does Copilot load the skill in normal use? |

`rules.md` holds the hard rules every runner must follow: no delegation, a smoke-check gate (`R/SMOKE_PASSED`), setup diagnostics allowed, no credential copies, exact output layout, and narrow child tools. Always pass it before the runner. Each runner proves its isolation before the batch and writes to `~/simple-code-evals/run-<agent>-N`. Grade with Claude: a different model grading avoids self-grading.

## Run

Pull and switch first so the deployed skill is current:

```
cd /etc/nix-darwin && git pull --ff-only && sudo darwin-rebuild switch --flake .
mkdir -p ~/simple-code-evals && cd ~/simple-code-evals
P=/etc/nix-darwin/home/skills/simple-code/evals/harness
```

Claude Code (two sessions, in parallel, same R):

```
claude "$(cat $P/rules.md $P/claude-runner.md) ARM=with-skill R=~/simple-code-evals/run-claude-1"
claude "$(cat $P/rules.md $P/claude-runner.md) ARM=without-skill R=~/simple-code-evals/run-claude-1"
```

Codex (the orchestrator must be unsandboxed; macOS can't nest sandboxes, and child runs keep their own):

```
codex -s danger-full-access -a on-request "$(cat $P/rules.md $P/codex-runner.md)"
```

Antigravity:

```
agy -i "$(cat $P/rules.md $P/antigravity-runner.md)"
```

## Copilot delivery check

Copilot's model family is already covered by the Codex run; what's specific to Copilot is whether it discovers the skill (from `~/.claude/skills`) in a normal session. No isolation needed:

```
mkdir -p ~/simple-code-evals/copilot-delivery && cd ~/simple-code-evals/copilot-delivery
cp -R /etc/nix-darwin/home/skills/simple-code/evals/files/py-discounts/. . && git init -q && git add -A && git commit -qm fixture
copilot
```

In that normal interactive session, give it this task:

```
Support discount codes in pricing: a code is either a percentage off or a fixed amount off the subtotal. Unknown or expired codes must be rejected, and the total can't go below zero. Marketing will likely ask for more discount types later.
```

The skill loaded if the transcript shows Copilot invoking the simple-code skill or reading `simple-code/SKILL.md`. To confirm from the session logs afterwards:

```
grep -rIl 'simple-code/SKILL.md' ~/.copilot 2>/dev/null
```

## Grade

Append the run folder to the grading prompt:

```
claude "$(cat $P/grade.md)~/simple-code-evals/run-codex-2"
```

To grade a run from another machine, package it there, copy it over, and grade it here:

```
tar czf ~/run-codex-2.tgz -C ~/simple-code-evals run-codex-2                    # on the run machine
mkdir -p ~/simple-code-evals && tar xzf run-codex-2.tgz -C ~/simple-code-evals   # on the grading machine
```
