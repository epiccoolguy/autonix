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

## AI Agent Maintenance

This repository is optimized for maintenance by AI coding assistants. Agents must read the [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md) file before proposing architectural changes, adding new applications, or making changes to the Nix configuration.
