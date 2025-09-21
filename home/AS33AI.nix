{ config, lib, ... }:
let
  certDir = "${config.home.homeDirectory}/.config/ssl";
  certPath = "${certDir}/ca-certificates.crt";
in
{
  imports = [ ./common.nix ];

  home.username = "AS33AI";
  home.homeDirectory = "/Users/AS33AI";

  programs.git.userEmail = "miguel.lo-a-foe@nn.nl";

  programs.git.extraConfig = {
    credential."https://gitlab.insim.biz".useHttpPath = false;
  };

  home.sessionVariables = {
    NIX_SSL_CERT_FILE = certPath;
    NODE_EXTRA_CA_CERTS = certPath;
    REQUESTS_CA_BUNDLE = certPath;
    CURL_CA_BUNDLE = certPath;
    AWS_CA_BUNDLE = certPath;
  };

  # impure
  home.activation.exportKeychainCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    echo "Exporting macOS keychain certificates..." >&2
    mkdir -p ${lib.escapeShellArg certDir}
    /usr/bin/security export -t certs -p -o ${lib.escapeShellArg certPath}
    chmod 0644 ${lib.escapeShellArg certPath}
  '';
}
