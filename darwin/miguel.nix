{
  ...
}:
{
  imports = [ ./common.nix ];

  system.primaryUser = "miguel";

  # https://github.com/nix-community/home-manager/issues/6036
  users.users.miguel.home = "/Users/miguel";

  homebrew.brews = [
    # Not nixpkgs: its Rust vibe-rs is not in cache.nixos.org for darwin, so every
    # flake update compiled it locally; the formula is bottled.
    "mistral-vibe"
    "wimlib"
  ];
  homebrew.casks = [
    "1password"
    "1password-cli"
    "antigravity-cli"
    "balenaetcher"
    "claude"
    "claude-code@latest"
    "codex"
    "iina"
    "transmission"
  ];
}
