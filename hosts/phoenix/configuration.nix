{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/laptop.nix
  ];

  networking.hostName = "phoenix";
}
