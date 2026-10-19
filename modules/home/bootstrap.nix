{ config, lib, pkgs, ... }:
let
  cfg = config.bootstrap;
  script = pkgs.writeShellScript "bootstrap" ''
    export PATH=${lib.makeBinPath cfg.packages}:$PATH
    failed=0
    ${lib.concatStringsSep "\n" cfg.steps}
    exit $failed
  '';
in
{
  options.bootstrap = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    # Idempotent bash fragments; set `failed=1` on error so the service retries.
    steps = lib.mkOption {
      type = lib.types.listOf lib.types.lines;
      default = [ ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.bootstrap = {
        Unit = {
          Description = "First-run setup";
          # Give up after 10 failed attempts in 10 minutes; the next login tries again.
          StartLimitIntervalSec = 600;
          StartLimitBurst = 10;
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${script}";
          Restart = "on-failure";
          RestartSec = 30;
        };
        Install.WantedBy = [ "default.target" ];
      };
    })

    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      home.activation.bootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${script} || true
      '';
    })
  ];
}
