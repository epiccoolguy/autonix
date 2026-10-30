{
  pkgs,
  lib,
  config,
  ...
}:
let
  certDir = "/usr/local/share/ca-certificates";
  certPath = "${certDir}/cacerts.crt";
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
    credential."https://dev.azure.com" = {
      msauthUseDefaultAccount = true;
      msauthFlow = "system";
    };
  };

  # Corporate Artifactory PyPI mirror -- corporate-only (moved out of
  # common.nix, which broke uvx package resolution for personal-profile tools
  # off the corporate VPN). Only the AS33AI profile needs it.
  programs.uv.settings.index = [
    {
      name = "nn-pypi";
      publish-url = "https://artifactory.insim.biz/artifactory/api/pypi/nn-pypi";
      url = "https://artifactory.insim.biz/artifactory/api/pypi/nn-pypi/simple";
      default = true;
    }
  ];

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    github.copilot-chat
    sonarsource.sonarlint-vscode
  ];

  # Cmd+Shift+I opens a Copilot CLI session in the editor.
  programs.vscode.profiles.default.keybindings = [
  ];

  programs.vscode.profiles.default.userSettings = {
    "chat.defaultConfiguration" = {
      mode = "interactive";
      approvals = "allowAll";
    };
    "sonarlint.connectedMode.connections.sonarqube" = [
      {
        connectionId = "sonarqube.insim.biz";
        serverUrl = "https://sonarqube.insim.biz";
      }
    ];
  };

  home.file."Library/Application Support/Code/User/mcp.json" = {
    text = builtins.toJSON {
      servers.sonarqube = {
        type = "stdio";
        command = "docker";
        args = [
          "run"
          "--init"
          "--pull=always"
          "-i"
          "--rm"
          "-e"
          "SONARQUBE_TOKEN"
          "-e"
          "SONARQUBE_URL"
          "sonarsource/sonarqube-mcp"
        ];
        envFile = "${config.home.homeDirectory}/.env";
      };
    };
    force = true;
  };

  home.file."Library/Application Support/Code/User/instructions/sonarqube-pr.instructions.md".source =
    ./vscode/instructions/sonarqube-pr.instructions.md;

  home.activation.secureSonarEnvFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    envFile=${lib.escapeShellArg "${config.home.homeDirectory}/.env"}
    if [ -f "$envFile" ]; then
      chmod 0600 "$envFile"
    fi
  '';

  # Session variables rather than zsh initContent, so non-interactive shells
  # (agents' `zsh -c`, bash) trust the corporate CAs too.
  home.sessionVariables = {
    NIX_SSL_CERT_FILE = certPath;
    NODE_EXTRA_CA_CERTS = certPath;
    REQUESTS_CA_BUNDLE = certPath;
    CURL_CA_BUNDLE = certPath;
    AWS_CA_BUNDLE = certPath;
    JAVA_TOOL_OPTIONS = "-Djavax.net.ssl.trustStore=${trustStorePath} -Djavax.net.ssl.trustStorePassword=changeit";
  };

  # impure
  home.activation.exportKeychainCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    echo "Exporting macOS keychain certificates..." >&2
    mkdir -p ${lib.escapeShellArg certDir}
    ${security} export -t certs -p -k /System/Library/Keychains/SystemRootCertificates.keychain > ${lib.escapeShellArg certPath}
    ${security} export -t certs -p -k /Library/Keychains/System.keychain >> ${lib.escapeShellArg certPath}
    chmod 0644 ${lib.escapeShellArg certPath}
  '';

  # impure as well
  home.activation.buildJavaTrustStore = lib.hm.dag.entryAfter [ "exportKeychainCerts" ] ''
    set -euo pipefail
    echo "Importing macOS keychain certificates into Java trust store..." >&2
    jdkCacertsSrc=${pkgs.jdk}/lib/security/cacerts
    jdkMarkerPath=${lib.escapeShellArg trustStorePath}.jdk-src
    # Reseed from the JDK's bundled cacerts whenever pkgs.jdk changes (new store path), not just on first run.
    if [ ! -f ${lib.escapeShellArg trustStorePath} ] || [ "$(cat "$jdkMarkerPath" 2>/dev/null)" != "$jdkCacertsSrc" ]; then
      cp "$jdkCacertsSrc" ${lib.escapeShellArg trustStorePath}
      chmod 0644 ${lib.escapeShellArg trustStorePath}
      echo "$jdkCacertsSrc" > "$jdkMarkerPath"
    fi
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
