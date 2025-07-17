{
  description = "Miguel's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .
      darwinConfigurations = {
        "Miguels-MacBook-Air" = nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin/miguel.nix
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
