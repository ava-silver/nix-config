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

  # Scripts run on Nix's bash rather than whichever bash is first on PATH (macOS ships 3.2).
  envBash = "#!/usr/bin/env bash\n";
  withNixBash =
    content:
    if lib.hasPrefix envBash content then
      "#!${pkgs.runtimeShell}\n" + lib.removePrefix envBash content
    else
      content;

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
      text = withNixBash content;
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

  options.thisRepoDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nix-config";
    description = "Clone of this repo, for files that link back into it so apps can write changes to the repo.";
  };

  config = {
    home.stateVersion = "25.05";

    home.packages = pkgsFrom ./bin ++ lib.optionals host.work (pkgsFrom ./bin/work);
  };
}
