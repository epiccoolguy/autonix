# Dev Environments

- Repos under `github.com/epiccoolguy` get a repo-root devShell pinning the toolchain - extend an existing `flake.nix`/`shell.nix` before creating one. Any other repo: ask first.
- Exception: in JS repos Node.js comes from `devEngines.runtime` in `package.json` (pnpm's `node` shim follows it); don't add `nodejs` to the devShell, which pins only the non-JS toolchain.
- Machines are managed by nix-darwin + home-manager (repo `/etc/nix-darwin`): global packages come from nix; brew only for GUI apps or tools missing from nixpkgs.
- Never edit `/etc/nix-darwin` to make a project tool available; propose global promotion only for cross-repo, version-independent tools, with my approval.
- Invoke project tools per-command as `nix develop --command <tool>` or `direnv exec . <tool>` - agent shells are fresh non-interactive processes, so direnv hooks never apply. You may `direnv allow` an `.envrc` you wrote yourself; ask before allowing a pre-existing one.
- Commit `flake.nix`, `flake.lock`, `.envrc`. Verify a new devShell with `nix flake check` plus one real tool run; flag nixpkgs version drift rather than silently accepting it.
- When configuring a versioned tool or library, fetch docs for that exact version.
- Format Nix with `nixfmt <file>` or `nixfmt-tree` (repo-wide); bare `nixfmt .` is deprecated.
- Never lower pnpm's `minimumReleaseAge`, disable `trustPolicy`, set `dangerouslyAllowAllBuilds`, or widen `allowBuilds` without asking.
- Commit `pnpm-lock.yaml` with the manifest changes that produced it; never hand-edit it. Resolve its merge conflicts by re-running `pnpm install` on the merged manifests. Trust pnpm's output and skip reviewing the lockfile diff unless something is unexpected (lockfile changes without a manifest change, unrelated packages moving, an install failure).
