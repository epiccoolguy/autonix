# Deploys & Cluster Access

- The dev/tst/acc/prd GitOps flow is pre-approved end-to-end: PRs, merges to master, acc/prd promotions, prd content writes, and release tags. The owning repo's `AGENTS.md` covers the mechanics.
- Direct cluster access (`kubectl`, Kubernetes MCP, `argocd`) is read-only: get/describe, logs, events. No restart, scale, sync, edit, or delete - make the change in git.
- Use the agent kubeconfig the cluster repo documents, never an admin one.
