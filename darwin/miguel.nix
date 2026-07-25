{
  ...
}:
{
  imports = [ ./common.nix ];

  system.primaryUser = "miguel";

  # https://github.com/nix-community/home-manager/issues/6036
  users.users.miguel.home = "/Users/miguel";

  homebrew.brews = [
    "wimlib"
  ];
  homebrew.casks = [
    "1password"
    "antigravity-cli"
    "antigravity-ide"
    "claude"
    "claude-code@latest"
    "iina"
    "transmission"
  ];

  # Force-install the Claude in Chrome extension (used by `claude --chrome`).
  # The native messaging host manifest and default-enable toggle are managed
  # by Claude Code itself on first `claude --chrome` run, not declaratively.
  system.defaults.CustomUserPreferences."com.google.Chrome" = {
    ExtensionInstallForcelist = [
      "fcoeoabgfenejglbffodgkkbkcdhcgfn;https://clients2.google.com/service/update2/crx"
    ];
  };
}
