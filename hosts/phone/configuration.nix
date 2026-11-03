{ pkgs, isWork, ... }:
{
  environment.packages = import ../../modules/common/cli-packages.nix { inherit pkgs isWork; } ++ [
    pkgs.openssh
    pkgs.ntfy-sh
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
    extraSpecialArgs = { inherit isWork; };
    config = {
      imports = [
        ../../modules/home/git
        ../../modules/home/bin.nix
        ../../modules/home/shell
        ../../modules/home/pi
      ];
      home.stateVersion = "25.05";
      pi.profile = "phone";

      # Pi publishes notifications to a local ntfy server that its phone-notify extension starts and stops;
      # the ntfy app subscribes to it. Termux:API can't be used because it only accepts calls from apps
      # sharing its Android user.
      home.sessionVariables.PI_NTFY_URL = "http://127.0.0.1:2586/pi";
    };
  };
}
