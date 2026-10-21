{ ... }:
{
  imports = [ ../../modules/darwin ];

  homebrew = {
    brews = [
      "llama.cpp"
    ];
    casks = [
      "bitwarden"
    ];
  };

  networking.hostName = "slate";
  system.primaryUser = "ava";
  users.users.ava.home = "/Users/ava";
  system.stateVersion = 5;
  home-manager = {
    extraSpecialArgs.isWork = false;
    useGlobalPkgs = true;
    users.ava.imports = [ ../../modules/home ];
  };
}
