{
  config,
  lib,
  pkgs,
  inputs,
  host,
  ...
}:
let
  isDarwin = host.kind == "darwin";
  hex =
    if isDarwin then
      "/Applications/Hex.app/Contents/MacOS/hex"
    else
      lib.getExe config.programs.hex.package;
  hexSettings = lib.importJSON ./settings.json;
  hexVocabulary = lib.importJSON ./vocabulary.json;
in
{
  imports = [ inputs.hex.homeManagerModules.hex ];

  # Hex rejects symlinks that resolve outside its config folder, so copy instead of linking.
  home.activation.hexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run install -Dm644 ${./hex.config.ts} ${config.xdg.configHome}/hex/hex.config.ts
  '';

  # Linux applies settings through programs.hex; the macOS app comes from Homebrew.
  home.activation.hexSettings = lib.mkIf isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${hex} settings apply ${
        (pkgs.formats.json { }).generate "hex-settings.json" (
          hexSettings // { dictation_hotkey = "right-command"; }
        )
      }
    ''
  );

  # Hex's CLI edits the vocabulary only in a running Hex; adding is idempotent and merges spellings.
  home.activation.hexVocabulary = lib.hm.dag.entryAfter [ "hexSettings" ] ''
    ${lib.optionalString (!isDarwin) "export HEX_APPLICATION_SUPPORT_DIR=${config.xdg.dataHome}/hex"}
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (term: soundsLike: ''
        run ${hex} vocabulary add ${lib.escapeShellArg term} --sounds-like ${lib.escapeShellArg (lib.concatStringsSep "," soundsLike)} \
          || warnEcho "Hex vocabulary: couldn't add ${term}; start Hex and switch again."
      '') hexVocabulary
    )}
  '';

  programs.hex = lib.mkIf (!isDarwin) {
    enable = true;
    autostart = true;
    installModel = true;
    # Modifier-only shortcuts aren't supported on Linux, so dictation_hotkey keeps Hex's default.
    model = "parakeet_unified_en";
    language = "en";
    settings = hexSettings;
  };
}
