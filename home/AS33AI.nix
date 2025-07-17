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
}
