{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  home.username = "miguel";
  home.homeDirectory = "/Users/miguel";

  programs.git.userEmail = "miguel@loafoe.dev";
}
