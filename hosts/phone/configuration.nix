{
  pkgs,
  isWork,
  nix-on-droid,
  ...
}:
let
  termux = import ./termux-api.nix { inherit pkgs nix-on-droid; };
in
{
  environment.packages = import ../../modules/common/cli-packages.nix { inherit pkgs isWork; } ++ [
    pkgs.openssh
    termux.termux-am
    termux.termux-api
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
    };
  };
}
