{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  home.username = "miguel";
  home.homeDirectory = "/Users/miguel";

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
