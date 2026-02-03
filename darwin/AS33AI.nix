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
  ];

  nix.extraOptions = ''
    ssl-cert-file = /Users/AS33AI/.config/ssl/ca-certificates.crt
  '';
}
