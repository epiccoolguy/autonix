{
  pkgs,
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
      "openssl"
      "powershell/tap/powershell"
    ];
    casks = [
      "drawio"
      "firefox"
      "ghostty"
      "git-credential-manager"
      "google-chrome"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.monaspace
  ];

  system.defaults = {
    NSGlobalDomain = {
      "com.apple.trackpad.scaling" = 3.0; # Set "Tracking speed" to "Fast"
      "com.apple.trackpad.forceClick" = true; # Enable "Force Click and haptic feedback"
      KeyRepeat = 2; # Set "Key repeat rate" to "Fast"
      InitialKeyRepeat = 15; # Set "Delay until repeat" to "Short"
      "com.apple.keyboard.fnState" = true; # "Use F1, F2, etc as standard function keys"
      NSDocumentSaveNewDocumentsToCloud = false; # Disable saving to iCloud by default
    };

    trackpad = {
      FirstClickThreshold = 2; # Set "Click" to "Firm"
    };

    dock = {
      tilesize = 16;
      magnification = true;
      largesize = 128;
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 1.0;
      show-recents = false;
      mru-spaces = false;
      expose-group-apps = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv";
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      NewWindowTarget = "Home";
    };

    spaces = {
      spans-displays = false;
    };

    screencapture = {
      disable-shadow = true; # Disable shadow in screenshots
    };
  };

  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs.config.allowUnfree = true;
}
