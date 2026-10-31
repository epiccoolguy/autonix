# Dev Environments

- No devShells: tools come from PATH, which autonix provides (mlzw toolchain in `home/miguel.nix`). A tool a `github.com/epiccoolguy` repo needs goes into autonix, in its own commit; any other repo: ask first.
- In JS repos pin Node.js and pnpm in `package.json` `devEngines` (`runtime` and `packageManager`, each with `onFail: "download"`), not the `packageManager` field - pnpm locks the resolved version in `pnpm-lock.yaml` and its `node` shim follows `runtime`.
- Run tools directly; the mlzw repos have no devShells left (mlzw-infra#454). mlzw-infra's CI pins its toolchain in `images/actions-runner/ci-tools.sh`.
- When configuring a versioned tool or library, fetch docs for that exact version.
- Format Nix with `nixfmt <file>` or `nixfmt-tree` (repo-wide); bare `nixfmt .` is deprecated.
- Never lower pnpm's `minimumReleaseAge`, disable `trustPolicy`, set `dangerouslyAllowAllBuilds`, or widen `allowBuilds` without asking.
- Commit `pnpm-lock.yaml` with the manifest changes that produced it; never hand-edit it. Resolve its merge conflicts by re-running `pnpm install` on the merged manifests. Trust pnpm's output and skip reviewing the lockfile diff unless something is unexpected (lockfile changes without a manifest change, unrelated packages moving, an install failure).
