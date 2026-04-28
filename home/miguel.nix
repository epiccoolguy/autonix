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

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
    google.gemini-cli-vscode-ide-companion
  ];

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
