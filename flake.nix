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
      ...
    }:
    let
      sharedHomeModules = [ nixcord.homeModules.nixcord ];
    in
    {
      darwinConfigurations.slate = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/slate/darwin-configuration.nix
          home-manager.darwinModules.home-manager
          { home-manager.sharedModules = sharedHomeModules; }
        ];
      };
      darwinConfigurations.work = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/work/darwin-configuration.nix
          home-manager.darwinModules.home-manager
          { home-manager.sharedModules = sharedHomeModules; }
        ];
      };
      nixosConfigurations = nixpkgs.lib.genAttrs [ "pegasus" "phoenix" ] (
        host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager.nixosModules.home-manager
            { home-manager.sharedModules = sharedHomeModules; }
            lix-module.nixosModules.lixFromNixpkgs
          ];
        }
      );
    };
}
