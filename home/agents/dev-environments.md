# Dev Environments

- No new devShells: tools come from PATH, which autonix provides (mlzw toolchain in `home/miguel.nix`). The mlzw repos are dropping theirs (mlzw-infra#454). A tool a `github.com/epiccoolguy` repo needs goes into autonix, in its own commit; any other repo: ask first.
- In JS repos pin Node.js and pnpm in `package.json` `devEngines` (`runtime` and `packageManager`, each with `onFail: "download"`), not the `packageManager` field - pnpm locks the resolved version in `pnpm-lock.yaml` and its `node` shim follows `runtime`.
- Until a repo's devShell is removed, use `nix develop --command <tool>` only where its CI or docs require the pinned version (mlzw-infra's checks); otherwise run tools directly. Agent shells never load direnv hooks.
- When configuring a versioned tool or library, fetch docs for that exact version.
- Format Nix with `nixfmt <file>` or `nixfmt-tree` (repo-wide); bare `nixfmt .` is deprecated.
- Never lower pnpm's `minimumReleaseAge`, disable `trustPolicy`, set `dangerouslyAllowAllBuilds`, or widen `allowBuilds` without asking.
- Commit `pnpm-lock.yaml` with the manifest changes that produced it; never hand-edit it. Resolve its merge conflicts by re-running `pnpm install` on the merged manifests. Trust pnpm's output and skip reviewing the lockfile diff unless something is unexpected (lockfile changes without a manifest change, unrelated packages moving, an install failure).
