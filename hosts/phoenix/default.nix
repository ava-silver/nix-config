{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "phoenix";

  home-manager.users.${host.user}.dconf.settings = {
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-battery-timeout = 1800;
    };
  };
}
