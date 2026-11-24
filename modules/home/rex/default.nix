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

  programs.zsh.initContent = ''
    [[ -z $REX_BIN_DIR ]] || path=("$REX_BIN_DIR" $path)
  '';

  # Rex reads init.lua once at server start and doesn't watch it; reload if the server is running.
  home.activation.rexConfig = lib.mkIf isDarwin (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      rex_bin="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
      if [ -x "$rex_bin" ]; then
        run "$rex_bin" config reload --autostart=false || true
      fi
    ''
  );

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
