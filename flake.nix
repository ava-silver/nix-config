{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-bun = {
      url = "github:ryoppippi/nix-bun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nix-darwin,
      nixpkgs,
      home-manager,
      lix-module,
      nixcord,
      nix-bun,
      ...
    }:
    let
      homeManagerShared =
        { isWork, ... }:
        {
          home-manager.sharedModules = [ nixcord.homeModules.nixcord ];
          home-manager.extraSpecialArgs = { inherit isWork; };
        };
      bunOverlay.nixpkgs.overlays = [ nix-bun.overlays.default ];
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs [ "slate" "work" ] (
        host:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs.isWork = host == "work";
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager.darwinModules.home-manager
            homeManagerShared
            bunOverlay
          ];
        }
      );
      nixosConfigurations = nixpkgs.lib.genAttrs [ "pegasus" "phoenix" ] (
        host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs.isWork = false;
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager.nixosModules.home-manager
            homeManagerShared
            bunOverlay
            lix-module.nixosModules.lixFromNixpkgs
          ];
        }
      );
    };
}
