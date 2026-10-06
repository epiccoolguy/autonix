# Copilot eval harness (temporary)

Runs the simple-code A/B eval (py-discounts and rust-cancel, 2 arms x 3 repeats) on a machine with GitHub Copilot CLI. Remove this folder once the Copilot results are graded.

## On the Copilot machine

```
cd /etc/nix-darwin && git pull --ff-only && sudo darwin-rebuild switch --flake .
ls ~/.claude/skills/simple-code   # expect SKILL.md and reference/
mkdir -p ~/simple-code-evals && cd ~/simple-code-evals
copilot -i "$(cat /etc/nix-darwin/home/skills/simple-code/evals/harness/copilot-runner.md)"
```

When it reports done, package the results:

```
tar czf ~/run-copilot-1.tgz -C ~/simple-code-evals run-copilot-1
```

## On the grading machine (Claude Code)

Copy `run-copilot-1.tgz` over, then:

```
mkdir -p ~/simple-code-evals && tar xzf run-copilot-1.tgz -C ~/simple-code-evals
cd ~/simple-code-evals && claude "$(cat /etc/nix-darwin/home/skills/simple-code/evals/harness/grade.md)"
```
