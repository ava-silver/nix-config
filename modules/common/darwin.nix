{ ... }:
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
  homebrew = {
    enable = true;
    brews = [
      "kingfisher"
      "mq"
      "colima"
      "lima"
      "docker"
      "magic-wormhole"
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
