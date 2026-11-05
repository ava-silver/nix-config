{
  lib,
  pkgs,
  host,
  ...
}:
let
  localFonts = pkgs.runCommand "local-fonts" { } ''
    install -Dm444 -t $out/share/fonts ${../../assets/fonts}/*
  '';
in
{
  # `fonts.packages` exists on both NixOS and nix-darwin (/Library/Fonts/Nix Fonts).
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira
    font-awesome_6
    localFonts
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;

  environment.systemPackages =
    import ./cli-packages.nix { inherit pkgs host; } ++ lib.optionals (!host.work) [ pkgs.qbittorrent ];
}
