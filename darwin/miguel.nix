{
  ...
}:
{
  imports = [ ./common.nix ];

  system.primaryUser = "miguel";

  # https://github.com/nix-community/home-manager/issues/6036
  users.users.miguel.home = "/Users/miguel";

  homebrew.brews = [
    "waydabber/betterdisplay/betterdisplaycli"
    "wimlib"
  ];
  homebrew.casks = [
    "1password"
    "betterdisplay"
    "iina"
    "transmission"
  ];
  homebrew.masApps = {
    "WireGuard" = 1451685025;
  };
}
