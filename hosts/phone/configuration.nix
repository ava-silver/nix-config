{ pkgs, isWork, ... }:
{
  environment.packages = import ../../modules/common/cli-packages.nix { inherit pkgs isWork; } ++ [
    pkgs.openssh
  ];

  system.stateVersion = "24.05";
  user.shell = "${pkgs.zsh}/bin/zsh";

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
    };
  };
}
