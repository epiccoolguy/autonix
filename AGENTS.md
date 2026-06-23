# Agent Instructions

System config lives in `darwin/`, user config in `home/`. Read the profile rules before adding apps or editing the Nix config.

## Profiles

Every app and setting must go in the correct profile:

- **`common`** (`darwin/common.nix`, `home/common.nix`) — shared by all machines; the default home for new tools.
- **`AS33AI`** (`darwin/AS33AI.nix`, `home/AS33AI.nix`) — corporate/work; corporate-only apps and settings.
- **`miguel`** (`darwin/miguel.nix`, `home/miguel.nix`) — personal; apps banned from corporate.
- **`test`** (`darwin/test.nix`, `home/test.nix`) — VM testing.

Add new apps to `common` unless they're corporate-banned (→ `miguel`) or corporate-only (→ `AS33AI`). Never put work VPNs or monitoring tools in `miguel`.

## Maintenance

- Update flake inputs with `python3 scripts/update_flake_lock.py`.
- `flake.nix` maps hostnames (`Miguels-MacBook-Air`, `MPCE-MBP-HKDC2N1VJ4`, …) to configs — change it carefully.
