{ ... }:
{
  imports = [ ../../modules/common/packages.nix ];

  networking.hostName = "pegasus";
  users.users.ava = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    home = "/home/ava";
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
  services.openssh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    users.ava.imports = [ ../../modules/home ];
  };
}
