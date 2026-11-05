{ config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "pegasus";
  time.hardwareClockInLocalTime = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
