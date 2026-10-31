# Deploys & Cluster Access

- The dev/tst/acc/prd GitOps flow is pre-approved end-to-end: PRs, merges to master, acc/prd promotions, prd content writes, and release tags. The owning repo's `AGENTS.md` covers the mechanics.
- Direct cluster access (`kubectl`, Kubernetes MCP, `argocd`) is read-only: get/describe, logs, events. No restart, scale, sync, edit, or delete - make the change in git.
- Use the agent kubeconfig the cluster repo documents, never an admin one.
- Exception: when the owner grants elevated access (`~/.kube/agent-elevated.mlzw.config`, mlzw-infra decisions/0020), use it only for the task the owner named, per that repo's runbook, and run `scripts/grant-agent-elevated.sh --revoke` as soon as the task is done. Never grant it, and never run `op` or `mlzw-admin`: they need the owner's approval.
