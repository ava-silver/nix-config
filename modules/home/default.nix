{ lib, pkgs, ... }:
{
  imports = [
    ./git
    ./bin.nix
    ./shell
  ];

  home.stateVersion = "25.05";

  # Clone the Pi agent config repo on first setup; no-op if already present.
  home.activation.piConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -d "$HOME/.pi/agent/.git" ]]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/ava-silver/pi-config.git "$HOME/.pi/agent"
      $DRY_RUN_CMD bash "$HOME/.pi/agent/setup.sh"
    fi
  '';

  xdg.configFile."ghostty/config".source = ./ghostty/config;

  xdg.configFile."zed/settings.json".source = ./zed/settings.json;
  xdg.configFile."zed/keymap.json".source = ./zed/keymap.json;
}
