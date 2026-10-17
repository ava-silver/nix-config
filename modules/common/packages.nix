{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    gh
    glab
    delta
    difftastic
    mergiraf

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
    gotestsum

    jq

    uv
    ruff

    bun
    nodejs_26

    rtk
    prek
  ];
}
