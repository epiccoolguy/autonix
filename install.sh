#! /bin/zsh

if [ -z "$(xcode-select --print-path 2> /dev/null)" ];
then
  # inform softwareupdate to fetch command line tools
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

  # list software updates and return the latest command line tools (skipping potential beta listed first)
  PRODUCT=$(softwareupdate --list | grep "^\*.* Command Line Tools" | tail -n 1 | sed 's/^[^C]* //')

  # download and install command line tools
  softwareupdate --install --no-scan "$PRODUCT"

  # remove temporary file
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi

# create system certificate authority bundle to account for an HTTPS-intercepting man in the middle proxy
CA_BUNDLE_DIR="$HOME/.config/ssl"
CA_BUNDLE="$CA_BUNDLE_DIR/ca-bundle.crt"
mkdir -p $CA_BUNDLE_DIR
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > "$CA_BUNDLE"
security find-certificate -a -p /Library/Keychains/System.keychain >> "$CA_BUNDLE"

# tell nix to use the created bundle instead of its own
export NIX_SSL_CERT_FILE=$CA_BUNDLE

if ! type "nix" > /dev/null; then
  # download and install nix
  curl -fsSL https://nixos.org/nix/install | sh -s -- --yes

  echo "export NIX_SSL_CERT_FILE=$CA_BUNDLE" | sudo tee -a /etc/zshrc > /dev/null
  echo "export NIX_SSL_CERT_FILE=$CA_BUNDLE" | sudo tee -a /etc/bashrc > /dev/null
  echo "ssl-cert-file = $CA_BUNDLE" | sudo tee -a /etc/nix/nix.conf > /dev/null

  # restart nix-daemon after updating nix.conf
  sudo launchctl kickstart -k system/org.nixos.nix-daemon

  # load system-wide profile changes from nix
  . /etc/zprofile && . /etc/zshrc
fi

if [ ! -d  "$HOME/.config/nix" ]; then
  # clone the nix config repository
  nix-shell -p git --run "git clone https://github.com/epiccoolguy/autonix $HOME/.config/nix"
fi

# install nix-darwin using flakes, rebuild the system and switch to the new generation
nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake "$HOME/.config/nix#mac"

echo 'Done setting up the system. Restart the shell for the "switch" command to become available.'
