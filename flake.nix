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
    hex = {
      url = "github:anomalyco/hex";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-on-droid,
      nix-bun,
      lix-module,
      ...
    }:
    let
      hosts = {
        slate = {
          kind = "darwin";
          user = "ava";
        };
        work = {
          kind = "darwin";
          user = "ava.silver";
          work = true;
        };
        pegasus = {
          kind = "nixos";
          user = "ava";
        };
        phoenix = {
          kind = "nixos";
          user = "ava";
        };
        phone.kind = "droid";
      };

      fonts = {
        sans = "Comfortaa";
        mono = "MonoLisa Nerd Font";
      };

      overlays = [ nix-bun.overlays.default ];
      lixOverlay = lix-module.overlays.lixFromNixpkgs;

      builders = {
        darwin =
          host: args:
          nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = args;
            modules = [
              ./hosts/${host.name}
              ./modules/darwin
              home-manager.darwinModules.home-manager
              { nixpkgs.overlays = overlays ++ [ lixOverlay ]; }
              { home-manager.extraSpecialArgs = args; }
            ];
          };

        nixos =
          host: args:
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = args;
            modules = [
              ./hosts/${host.name}
              ./modules/nixos
              home-manager.nixosModules.home-manager
              { nixpkgs.overlays = overlays ++ [ lixOverlay ]; }
              { home-manager.extraSpecialArgs = args; }
            ];
          };

        # nix-on-droid rejects nixpkgs.overlays when given a pkgs, so overlays apply at import.
        # No Lix: under proot, Lix 2.96 fails every local build (stat of
        # /proc/sys/user/max_user_namespaces returns EACCES), which breaks `nix-on-droid switch`.
        droid =
          host: args:
          nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-linux";
              overlays = overlays ++ [ (import ./hosts/${host.name}/overlay.nix inputs) ];
            };
            extraSpecialArgs = args;
            modules = [
              ./hosts/${host.name}
              { home-manager.extraSpecialArgs = args; }
            ];
          };
      };

      mkHost =
        name: cfg:
        let
          host = {
            inherit name;
            work = false;
          }
          // cfg;
        in
        builders.${host.kind} host { inherit inputs host fonts; };

      ofKind = kind: nixpkgs.lib.filterAttrs (_: host: host.kind == kind) hosts;
    in
    {
      darwinConfigurations = builtins.mapAttrs mkHost (ofKind "darwin");
      nixosConfigurations = builtins.mapAttrs mkHost (ofKind "nixos");
      nixOnDroidConfigurations = builtins.mapAttrs mkHost (ofKind "droid");
    };
}
