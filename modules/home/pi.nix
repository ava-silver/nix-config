{
  lib,
  pkgs,
  isWork,
  ...
}:
let
  configBranch = if isWork then "main" else "personal";
  path = lib.makeBinPath [
    pkgs.git
    pkgs.bun
    pkgs.coreutils
  ];
in
{
  # Idempotent and non-fatal: if offline, run `just switch` again once connected.
  # The timeouts keep a first boot without network from stalling login.
  home.activation.pi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (
      export PATH=${path}:$PATH
      agent="$HOME/.pi/agent"

      # Branch is only chosen at clone time; pi rewrites tracked files, so existing clones are left alone.
      if [[ ! -d "$agent/.git" ]]; then
        $DRY_RUN_CMD timeout 120 git clone --branch ${configBranch} \
          https://github.com/ava-silver/pi-config.git "$agent" \
          || echo "pi: pi-config clone failed; switch again once online" >&2
      fi
      if [[ -d "$agent/.git" && ! -d "$agent/extensions/node_modules" ]]; then
        $DRY_RUN_CMD timeout 300 bash "$agent/setup.sh" \
          || echo "pi: pi-config setup failed; switch again once online" >&2
      fi

      if [[ ! -d "$HOME/.bun/install/global/node_modules/@earendil-works/pi-coding-agent" ]]; then
        $DRY_RUN_CMD timeout 300 bun install -g --ignore-scripts @earendil-works/pi-coding-agent \
          || echo "pi: install failed; switch again once online" >&2
      fi
    )
  '';
}
