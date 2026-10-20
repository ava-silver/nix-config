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

      # Linux equivalent of the macOS super+z binding above
      keybind = ctrl+shift+z=text:\x1bZ

      # Word deletion, matching what option+backspace/delete send on macOS
      keybind = ctrl+backspace=text:\x1b\x7f
      keybind = ctrl+delete=text:\x1bd
    '';

  xdg.configFile."zed/settings.json".source = ./zed/settings.json;
  xdg.configFile."zed/keymap.json".source = ./zed/keymap.json;
}
