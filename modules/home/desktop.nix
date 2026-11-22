{
  inputs,
  fonts,
  ...
}:
{
  imports = [
    inputs.nixcord.homeModules.nixcord
    ./ghostty
    ./herdr-app
    ./hex
    ./rex
    ./zed
  ];

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
