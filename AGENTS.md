# Agent Instructions

System config lives in `darwin/`, user config in `home/`. Read the profile rules before adding apps or editing the Nix config.

## Profiles

Every app and setting must go in the correct profile:

- **`common`** (`darwin/common.nix`, `home/common.nix`) - shared by all machines; the default home for new tools.
- **`AS33AI`** (`darwin/AS33AI.nix`, `home/AS33AI.nix`) - corporate/work; corporate-only apps and settings.
- **`miguel`** (`darwin/miguel.nix`, `home/miguel.nix`) - personal; apps banned from corporate.
- **`test`** (`darwin/test.nix`, `home/test.nix`) - VM testing.

Add new apps to `common` unless they're corporate-banned (-> `miguel`) or corporate-only (-> `AS33AI`). Never put work VPNs or monitoring tools in `miguel`.

## Commands

- Check: `darwin-rebuild build --flake .` (builds this machine's config without applying).
- Apply: `sudo darwin-rebuild switch --flake .` - needs sudo, so hand it to me.
- Format: `nixfmt-tree`.
- Don't run `nix flake update` unprompted; a daily workflow bumps inputs.
