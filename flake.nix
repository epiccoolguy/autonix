{
  description = "Miguel's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      mac-app-util,
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .
      darwinConfigurations = {
        "Miguels-MacBook-Air" = nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin/miguel.nix
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.miguel = import ./home/miguel.nix;
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
