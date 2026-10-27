# Delivery

Ship small, frequent changes through one automated path to production; no freezes [CD: The Problem of Delivering Software; Accelerate]. CI test tiers, the deploy check, and the done gate belong to simple-testing; how a repository deploys (tools, environments, hooks) belongs to its decision records.

## Pipeline

- One path to production: every change, including config and hotfixes, goes through the pipeline; nothing deploys by hand [CD: Deploying and Releasing Applications; Pragmatic: Pragmatic Starter Kit].
- Build an artifact once, reproducibly with a pinned toolchain, and promote that same artifact by digest. Version deployables by git SHA, libraries and contracts by semver [CD: Only Build Your Binaries Once; Twelve-Factor: Build, Release, Run].
- Deploy automatically to the first environment and promote automatically when the previous environment's deploy check passes; this relies on the deploy check, expand/contract migrations, and a working rollback. A manual gate needs a decision record [Accelerate].
- Roll back by default when the cause is not obvious: a new commit pointing at the last digest healthy in that environment, never an out-of-band rollback. Fix forward when the fix is small and the pipeline fast, or when rollback is unsafe (a contract step ran, data is in a new format) [CD: Deploying and Releasing Applications].
- Migrations run as a separate, serialized step (a job or init step under a lock) that completes before the new version serves, never inside the application process. They stay backward-compatible: expand, then contract [CD: Managing Data; DDIA: Encoding and Evolution].
- Progressive delivery (canary, blue-green) only with replicas and a rollout tool that supports it.
- Reference a shared pipeline (reusable workflows, templates) by an immutable ref (SHA or tag) and upgrade it through the update bot like any dependency.
- Measure the pipeline's critical path before changing CI infrastructure and fix the longest stage first. Aim for about 10 minutes from PR to deployed in the first environment [Ousterhout: Designing for Performance; Fowler: Continuous Integration].
- Prefer that no runner reaches production: CI writes to git and the environment pulls. A runner that must is ephemeral, least-privilege, uses short-lived credentials, and never runs untrusted code [SLSA].

## Branches and flags

- Integrate into the main branch at least daily; a branch lives hours, at most about two days. Larger work merges in dark steps: unwired code, branch by abstraction, expand/contract [Fowler: Continuous Integration; Hammant: Trunk-Based Development].
- Add a release flag only when a change cannot ship dark. It lives in config, has a removal issue with a date, and is deleted with its dead path once fully on. No flag service until a real need [Hodgson: Feature Toggles].

## Environments, config, secrets

- Environments differ only in config and scale: the same artifact and manifests plus a per-environment overlay [Twelve-Factor: Dev/Prod Parity]. Each environment between the first and production names in a decision record what it catches that the previous cannot; the default is one pre-production environment.
- No production personal data outside production; use synthetic or anonymized data.
- Everything that defines an environment (manifests, config, infrastructure, secret references) is in version control and changes only through the pipeline. A reconciler reverts drift; where none runs, a scheduled drift check (such as a plan) alerts [OpenGitOps; CD: Configuration Management].
- Git holds only secret references or encrypted values; the environment pulls secrets from a secret store. Prefer short-lived workload identity over stored keys.
- Break-glass: the owner only, only to restore service; the change is folded back into git and reconciliation re-enabled the same day.

## Supply chain

- Every input resolves to an immutable version: lockfiles committed and enforced in CI, base images and CI actions or templates by digest or SHA. How they move is in [capabilities](capabilities.md#upgrades) [OpenSSF Scorecard].
- Scan dependencies and images on every PR and, on a schedule, the deployed artifacts. Gate only on fixable high or critical findings; report the rest. Every exception has a reason and an expiry date.
- Sign artifacts and attach build provenance only together with verification at deploy; unverified signing is skipped [SLSA; Sigstore].
