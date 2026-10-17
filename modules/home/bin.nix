{ lib, pkgs, ... }@args:
let
  isWork = args.isWork or false;

  # Scripts that need a Nix store path use @varname@ as a placeholder.
  # Add entries here when a new script needs one.
  subs = {
    "@gh@" = "${pkgs.gh}";
  };

  applySubstitutions = content:
    builtins.replaceStrings
      (builtins.attrNames subs)
      (builtins.attrValues subs)
      content;

  makePkg = dir: filename:
    let
      name = lib.pipe filename [
        (lib.removeSuffix ".sh")
        (lib.removeSuffix ".py")
      ];
      text = applySubstitutions (builtins.readFile (dir + "/${filename}"));
    in pkgs.writeTextFile {
      inherit name text;
      executable = true;
      destination = "/bin/${name}";
    };

  pkgsFrom = dir:
    let files = builtins.attrNames (lib.filterAttrs (_: v: v == "regular") (builtins.readDir dir));
    in map (makePkg dir) files;
in
{
  home.packages =
    pkgsFrom ./bin/shared
    ++ lib.optionals isWork (pkgsFrom ./bin/work);
}
