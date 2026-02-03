{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  home.username = "test";
  home.homeDirectory = "/Users/test";
}
