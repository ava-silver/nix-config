{
  config,
  lib,
  pkgs,
  inputs,
  host,
  fonts,
  ...
}:
let
  isDarwin = host.kind == "darwin";
  hex =
    if isDarwin then
      "/Applications/Hex.app/Contents/MacOS/hex"
    else
      lib.getExe config.programs.hex.package;
  hexSettings = lib.importJSON ./hex/settings.json;
  hexVocabulary = lib.importJSON ./hex/vocabulary.json;
in
{
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.hex.homeManagerModules.hex
  ];

  xdg.configFile."ghostty/config".text =
    builtins.replaceStrings [ "@mono@" ] [ fonts.mono ] (builtins.readFile ./ghostty/config)
    + lib.optionalString (!isDarwin) ''

      # macOS sizes are 72 dpi points, GTK's are 96 dpi, so 18 renders ~33% larger there
      font-size = 13

      keybind = ctrl+shift+z=text:\x1bZ

      # Word deletion, matching what option+backspace/delete send on macOS
      keybind = ctrl+backspace=text:\x1b\x7f
      keybind = ctrl+delete=text:\x1bd
    '';

  # Out-of-store so settings changed in Zed write back to the repo.
  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/modules/home/zed/settings.json";
  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/modules/home/zed/keymap.json";

  # Hex rejects symlinks that resolve outside its config folder, so copy instead of linking.
  home.activation.hexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run install -Dm644 ${./hex/hex.config.ts} ${config.xdg.configHome}/hex/hex.config.ts
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

  programs.nixcord = {
    enable = true;
    discord.vencord.enable = true;

    quickCss = ''
      /* google emojis */
      @import url(https://mwittrien.github.io/BetterDiscordAddons/Themes/EmojiReplace/base/Google.css);

      /* mocha (pink accent) */
      @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-pink.theme.css");

      ::placeholder, body, button, input, select, textarea, div {
          font-family: "${fonts.sans}" !important;
      }
    '';

    config = {
      useQuickCss = true;
      plugins = {
        alwaysTrust.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        clientTheme.enable = true;
        experiments.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        noTrack.enable = true;
        openInApp.enable = true;
        petpet.enable = true;
        readAllNotificationsButton.enable = true;
        relationshipNotifier.enable = true;
        serverInfo.enable = true;
      };
    };
  };
}
