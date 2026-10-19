{ lib, pkgs, ... }:
{
  imports = [
    ./git
    ./bin.nix
    ./shell
    ./pi.nix
  ];

  home.stateVersion = "25.05";

  xdg.configFile."ghostty/config".text =
    builtins.readFile ./ghostty/config
    + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''

      # macOS sizes are 72 dpi points, GTK's are 96 dpi, so 18 renders ~33% larger there
      font-size = 13
    '';

  xdg.configFile."zed/settings.json".source = ./zed/settings.json;
  xdg.configFile."zed/keymap.json".source = ./zed/keymap.json;
}
