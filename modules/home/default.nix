{ ... }:
{
  imports = [
    ./git
    ./bin.nix
    ./shell
  ];

  home.stateVersion = "25.05";

  xdg.configFile."ghostty/config".source = ./ghostty/config;

  xdg.configFile."zed/settings.json".source = ./zed/settings.json;
  xdg.configFile."zed/keymap.json".source = ./zed/keymap.json;
}
