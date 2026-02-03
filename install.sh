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

# create default config dir for nix-darwin
NIX_DARWIN_DIR="/etc/nix-darwin"
sudo mkdir -p "$NIX_DARWIN_DIR"
sudo chown $(id -nu):$(id -ng) "$NIX_DARWIN_DIR"
find "$NIX_DARWIN_DIR" -mindepth 1 -delete

# create system certificate authority bundle to account for an HTTPS-intercepting man in the middle proxy
CERT_DIR="/usr/local/share/ca-certificates"
CERT_FILE="$CERT_DIR/cacerts.crt"
sudo mkdir -p "$CERT_DIR"
sudo chown $(id -nu):$(id -ng) "$CERT_DIR"
security export -t certs -p -o "$CERT_FILE"

# tell nix to use the created bundle instead of its own
export NIX_SSL_CERT_FILE=$CERT_FILE

if ! type "nix" > /dev/null; then
  # download and install nix
  curl -fsSL https://install.lix.systems/lix | sh -s -- install --enable-flakes --no-confirm --ssl-cert-file "$CERT_FILE"

  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin

cd "$NIX_DARWIN_DIR"

# install nix-darwin using flakes, rebuild the system and switch to the new generation
nix shell nixpkgs#git -c git clone https://github.com/epiccoolguy/autonix /etc/nix-darwin
sudo -H nix run nix-darwin#darwin-rebuild -- switch --flake /etc/nix-darwin

echo 'Done setting up the system. Restart the shell for the "switch" command to become available.'
