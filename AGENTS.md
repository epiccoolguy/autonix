# Agent Instructions

## Profiles

Every app and setting belongs to exactly one profile: `common` (all machines), `AS33AI` (corporate), `miguel` (personal), or `test` (VM testing).

Add new apps to `common` unless they're corporate-banned (-> `miguel`) or corporate-only (-> `AS33AI`). Never put work VPNs or monitoring tools in `miguel`.

Install via nix by default. Use Homebrew casks for GUI apps and fast-moving tools such as agent CLIs, where nixpkgs lags; `brews` only for formulae missing from nixpkgs.

## Commands

- Applying (`sudo darwin-rebuild switch --flake .`) needs sudo - hand it to me.
- Don't run `nix flake update` unprompted; a daily workflow bumps inputs.
