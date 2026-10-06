# simple-code eval harness

Prompts that run the simple-code A/B eval (with the skill vs without it, on top of the shared AGENTS.md) on each agent, then grade the results blind. Nothing under `evals/` is deployed, so agents never see these files unless they work in this repo, and every runner blocks eval runs from reading the evals folder.

| Agent | Runner | Scope |
| --- | --- | --- |
| Claude Code | `claude-runner.md` | all 5 evals, Sonnet and Opus, 3 repeats; one session per arm |
| Codex | `codex-runner.md` | py-discounts and rust-cancel, 3 repeats, both arms in one session |
| Copilot CLI | `copilot-runner.md` | same as Codex |
| Antigravity (agy) | `antigravity-runner.md` | same as Codex |

Each runner proves its isolation with smoke runs before the batch and writes to `~/simple-code-evals/run-<agent>-N`. Grade with Claude: a different model grading avoids self-grading.

## Run

Pull and switch first so the deployed skill is current:

```
cd /etc/nix-darwin && git pull --ff-only && sudo darwin-rebuild switch --flake .
mkdir -p ~/simple-code-evals && cd ~/simple-code-evals
P=/etc/nix-darwin/home/skills/simple-code/evals/harness
```

Claude Code (two sessions, in parallel, same R):

```
claude "$(cat $P/claude-runner.md) ARM=with-skill R=~/simple-code-evals/run-claude-1"
claude "$(cat $P/claude-runner.md) ARM=without-skill R=~/simple-code-evals/run-claude-1"
```

Codex (the orchestrator must be unsandboxed; macOS can't nest sandboxes, and child runs keep their own):

```
codex -s danger-full-access -a on-request "$(cat $P/codex-runner.md)"
```

Copilot CLI:

```
copilot -i "$(cat $P/copilot-runner.md)"
```

Antigravity:

```
agy -i "$(cat $P/antigravity-runner.md)"
```

## Grade

Append the run folder to the grading prompt:

```
claude "$(cat $P/grade.md)~/simple-code-evals/run-codex-2"
```

On another machine (e.g. Copilot on the corporate laptop), package the run, copy it over, and grade it here:

```
tar czf ~/run-copilot-1.tgz -C ~/simple-code-evals run-copilot-1           # on the run machine
mkdir -p ~/simple-code-evals && tar xzf run-copilot-1.tgz -C ~/simple-code-evals   # on the grading machine
```
