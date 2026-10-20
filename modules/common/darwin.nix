{ lib, ... }:
{
  system.defaults = {
    dock.autohide = true;
    dock.autohide-delay = 0.0;
    dock.autohide-time-modifier = 0.15;
    dock.appswitcher-all-displays = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllFiles = true;
    NSGlobalDomain.KeyRepeat = 1;
  };
  # Appended so Nix tools win over Homebrew's leftover node/python/just/etc.
  environment.systemPath = lib.mkOrder 1300 [ "/opt/homebrew/bin:/opt/homebrew/sbin" ];

  homebrew = {
    enable = true;
    brews = [
      "kingfisher"
      "mq"
      "colima"
      "lima"
      "docker"
    ];
    casks = [
      "ghostty"
      "linearmouse"
      "zed"
      "raycast"
      "eul"
      "fluidvoice"
      "firefox"
      "android-commandlinetools"
    ];
  };
}
