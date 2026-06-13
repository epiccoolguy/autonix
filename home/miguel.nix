{
  config,
  pkgs,
  lib,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  vscodeDefaults = config.programs.vscode.profiles.default;
in
{
  imports = [ ./common.nix ];

  home.username = "miguel";
  home.homeDirectory = "/Users/miguel";

  home.packages = with pkgs; [
    claude-code
  ];

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
    google.gemini-cli-vscode-ide-companion
  ];

  # Reuse VS Code settings for Antigravity IDE (installed via homebrew cask)
  home.file = {
    "Library/Application Support/Antigravity IDE/User/settings.json".source =
      jsonFormat.generate "antigravity-ide-settings.json" vscodeDefaults.userSettings;

    "Library/Application Support/Antigravity IDE/User/keybindings.json".source =
      jsonFormat.generate "antigravity-ide-keybindings.json" (
        map (lib.filterAttrs (_: v: v != null)) vscodeDefaults.keybindings
      );

    "Library/Application Support/Antigravity IDE/User/snippets/global.code-snippets".source =
      jsonFormat.generate "antigravity-ide-global-snippets.json" vscodeDefaults.globalSnippets;
  };

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
