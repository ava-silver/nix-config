{ pkgs, lib, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      font-name = "Comfortaa 11";
      document-font-name = "Comfortaa 11";
      monospace-font-name = "MonoLisa Nerd Font 11";
      clock-format = "12h";
      color-scheme = "prefer-dark";
      font-antialiasing = "grayscale";
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file://${./images/background.jpg}";
      picture-uri-dark = "file://${./images/background.jpg}";
      picture-options = "zoom";
    };

    "org/gnome/desktop/wm/preferences".titlebar-font = "Comfortaa Bold 11";

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
      accel-profile = "flat";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = true;
      night-light-temperature = lib.hm.gvariant.mkUint32 3700;
    };

    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
    "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 600;

    "org/gnome/desktop/wm/keybindings" = {
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
      switch-applications = [ "<Super>Tab" ];
    };

    "org/gnome/desktop/privacy" = {
      report-technical-problems = false;
      send-software-usage-stats = false;
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "gsconnect@andyholmes.github.io"
        "clipboard-indicator@tudmotu.com"
        "blur-my-shell@aunetx"
      ];
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "com.mitchellh.ghostty.desktop"
        "dev.zed.Zed.desktop"
        "com.bitwarden.desktop.desktop"
        "spotify.desktop"
        "slack.desktop"
      ];
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      sigma = 30;
      brightness = 0.6;
    };
    "org/gnome/shell/extensions/clipboard-indicator" = {
      history-size = 50;
      toggle-menu = [ "<Super>v" ];
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };
}
