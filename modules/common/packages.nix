{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
    gotestsum
    kingfisher

    moreutils
    jq

    uv
    ruff
    pipx
    ty
    pyrefly

    bun
    nodejs_26

    nixd
    nil

    rtk
    prek
  ];
}
