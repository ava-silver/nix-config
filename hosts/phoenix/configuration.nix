{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/nixos/laptop.nix
  ];

  networking.hostName = "phoenix";
}
