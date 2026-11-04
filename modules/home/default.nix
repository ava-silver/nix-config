{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  # Scripts that need a Nix store path use @varname@ as a placeholder.
  subs = {
    "@gh@" = "${pkgs.gh}";
  };

  # Dropping the shebang keeps scripts on Nix's bash rather than whichever bash is first on PATH.
  withNixShell = lib.removePrefix "#!/usr/bin/env bash\n";

  makePkg =
    dir: filename:
    let
      name = lib.pipe filename [
        (lib.removeSuffix ".sh")
        (lib.removeSuffix ".py")
      ];
      content = builtins.replaceStrings (builtins.attrNames subs) (builtins.attrValues subs) (
        builtins.readFile (dir + "/${filename}")
      );
    in
    pkgs.writeTextFile {
      inherit name;
      text =
        if lib.hasSuffix ".sh" filename then "#!${pkgs.runtimeShell}\n" + withNixShell content else content;
      executable = true;
      destination = "/bin/${name}";
    };

  pkgsFrom =
    dir:
    map (makePkg dir) (
      builtins.attrNames (lib.filterAttrs (_: v: v == "regular") (builtins.readDir dir))
    );
in
{
  imports = [
    ./git.nix
    ./shell
    ./pi
  ];

  options.my.repo = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nix-config";
    description = "Clone of this repo, for files that link back into it so apps can write changes to the repo.";
  };

  config = {
    home.stateVersion = "25.05";

    home.packages = pkgsFrom ./bin ++ lib.optionals host.work (pkgsFrom ./bin/work);
  };
}
