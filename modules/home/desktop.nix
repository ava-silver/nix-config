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
  herdrFiles = [
    "settings.json"
    "keys.json"
  ]
  ++
    lib.concatMap
      (
        dir: map (name: "${dir}/${name}") (builtins.attrNames (builtins.readDir (./herdr-app + "/${dir}")))
      )
      [
        "layouts"
        "themes"
        "mods"
      ];
  herdrCore = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "herdr-core";
    version = "0.1.21";
    src = pkgs.fetchurl {
      url = "https://releases.herdr.dev/core/${finalAttrs.version}/herdr-core-${
        if isDarwin then "macos-aarch64" else "linux-x86_64"
      }.tar.gz";
      hash =
        if isDarwin then
          "sha256-GrON2ScPY6j3lNbWDocC6w0chacr2oXXNeXupD8F/+0="
        else
          "sha256-eEJHVcEKQN3jigvbVcIKwZcG6a4F7Wj8Ks8fz/DZQcE=";
    };
    sourceRoot = ".";
    # Keep the macOS bundle's signature and privacy permission identity intact.
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin" "$out/share/licenses/herdr-core"
      ${
        if isDarwin then
          ''
            mkdir -p "$out/Applications"
            cp -R "Herdr Core.app" "$out/Applications/"
            ln -s "$out/Applications/Herdr Core.app/Contents/MacOS/herdr-core" "$out/bin/herdr-core"
          ''
        else
          ''
            cp herdr-core "$out/bin/"
          ''
      }
      ln -s herdr-core "$out/bin/hc"
      cp LICENSE THIRD-PARTY-NOTICES "$out/share/licenses/herdr-core/"
      runHook postInstall
    '';
    meta = {
      mainProgram = "hc";
      license = lib.licenses.asl20;
      platforms = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
    };
  });
in
{
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.hex.homeManagerModules.hex
  ];

  home.packages = [ herdrCore ] ++ lib.optionals isDarwin [ pkgs.terminal-notifier ];

  xdg.configFile =
    builtins.listToAttrs (
      map (
        name:
        lib.nameValuePair "herdr-app/${name}" {
          source = config.lib.file.mkOutOfStoreSymlink "${config.thisRepoDir}/modules/home/herdr-app/${name}";
        }
      ) herdrFiles
    )
    // {
      "ghostty/config".text =
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
      "zed/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.thisRepoDir}/modules/home/zed/settings.json";
      "zed/keymap.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.thisRepoDir}/modules/home/zed/keymap.json";
    };

  home.activation.herdrNotifications = lib.mkIf isDarwin (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -f "${pkgs.terminal-notifier}/Applications/terminal-notifier.app"
    ''
  );

  home.activation.herdrLayout = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [[ ! -e "${config.xdg.configHome}/herdr-app/shared.json" ]]; then
      run install -Dm644 ${pkgs.writeText "herdr-shared.json" ''{"layout":"islands"}''} \
        "${config.xdg.configHome}/herdr-app/shared.json"
    fi
  '';

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
        noTrack.enable = true;
        openInApp.enable = true;
        readAllNotificationsButton.enable = true;
        relationshipNotifier.enable = true;
        serverInfo.enable = true;
      };
    };
  };
}
