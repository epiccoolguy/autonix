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
    antigravity-cli
  ];

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
    google.gemini-cli-vscode-ide-companion
  ];

  programs.antigravity = {
    enable = true;
    profiles.default = {
      userSettings = config.programs.vscode.profiles.default.userSettings;
      keybindings = config.programs.vscode.profiles.default.keybindings;
      extensions = config.programs.vscode.profiles.default.extensions;
      globalSnippets = config.programs.vscode.profiles.default.globalSnippets;
    };
  };

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
