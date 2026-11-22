{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  isDarwin = host.kind == "darwin";
in
{
  xdg.configFile."rex/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.thisRepoDir}/modules/home/rex/init.lua";

  # Rex keeps themes in its preferences, not a config file, so write the theme there and select it for dark mode.
  home.activation.rexTheme = lib.mkIf isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      theme=${./theme.json}
      run /usr/bin/defaults write com.superlogical.rex Workspace.customThemes \
        -data "$(${pkgs.jq}/bin/jq -c . "$theme" | ${pkgs.xxd}/bin/xxd -p | tr -d '\n')"
      run /usr/bin/defaults write com.superlogical.rex Workspace.darkThemeID \
        -string "$(${pkgs.jq}/bin/jq -r '.[0].id' "$theme")"
    ''
  );
}
