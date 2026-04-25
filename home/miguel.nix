{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  home.username = "miguel";
  home.homeDirectory = "/Users/miguel";

  home.packages = with pkgs; [
    claude-code
    gemini-cli
  ];

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
