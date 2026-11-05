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
    config = {
      imports = [ ../../modules/home ];
      # Replace files home-manager doesn't own instead of failing on them.
      home.backupCommand = "${pkgs.coreutils}/bin/rm -rf";
    };
  };
}
