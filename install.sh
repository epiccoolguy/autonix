#! /bin/sh

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

# launch a new shell to load system-wide profile changes from nix
exec zsh
