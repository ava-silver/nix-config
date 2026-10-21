{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/nixos/nvidia.nix
  ];

  networking.hostName = "pegasus";
  time.hardwareClockInLocalTime = true;
}
