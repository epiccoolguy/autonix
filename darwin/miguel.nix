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
    "1password-cli"
    "antigravity-cli"
    "antigravity-ide"
    "claude"
    "claude-code@latest"
    "iina"
    "transmission"
  ];
}
