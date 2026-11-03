{
  lib,
  pkgs,
  isWork,
  ...
}:
{
  environment.packages = import ../../modules/common/cli-packages.nix { inherit pkgs isWork; } ++ [
    pkgs.openssh
  ];

  system.stateVersion = "24.05";
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Termux only loads one font file; bold and italic are synthesized from it.
  terminal.font = "${../../assets/fonts}/MonoLisaNerdFont-Regular.otf";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {
      inherit isWork;
      isPhone = true;
    };
    config = {
      imports = [
        ../../modules/home/git
        ../../modules/home/bin.nix
        ../../modules/home/shell
        ../../modules/home/pi
      ];
      home.stateVersion = "25.05";

      # Pi publishes finish notifications to a local ntfy server; the ntfy app subscribes to it.
      # Termux:API can't be used because it only accepts calls from apps sharing its Android user.
      home.sessionVariables.PI_NTFY_URL = "http://127.0.0.1:2586/pi";
      programs.zsh.initContent = lib.mkAfter ''
        ntfy_pidfile="$HOME/.cache/ntfy.pid"
        if ! kill -0 "$(cat "$ntfy_pidfile" 2>/dev/null)" 2>/dev/null; then
          ${pkgs.ntfy-sh}/bin/ntfy serve --listen-http 127.0.0.1:2586 >/dev/null 2>&1 &!
          echo $! > "$ntfy_pidfile"
        fi
      '';
    };
  };
}
