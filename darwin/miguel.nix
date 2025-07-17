{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  # https://github.com/nix-community/home-manager/issues/6036
  users.users.miguel.home = "/Users/miguel";
}
