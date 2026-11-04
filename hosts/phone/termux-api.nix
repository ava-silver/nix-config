# cp can't copy read-only directories under nix-on-droid's proot, so sources are fetched as tarballs
# instead of directories. The Termux:API app must also be built for the com.termux.nix package name.
{ pkgs, nix-on-droid }:
rec {
  termux-am =
    (pkgs.callPackage "${nix-on-droid}/pkgs/android-integration/termux-am.nix" { }).overrideAttrs
      (old: {
        src = pkgs.fetchurl {
          url = "https://github.com/termux/termux-am-socket/archive/refs/tags/${old.version}.tar.gz";
          hash = "sha256-UXUCPH/WdUkkUactBrdcdy8ldoW2n+EXInuuWl5vVJQ=";
        };
      });

  termux-api = pkgs.stdenv.mkDerivation rec {
    pname = "termux-api";
    version = "0.60.0";

    src = pkgs.fetchurl {
      url = "https://github.com/termux/termux-api-package/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-sjKQCCSCM6fC1pqmFYzMQTT53YP2xbGzEccX6ZcRO88=";
    };

    nativeBuildInputs = [ pkgs.cmake ];

    cmakeFlags = [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      "-DCMAKE_C_FLAGS=-DPREFIX=\\\"${placeholder "out"}\\\""
    ];

    postPatch = ''
      substituteInPlace termux-api.c --replace-fail 'execv(PREFIX "/bin/am", child_argv)' 'execv("${termux-am}/bin/am", child_argv)'
    '';

    postInstall = ''
      sed -i "1c#!${pkgs.runtimeShell}" $out/bin/* $out/libexec/termux-callback
    '';
  };
}
