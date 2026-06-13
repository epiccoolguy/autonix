# Agent Instructions

Welcome, Agent. This document contains critical context for maintaining this repository. **You must read and adhere to these guidelines when proposing architectural changes, adding new applications, or altering the Nix configuration.**

## Repository Overview

This repository uses [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager) to manage macOS system configurations and dotfiles.

The configuration logic is split primarily between system-level config (`darwin/`) and user-level config (`home/`).

## Profiles

We have distinct user profiles that apply to different machines. It is strictly required to categorize applications and configurations correctly into the appropriate profiles.

### 1. `AS33AI` (Corporate Profile)
- This is the **corporate/work profile**.
- Applications, settings, and secrets that are specific to the corporate environment **MUST ONLY** be specified in this profile.
- Relevant files: `darwin/AS33AI.nix` and `home/AS33AI.nix`.

### 2. `miguel` (Personal Profile)
- This is the **personal profile**.
- Applications, games, and personal tools **MUST ONLY** be specified in this profile.
- Relevant files: `darwin/miguel.nix` and `home/miguel.nix`.

### 3. `test` (Virtual Machine)
- Used for testing inside virtual machines.
- Relevant files: `darwin/test.nix` and `home/test.nix`.

### 4. `common` (Shared Configuration)
- Configurations, standard utilities, and core packages that should exist on **both** corporate and personal machines belong here.
- Relevant files: `darwin/common.nix` and `home/common.nix`.

## Maintenance Guidelines

1. **Adding Applications**: When asked to add an application, always determine if it is for work (`AS33AI`), personal use (`miguel`), or shared (`common`). Do not install work-related VPNs or monitoring tools in the personal profile, and do not install personal entertainment/tools in the corporate profile.
2. **Updates & formatting**: Use `python3 scripts/update_flake_lock.py` to update flake inputs (as mentioned in the README).
3. **Flake Structure**: The `flake.nix` file ties the darwin configurations to specific hostnames (`Miguels-MacBook-Air`, `MPCE-MBP-HKDC2N1VJ4`, etc.). Be extremely cautious when modifying this file.
