{
  config,
  pkgs,
  lib,
  ...
}:
let
  certDir = "${config.home.homeDirectory}/.config/ssl";
  certPath = "${certDir}/ca-certificates.crt";
  trustStorePath = "${certDir}/java-truststore.jks";
  security = "/usr/bin/security";
  awk = "/usr/bin/awk";
  openssl = "${pkgs.openssl}/bin/openssl";
  keytool = "${pkgs.jdk}/bin/keytool";
in
{
  imports = [ ./common.nix ];

  home.username = "AS33AI";
  home.homeDirectory = "/Users/AS33AI";

  programs.git.settings.user.email = "miguel.lo-a-foe@nn.nl";

  programs.git.settings = {
    credential."https://gitlab.insim.biz".useHttpPath = false;
  };

  # after zshGeneralConfig (1000)
  programs.zsh.initContent = lib.mkOrder 1100 ''
    # --- AS33AI environment exports (after general config) ---
    export NIX_SSL_CERT_FILE=${lib.escapeShellArg certPath}
    export NODE_EXTRA_CA_CERTS="$NIX_SSL_CERT_FILE"
    export REQUESTS_CA_BUNDLE="$NIX_SSL_CERT_FILE"
    export CURL_CA_BUNDLE="$NIX_SSL_CERT_FILE"
    export AWS_CA_BUNDLE="$NIX_SSL_CERT_FILE"
    export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=${trustStorePath} -Djavax.net.ssl.trustStorePassword=changeit"
  '';

  # impure
  home.activation.exportKeychainCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    echo "Exporting macOS keychain certificates..." >&2
    mkdir -p ${lib.escapeShellArg certDir}
    ${security} export -t certs -p -o ${lib.escapeShellArg certPath}
    chmod 0644 ${lib.escapeShellArg certPath}
  '';

  # impure as well
  home.activation.buildJavaTrustStore = lib.hm.dag.entryAfter [ "exportKeychainCerts" ] ''
    set -euo pipefail
    echo "Importing macOS keychain certificates into Java trust store..." >&2
    cp ${pkgs.jdk}/lib/security/cacerts ${lib.escapeShellArg trustStorePath}
    chmod 0644 ${lib.escapeShellArg trustStorePath}
    imported=0
    workdir=$(mktemp -d)
    trap 'rm -rf "$workdir"' EXIT

    cp ${lib.escapeShellArg certPath} "$workdir/bundle.pem"

    ${awk} 'BEGIN{n=0;out=""}
      /-----BEGIN CERTIFICATE-----/ {out=$0;next}
      /-----END CERTIFICATE-----/ {out=out"\n"$0; n++; file=sprintf("%s/cert_%04d.pem", d, n); print out > file; close(file); out=""; next}
      { if(out!="") out=out"\n"$0 }
    ' d="$workdir" ${lib.escapeShellArg certPath}

    for c in "$workdir"/cert_*.pem; do
      [ -s "$c" ] || continue
      fp=$(${openssl} x509 -in "$c" -noout -fingerprint -sha256 | sed 's/.*=//;s/://g')
      alias=hm-$fp
      # Suppress normal output of list (stdout), keep stderr for errors
      if ! ${keytool} -list -keystore ${lib.escapeShellArg trustStorePath} -storepass changeit -alias "$alias" >/dev/null; then
        if ${keytool} -importcert -noprompt -trustcacerts -alias "$alias" -file "$c" -keystore ${lib.escapeShellArg trustStorePath} -storepass changeit >/dev/null 2>&1; then
          imported=$((imported+1))
        fi
      fi
    done
    echo "...$imported certificates imported into ${trustStorePath}." >&2
  '';
}
