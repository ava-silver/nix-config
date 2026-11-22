{
  lib,
  host,
  fonts,
  ...
}:
let
  isDarwin = host.kind == "darwin";
in
{
  xdg.configFile."ghostty/config".text =
    builtins.replaceStrings [ "@mono@" ] [ fonts.mono ] (builtins.readFile ./config)
    + lib.optionalString (!isDarwin) ''

      # macOS sizes are 72 dpi points, GTK's are 96 dpi, so 18 renders ~33% larger there
      font-size = 13

      keybind = ctrl+shift+z=text:\x1bZ

      # Word deletion, matching what option+backspace/delete send on macOS
      keybind = ctrl+backspace=text:\x1b\x7f
      keybind = ctrl+delete=text:\x1bd
    '';
}
