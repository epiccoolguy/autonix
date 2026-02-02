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
CERT_DIR="$HOME/.config/ssl"
CERT="$CERT_DIR/ca-certificates.crt"
mkdir -p $CERT_DIR
security export -t certs -p -o "$CERT"

# tell nix to use the created bundle instead of its own
export NIX_SSL_CERT_FILE=$CERT

if ! type "nix" > /dev/null; then
  # download and install nix
  curl -fsSL https://nixos.org/nix/install | sh -s -- --yes

  # temporarily add configuration to use the created bundle
  echo "export NIX_SSL_CERT_FILE=$CERT" | sudo tee -a /etc/bashrc > /dev/null
  echo "export NIX_SSL_CERT_FILE=$CERT" | sudo tee -a /etc/zshrc > /dev/null
  echo "ssl-cert-file = $CERT" | sudo tee -a /etc/nix/nix.conf > /dev/null

  # restart nix-daemon after updating nix.conf
  sudo launchctl kickstart -k system/org.nixos.nix-daemon

  # load system-wide profile changes from nix
  . /etc/zprofile && . /etc/zshrc

fi

if [ -d  "/etc/nix-darwin" ]; then
  # update the nix config repository
  nix-shell -p git --run "git -C /etc/nix-darwin/ pull"
else
  # create default config dir for nix-darwin
  sudo mkdir -p /etc/nix-darwin
  sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
  # clone the nix config repository
  nix-shell -p git --run "git clone https://github.com/epiccoolguy/autonix /etc/nix-darwin"
fi

sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin

# install nix-darwin using flakes, rebuild the system and switch to the new generation
sudo -H NIX_SSL_CERT_FILE=$CERT nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch

echo 'Done setting up the system. Restart the shell for the "switch" command to become available.'
