{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
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
    ./git
    ./bin.nix
    ./shell
    ./pi
  ];

  home.stateVersion = "25.05";

  xdg.configFile."ghostty/config".text =
    builtins.readFile ./ghostty/config
    + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''

      # macOS sizes are 72 dpi points, GTK's are 96 dpi, so 18 renders ~33% larger there
      font-size = 13

      keybind = ctrl+shift+z=text:\x1bZ

      # Word deletion, matching what option+backspace/delete send on macOS
      keybind = ctrl+backspace=text:\x1b\x7f
      keybind = ctrl+delete=text:\x1bd
    '';

  # Out-of-store so settings changed in Zed write back to the repo; assumes the clone lives at ~/nix-config.
  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/home/zed/settings.json";
  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/home/zed/keymap.json";

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

  programs.nixcord = {
    enable = true;
    discord.vencord.enable = true;

    quickCss = ''
      /* google emojis */
      @import url(https://mwittrien.github.io/BetterDiscordAddons/Themes/EmojiReplace/base/Google.css);

      /* mocha (pink accent) */
      @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-pink.theme.css");

      ::placeholder, body, button, input, select, textarea, div {
          font-family: "Comfortaa" !important;
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
