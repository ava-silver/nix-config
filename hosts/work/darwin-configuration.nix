{ ... }:
{
  imports = [
    ../../modules/common/packages.nix
    ../../modules/common/darwin.nix
  ];

  homebrew.brews = [
    "withgraphite/tap/graphite"
    "direnv"
    "pinentry-mac"
  ];
  system.primaryUser = "ava.silver";
  system.stateVersion = 5;
  users.users."ava.silver".home = "/Users/ava.silver";
  home-manager = {
    extraSpecialArgs = {
      isWork = true;
    };
    useGlobalPkgs = true;
    users."ava.silver".imports = [ ../../modules/home ];
  };
}
