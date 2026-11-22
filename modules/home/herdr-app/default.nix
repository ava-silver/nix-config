{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  isDarwin = host.kind == "darwin";
  herdrFiles = [
    "settings.json"
    "keys.json"
  ]
  ++
    lib.concatMap
      (dir: map (name: "${dir}/${name}") (builtins.attrNames (builtins.readDir (./. + "/${dir}"))))
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
  home.packages = [ herdrCore ] ++ lib.optionals isDarwin [ pkgs.terminal-notifier ];

  xdg.configFile = builtins.listToAttrs (
    map (
      name:
      lib.nameValuePair "herdr-app/${name}" {
        source = config.lib.file.mkOutOfStoreSymlink "${config.thisRepoDir}/modules/home/herdr-app/${name}";
      }
    ) herdrFiles
  );

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
}
