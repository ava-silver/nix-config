# nix-on-droid emulates hardlinks with symlinks into ~/.l2s. Bun's default hardlink backend then
# resolves modules to .l2s paths and corrupts its own cache, leaving empty node_modules directories.
# bunfig has no setting for the backend, so install-like subcommands get the flag here.
final: prev: {
  bun = prev.symlinkJoin {
    name = "bun-${prev.bun.version}";
    paths = [ prev.bun ];
    postBuild = ''
      rm $out/bin/bun
      cat > $out/bin/bun <<'EOF'
      #!${prev.runtimeShell}
      case "''${1:-}" in
        install|i|add|a|update|up) exec ${prev.bun}/bin/bun "$@" --backend=copyfile ;;
        *) exec ${prev.bun}/bin/bun "$@" ;;
      esac
      EOF
      chmod +x $out/bin/bun
    '';
    inherit (prev.bun) meta version;
  };
}
