inputs: final: prev: {
  # nix-on-droid emulates hardlinks with symlinks into ~/.l2s. Bun's default hardlink backend then
  # resolves modules to .l2s paths and corrupts its own cache, leaving empty node_modules directories.
  # bunfig has no setting for the backend, so install-like subcommands get the flag here.
  bun = prev.symlinkJoin {
    name = "bun-${prev.bun.version}";
    paths = [ prev.bun ];
    postBuild = ''
      rm $out/bin/bun
      cat > $out/bin/bun <<'EOF'
      #!${prev.runtimeShell}
      case "''${1:-}" in
        install|i|add|a|update|up) exec ${prev.bun}/bin/bun "$@" --backend=copyfile ;;
        *) exec ${prev.bun}/bin/bun "$@" ;;
      esac
      EOF
      chmod +x $out/bin/bun
    '';
    inherit (prev.bun) meta version;
  };

  # Termux:API commands (termux-clipboard-set, termux-notification, ...) for nix-on-droid.
  # Background: https://github.com/nix-community/nix-on-droid/issues/133
  #
  # Three parts must line up:
  # - CLI: this file builds termux-api-package natively (not the NDK) with PREFIX set to $out, and
  #   termux-am (`am`, talks to the app's am.sock). They broadcast to the com.termux.api plugin app.
  # - Plugin app: only accepts callers sharing its Android user ID, so it needs
  #   TERMUX_PACKAGE_NAME=com.termux.nix. Fork: https://github.com/ava-silver/termux-api
  # - Main app: sharedUserId requires the same signing key. The F-Droid build can't share a user ID with
  #   the plugin, so use the CI build of https://github.com/ava-silver/nix-on-droid-app (custom icon).
  #   Both forks sign with the upstream testkey_untrusted.jks and build via GitHub Actions (JDK 17).
  #
  # Install order: nix-on-droid app, then Termux:API, open Termux:API once, then `just switch`.
  #
  # cp can't copy read-only directories under nix-on-droid's proot, so sources are fetched as tarballs
  # instead of directories.
  termux-am =
    (final.callPackage "${inputs.nix-on-droid}/pkgs/android-integration/termux-am.nix" { })
    .overrideAttrs
      (old: {
        src = final.fetchurl {
          url = "https://github.com/termux/termux-am-socket/archive/refs/tags/${old.version}.tar.gz";
          hash = "sha256-UXUCPH/WdUkkUactBrdcdy8ldoW2n+EXInuuWl5vVJQ=";
        };
      });

  termux-api = final.stdenv.mkDerivation rec {
    pname = "termux-api";
    version = "0.60.0";

    src = final.fetchurl {
      url = "https://github.com/termux/termux-api-package/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-sjKQCCSCM6fC1pqmFYzMQTT53YP2xbGzEccX6ZcRO88=";
    };

    nativeBuildInputs = [ final.cmake ];

    cmakeFlags = [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      "-DCMAKE_C_FLAGS=-DPREFIX=\\\"${placeholder "out"}\\\""
    ];

    postPatch = ''
      substituteInPlace termux-api.c --replace-fail 'execv(PREFIX "/bin/am", child_argv)' 'execv("${final.termux-am}/bin/am", child_argv)'
    '';

    postInstall = ''
      sed -i "1c#!${final.runtimeShell}" $out/bin/* $out/libexec/termux-callback
      # The scripts call getopt, which nix-on-droid does not put on PATH.
      sed -i 's|`getopt |`${final.util-linux}/bin/getopt |' $out/bin/*
    '';
  };
}
