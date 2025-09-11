{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  home.username = "AS33AI";
  home.homeDirectory = "/Users/AS33AI";

  programs.git.userEmail = "miguel.lo-a-foe@nn.nl";

  home.sessionVariables = {
    NIX_SSL_CERT_FILE = "/Users/AS33AI/.config/ssl/ca-certificates.crt";
    NODE_EXTRA_CA_CERTS = "/Users/AS33AI/.config/ssl/ca-certificates.crt";
    REQUESTS_CA_BUNDLE = "/Users/AS33AI/.config/ssl/ca-certificates.crt";
    CURL_CA_BUNDLE = "/Users/AS33AI/.config/ssl/ca-certificates.crt";
    AWS_CA_BUNDLE = "/Users/AS33AI/.config/ssl/ca-certificates.crt";
  };
}
