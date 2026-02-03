{
  ...
}:
{
  imports = [ ./common.nix ];

  system.primaryUser = "test";

  # https://github.com/nix-community/home-manager/issues/6036
  users.users.test.home = "/Users/test";

  homebrew.brews = [ ];
  homebrew.casks = [ ];
}
