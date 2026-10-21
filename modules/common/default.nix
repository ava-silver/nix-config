{ pkgs, ... }:
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

  environment.systemPackages = with pkgs; [
    git
    gh
    glab
    delta
    difftastic
    mergiraf

    just
    curl
    lsd
    zoxide
    fzf
    bat
    rm-improved
    ripgrep
    gum
    bottom
    gnused
    nmap
    magic-wormhole
    gotestsum
    kingfisher

    moreutils
    jq
    fastfetch

    python315
    uv
    ruff
    pipx
    ty
    pyrefly

    bun
    nodejs_26

    rust-analyzer
    jinja-lsp

    nixd
    nil
    nixfmt

    prek
  ];
}
