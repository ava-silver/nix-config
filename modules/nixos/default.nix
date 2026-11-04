{ host, pkgs, ... }:
{
  imports = [
    ../common
    ./desktop.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
    efi.canTouchEfiVariables = true;
  };

  users.users.${host.user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "audio"
      "video"
    ];
    home = "/home/${host.user}";
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
  services.openssh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    users.${host.user}.imports = [ ../home ];
  };

  time.timeZone = "America/New_York";

  documentation.doc.enable = false;

  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;

  programs.zsh.enable = true;

  # Lets prebuilt binaries (uv Pythons, rustup, Android SDK, bun packages) run.
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    android-tools
    docker-compose
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
