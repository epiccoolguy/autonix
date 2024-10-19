#! /bin/zsh

# inform softwareupdate to fetch command line tools
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

# list software updates and return the latest command line tools (skipping potential beta listed first)
PRODUCT=$(softwareupdate --list | grep "^\*.* Command Line Tools" | tail -n 1 | sed 's/^[^C]* //')
echo "$PRODUCT"

# download and install command line tools
softwareupdate --install --no-scan "$PRODUCT"

# remove temporary file
rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

# download and install nix
curl -fsSL https://nixos.org/nix/install | sh -s -- --yes

# load system-wide profile changes from nix
source /etc/zprofile && source /etc/zshrc

# install nix-darwin using flakes, rebuild the system and switch to the new generation
nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ~/.config/nix

# load system-wide profile changes from nix-darwin
source /etc/zshenv && source /etc/zprofile && source /etc/zshrc
