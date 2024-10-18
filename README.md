# autonix

Automatically set up a system using Nix.

1. `xcode-select --install`
2. `sh <(curl -L https://nixos.org/nix/install)`
3. `source /etc/zshrc`
4. `nix-shell -p git --run 'git clone https://github.com/epiccoolguy/autonix ~/.config/nix'`
5. `nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ~/.config/nix`
6. `source /etc/zshenv && source /etc/zprofile && source /etc/zshrc`
7. `switch`