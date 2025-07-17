{
  config,
  inputs,
  ...
}:
{
  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    brews = [
      "mas"
      "openssl"
      "powershell/tap/powershell"
      "microsoft/mssql-release/mssql-tools18"
    ];
    casks = [
      "firefox"
      "google-chrome"
    ];
    masApps = {
    };
  };

}
