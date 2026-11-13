{ config, pkgs, ... }:
let
  # The work profile is Android user 10, which can't reach /data/data. Nix-on-Droid hardcodes that path,
  # so login runs proot from the real directory and binds it over /data/data for everything inside,
  # including HOME. The app side lives in https://github.com/ava-silver/nix-on-droid-app.
  # The app's bootstrap installs the unpatched login, so first setup runs over adb as
  # `run-as com.termux.nix --user 10`: extract the bootstrap zip into files/usr, apply this sed to
  # bin/login, then run `nix-on-droid switch --flake .#phone-work` through it before opening the app.
  login = pkgs.runCommand "login" { } ''
    sed '/^export HOME=/!s#/data/data/com.termux.nix#/data/user/10/com.termux.nix#g' ${config.environment.files.login} > $out
    chmod +x $out
  '';
in
{
  system.stateVersion = "24.05";

  build.extraProotOptions = [ "-b /data/user/10:/data/data" ];

  # Runs after nix-on-droid's installLogin, which always writes the unpatched script first.
  build.activationAfter.workProfileLogin = ''
    if ! diff /bin/login ${login} > /dev/null; then
      $DRY_RUN_CMD cp $VERBOSE_ARG ${login} /bin/.login.tmp
      $DRY_RUN_CMD chmod $VERBOSE_ARG u+w /bin/.login.tmp
      $DRY_RUN_CMD mv $VERBOSE_ARG /bin/.login.tmp /bin/login
    fi
  '';
}
