{ host, pkgs, ... }:
{
  environment.packages = import ../../modules/common/cli-packages.nix { inherit pkgs host; } ++ [
    pkgs.openssh
    pkgs.termux-am
    pkgs.termux-api
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
    config.imports = [ ../../modules/home ];
  };
}
