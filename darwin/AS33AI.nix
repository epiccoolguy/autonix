{
  ...
}:
{
  imports = [ ./common.nix ];

  system.primaryUser = "AS33AI";

  # https://github.com/nix-community/home-manager/issues/6036
  users.users.AS33AI.home = "/Users/AS33AI";

  homebrew.brews = [
  ];
  homebrew.casks = [
    "soapui"
    "citrix-workspace"
  ];

  nix.extraOptions = ''
    ssl-cert-file = /usr/local/share/ca-certificates/cacerts.crt
  '';
}
