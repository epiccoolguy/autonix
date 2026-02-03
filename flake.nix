{
  description = "Miguel's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;
    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
    homebrew-powershell.url = "github:PowerShell/Homebrew-Tap";
    homebrew-powershell.flake = false;
    homebrew-mssql.url = "github:microsoft/homebrew-mssql-release";
    homebrew-mssql.flake = false;
    homebrew-betterdisplay.url = "github:waydabber/homebrew-betterdisplay";
    homebrew-betterdisplay.flake = false;
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      mac-app-util,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      homebrew-powershell,
      homebrew-mssql,
      homebrew-betterdisplay,
      nix-vscode-extensions,
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .
      darwinConfigurations = {
        "tests-Virtual-Machine" = nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin/test.nix
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              nixpkgs.overlays = [
                inputs.nix-vscode-extensions.overlays.default
              ];
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.test = import ./home/test.nix;
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = "test";
                enable = true;
                enableRosetta = false;
                mutableTaps = false;

                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "powershell/homebrew-tap" = homebrew-powershell;
                  "microsoft/homebrew-mssql-release" = homebrew-mssql;
                  "waydabber/homebrew-betterdisplay" = homebrew-betterdisplay;
                };
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };
        "Miguels-MacBook-Air" = nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin/miguel.nix
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              nixpkgs.overlays = [
                inputs.nix-vscode-extensions.overlays.default
              ];
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.miguel = import ./home/miguel.nix;
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = "miguel";
                enable = true;
                enableRosetta = false;
                mutableTaps = false;

                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "powershell/homebrew-tap" = homebrew-powershell;
                  "microsoft/homebrew-mssql-release" = homebrew-mssql;
                  "waydabber/homebrew-betterdisplay" = homebrew-betterdisplay;
                };
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };
        "MPCE-MBP-HKDC2N1VJ4" = nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin/AS33AI.nix
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              nixpkgs.overlays = [
                inputs.nix-vscode-extensions.overlays.default
              ];
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.AS33AI = import ./home/AS33AI.nix;
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = "AS33AI";
                enable = true;
                enableRosetta = false;
                mutableTaps = false;

                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "powershell/homebrew-tap" = homebrew-powershell;
                  "microsoft/homebrew-mssql-release" = homebrew-mssql;
                  "waydabber/homebrew-betterdisplay" = homebrew-betterdisplay;
                };
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    };
}
