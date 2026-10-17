{ pkgs, ... }:
{
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

    moreutils
    jq

    uv
    ruff
    pipx
    ty
    pyrefly

    bun
    nodejs_26

    rtk
    prek
  ];
}
