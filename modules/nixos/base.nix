{ pkgs, ... }:
let
  localFonts = pkgs.runCommand "local-fonts" { } ''
    install -Dm444 -t $out/share/fonts ${../home/fonts}/*
  '';
in
{
  imports = [ ../common/packages.nix ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
    efi.canTouchEfiVariables = true;
  };

  users.users.ava = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "audio"
      "video"
    ];
    home = "/home/ava";
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
  services.openssh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    users.ava.imports = [
      ../home
      ../home/linux.nix
    ];
  };

  time.timeZone = "America/New_York";

  documentation.doc.enable = false;

  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;
  # GSConnect
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "us";

  # GDM and GNOME Settings read the avatar from AccountsService, not from $HOME.
  systemd.tmpfiles.rules = [
    "d /var/lib/AccountsService/icons 0755 root root -"
    "d /var/lib/AccountsService/users 0700 root root -"
    "L+ /var/lib/AccountsService/icons/ava - - - - ${../home/images/profile.jpg}"
    "f+ /var/lib/AccountsService/users/ava 0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/ava\\n"
  ];

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-console
    gnome-music
    gnome-contacts
    gnome-maps
    gnome-tour
    totem
    yelp
  ];

  # Electron apps use Wayland natively
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  virtualisation.docker.enable = true;

  programs.zsh.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  services.flatpak.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      localFonts
    ];
    fontconfig.defaultFonts = {
      sansSerif = [
        "Comfortaa"
        "Noto Sans"
      ];
      monospace = [ "MonoLisa Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    ghostty
    zed-editor
    # nixpkgs only ships `zeditor`; EDITOR, git and the worktree scripts call `zed`.
    (runCommand "zed-alias" { } ''
      mkdir -p $out/bin
      ln -s ${zed-editor}/bin/zeditor $out/bin/zed
    '')
    bitwarden-desktop
    spotify
    tor-browser
    android-studio
    docker-compose
    android-tools
    solaar
    mpv
    celluloid

    gnome-tweaks
    dconf-editor
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell

    wl-clipboard
    xdg-utils
    imagemagick
    sqlite
    vim
    llama-cpp

    cargo
    rustc
    clippy
    rustfmt
    gcc
  ];

  environment.variables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
}
