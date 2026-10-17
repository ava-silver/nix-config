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
      ...
    }:
    {
      darwinConfigurations.slate = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/slate/darwin-configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
      darwinConfigurations.work = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/work/darwin-configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
      nixosConfigurations.pegasus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/pegasus/configuration.nix
          home-manager.nixosModules.home-manager
          lix-module.nixosModules.default
        ];
      };

    };
}
