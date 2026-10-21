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

      if [[ ! -d "$HOME/skills/.git" ]]; then
        $DRY_RUN_CMD timeout 120 git clone \
          https://github.com/ava-silver/skills.git "$HOME/skills" \
          || echo "pi: skills clone failed; switch again once online" >&2
      fi

      if [[ ! -d "$HOME/.bun/install/global/node_modules/@earendil-works/pi-coding-agent" ]]; then
        $DRY_RUN_CMD timeout 300 bun install -g --ignore-scripts @earendil-works/pi-coding-agent \
          || echo "pi: install failed; switch again once online" >&2
      fi
    )
  '';

  # Personal machines only: the personal pi-config branch loads this provider from ~/repos.
  # Runs after `pi` so bun and the pi install exist; same idempotent, non-fatal rules.
  home.activation.piSpotifyProvider = lib.mkIf (!isWork) (
    lib.hm.dag.entryAfter [ "pi" ] ''
      (
        export PATH=${path}:$PATH
        provider="$HOME/repos/pi-spotify-provider"

        if [[ ! -d "$provider/.git" ]]; then
          $DRY_RUN_CMD mkdir -p "$HOME/repos"
          $DRY_RUN_CMD timeout 120 git clone \
            https://github.com/ava-silver/pi-spotify-provider.git "$provider" \
            || echo "pi: spotify provider clone failed; switch again once online" >&2
        fi
        if [[ -d "$provider/.git" && ! -d "$provider/node_modules" ]]; then
          (cd "$provider" && $DRY_RUN_CMD timeout 300 bun install --ignore-scripts) \
            || echo "pi: spotify provider install failed; switch again once online" >&2
        fi
      )
    ''
  );
}
