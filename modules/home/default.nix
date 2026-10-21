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

      keybind = ctrl+shift+z=text:\x1bZ

      # Word deletion, matching what option+backspace/delete send on macOS
      keybind = ctrl+backspace=text:\x1b\x7f
      keybind = ctrl+delete=text:\x1bd
    '';

  xdg.configFile."zed/settings.json".source = ./zed/settings.json;
  xdg.configFile."zed/keymap.json".source = ./zed/keymap.json;

  # Vesktop rather than Discord so Linux and macOS share one config; it updates Vencord itself.
  programs.nixcord = {
    enable = true;
    discord.enable = false;
    vesktop = {
      enable = true;
      useSystemVencord = false;
    };

    quickCss = ''
      /* google emojis */
      @import url(https://mwittrien.github.io/BetterDiscordAddons/Themes/EmojiReplace/base/Google.css);

      ::placeholder, body, button, input, select, textarea {
        font-family: "Comfortaa";
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
