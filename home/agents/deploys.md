# Deploys & Cluster Access

- GitOps is the only path that changes cluster state. The dev/tst/acc/prd flow is pre-approved: PRs, merges to master, re-pinning `overlays/acc` and `overlays/prd`, prd promotions and content writes, `vX.Y.Z` tags.
- Direct cluster access (`kubectl`, Kubernetes MCP, `argocd`) is read-only: get/describe, logs, events. No restart, scale, sync, edit, or delete - make the change in git.
- Use `~/.kube/agent.mlzw.config` (revocable token; re-mint with mlzw-cluster's `scripts/build-agent-kubeconfig.sh` when expired).
