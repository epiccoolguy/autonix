# autonix

Automatically set up a system using Nix.

1. Sign into the App Store
2. Install [Xcode](https://apps.apple.com/en/app/xcode/id497799835) from the App Store
3. Run:

   ```sh
   /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/epiccoolguy/autonix/HEAD/install.sh)"
   ```

   In case you are behind a corporate VPN that intercepts all TLS traffic with a man-in-the-middle attack:

   ```sh
   /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/epiccoolguy/autonix/HEAD/install.sh)" --ca-bundle
   ```

Update using the following command:

```sh
python3 scripts/update_flake_lock.py
switch
```

The repository also runs a daily GitHub Action that refreshes `flake.lock`, skips any source newer than 24 hours, validates the updated flake on macOS, and opens a pull request when the filtered lockfile changes.

## Linux-like command line

The shell stays zsh, but `home.packages` puts the GNU/Linux userland (coreutils, findutils, grep, sed, awk, tar, util-linux, procps, ...) ahead of Apple's BSD tools in `PATH`, so commands and scripts behave as on a Linux machine and the package list can be shared with a future Linux host. Agents get bash-compatible behavior too: Claude Code runs its commands in nix bash 5, Codex and Antigravity use zsh, which passes unmatched globs through like bash (`NO_NOMATCH`), and Copilot CLI hard-codes `/bin/bash` 3.2. None of the others follow `$SHELL`. Scripts use `#!/usr/bin/env bash`, never `/bin/bash` (3.2).

Where macOS has no Linux counterpart, or its native tool is better, the native one stays:

| Linux | macOS native | Why native |
| --- | --- | --- |
| OpenSSH | `/usr/bin/ssh` | Keychain and security-key (`ssh-keychain.dylib`) integration |
| `nc` (netcat-openbsd) | `/usr/bin/nc` | Already OpenBSD-derived; nixpkgs' netcat-openbsd does not build on darwin |
| `vim`, `xxd` | `/usr/bin/vim`, `/usr/bin/xxd` | Same upstream; `neovim` is the editor |
| `ps`, `top`, `sysctl` | `/bin/ps`, `/usr/bin/top`, `/usr/sbin/sysctl` | Kernel-specific; nixpkgs `procps` links Apple's on darwin (adds GNU `watch`) |
| `ip`, `ss`, `ifconfig` (net-tools) | `/sbin/ifconfig`, `netstat`, `networksetup`, `route` | iproute2 is Linux-only; inetutils' `ifconfig` (first in `PATH`) omits MAC, IPv6 and link status |
| `free`, `lscpu`, `lsblk` | `vm_stat`, `sysctl hw`, `diskutil list` | Linux `/proc` and `/sys` interfaces |
| `strace`, `ldd` | `dtruss`, `otool -L` | Linux syscall and ELF tooling |
| `systemctl`, `journalctl` | `launchctl`, `log show` | systemd vs launchd |
| `useradd`, `chattr`, `locate` | `dscl`/`sysadminctl`, `chflags`, `mdfind` | Platform-specific user, file-flag and index tooling |
| `xdg-open`, `xclip` | `open`, `pbcopy`/`pbpaste` | Desktop integration |

## AI Agent Maintenance

This repository is optimized for maintenance by AI coding assistants. Agents must read the [AGENTS.md](AGENTS.md) file before proposing architectural changes, adding new applications, or making changes to the Nix configuration.
