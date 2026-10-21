{ lib, ... }:
{
  system.defaults = {
    dock.autohide = true;
    dock.autohide-delay = 0.0;
    dock.autohide-time-modifier = 0.15;
    dock.appswitcher-all-displays = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllFiles = true;
    NSGlobalDomain.KeyRepeat = 1;
  };
  # Home-manager runs as the user, so this uses sharedModules (user names differ per host).
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      let
      # FluidVoice (homebrew cask): preferences are written into its
      # com.FluidApp.app defaults domain on every switch. Only stable preferences
      # live here; app state (window frames, analytics IDs, onboarding flags) and
      # machine-specific values (microphone priority) are left out so first launch
      # still runs onboarding. Keys are written one at a time because
      # `defaults import` would replace the whole domain.
      fluidVoiceDomain = "com.FluidApp.app";

      # FluidVoice stores structured values as JSON encoded into NSData.
      fluidVoiceData = value: { inherit value; _type = "fluidvoice-data"; };

      fluidVoiceSettings = {
        AccentColorOption = "Purple";
        HotkeyMode = "hold";
        PressAndHoldMode = true;
        PauseMediaDuringTranscription = true;
        GAAVLowercaseFirstLetterEnabled = true;
        GAAVRemoveTrailingPeriodEnabled = true;
        TextInsertionMode = "reliablePaste";
        OverlayBottomOffset = 50;
        ShowInDock = true;
        ShowMainWindowAtLoginLaunch = false;
        EnableDebugLogs = true;

        SelectedSpeechModel = "parakeet-tdt-v2";
        SelectedProviderID = "fluid-1";
        FluidIntelligenceSelectedModelID = "fluid-1";
        FluidIntelligenceBackendPreference = "mlx";
        SelectedDictationPromptID = "__FLUID_1__";
        DictationPromptOff = false;
        SecondaryDictationPromptOff = true;

        # Right Command (keyCode 54), held to dictate.
        HotkeyShortcutKey = fluidVoiceData {
          kind = "keyboard";
          keyCode = 54;
          modifierFlagsRawValue = 0;
          modifierKeyCodes = [ 54 ];
        };
        PrimaryDictationShortcuts = fluidVoiceData [
          {
            kind = "keyboard";
            keyCode = 54;
            modifierFlagsRawValue = 0;
            modifierKeyCodes = [ 54 ];
          }
        ];

        CustomDictionaryEntries = fluidVoiceData [
          {
            id = "254682AF-2777-43C5-9598-62260D30012B";
            triggers = [ "z" ];
            replacement = "Zed";
          }
          {
            id = "F2D6DC51-C864-412B-95AA-620E8F00FF1D";
            triggers = [
              "nick's"
              "nyx"
            ];
            replacement = "nix";
          }
        ];
      };

      fluidVoiceEncode =
        value:
        if lib.isBool value then
          "-bool ${lib.boolToString value}"
        else if lib.isInt value then
          "-int ${toString value}"
        else if lib.isFloat value then
          "-float ${toString value}"
        else if lib.isString value then
          "-string ${lib.escapeShellArg value}"
        else if (value._type or null) == "fluidvoice-data" then
          "-data \"$(printf %s ${lib.escapeShellArg (builtins.toJSON value.value)} | ${pkgs.xxd}/bin/xxd -p | tr -d '\\n')\""
        else
          throw "fluidvoice: unsupported value type for ${builtins.toJSON value}";

      fluidVoiceWrites = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          key: value: "run /usr/bin/defaults write ${fluidVoiceDomain} ${key} ${fluidVoiceEncode value}"
        ) fluidVoiceSettings
      );
      in
      {
        home.activation.fluidvoice = lib.hm.dag.entryAfter [ "writeBoundary" ] fluidVoiceWrites;
      }
    )
  ];

  # Appended so Nix tools win over Homebrew's leftover node/python/just/etc.
  environment.systemPath = lib.mkOrder 1300 [ "/opt/homebrew/bin:/opt/homebrew/sbin" ];

  homebrew = {
    enable = true;
    brews = [
      "kingfisher"
      "mq"
      "colima"
      "lima"
      "docker"
    ];
    casks = [
      "ghostty"
      "linearmouse"
      "zed"
      "raycast"
      "eul"
      "fluidvoice"
      "firefox"
      "android-commandlinetools"
    ];
  };
}
