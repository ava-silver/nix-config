{ host, lib, ... }:
{
  imports = [ ../common ];

  system.primaryUser = host.user;
  users.users.${host.user}.home = "/Users/${host.user}";
  home-manager = {
    useGlobalPkgs = true;
    users.${host.user}.imports = [
      ../home
      ../home/desktop.nix
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "discord";

  # Daily rather than the weekly default, so --delete-older-than 7d really means about 7 days.
  nix.gc.interval = {
    Hour = 3;
    Minute = 15;
  };

  # Drops the default root channels entry, which doesn't exist on a flake-only setup and makes Lix warn.
  nix.nixPath = lib.mkForce [ "nixpkgs=flake:nixpkgs" ];

  security.pam.services.sudo_local.touchIdAuth = true;

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
    taps = [
      {
        name = "anomalyco/tap";
        trusted = true;
      }
    ];
    brews = [
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
      "anomalyco/tap/hex"
      "firefox"
      "android-commandlinetools"
    ];
  };
}
