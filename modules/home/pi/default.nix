{
  lib,
  pkgs,
  isWork,
  isPhone ? false,
  ...
}:
let
  profile =
    if isPhone then
      "phone"
    else if isWork then
      "work"
    else
      "personal";
  path = lib.makeBinPath [
    pkgs.git
    pkgs.bun
    pkgs.coreutils
  ];

  # Builds the Pi binary from the version pinned in pi-config's extensions/package.json.
  # Pi's /update command runs it after bumping the pin.
  piInstall = pkgs.writeShellApplication {
    name = "pi-install";
    runtimeInputs = with pkgs; [
      bun
      coreutils
      jq
    ];
    text = builtins.readFile ./pi-install.sh;
  };
in
{
  home.packages = [ piInstall ];

  # The binary runs from a fixed path so allowlists can name ~/.pi/bin/pi.
  home.sessionPath = [ "$HOME/.pi/bin" ];

  # Idempotent and non-fatal: if offline, run `just switch` again once connected.
  # The timeouts keep a first boot without network from stalling login.
  home.activation.pi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (
      export PATH=${path}:$PATH
      agent="$HOME/.pi/agent"

      if [[ ! -d "$agent/.git" ]]; then
        $DRY_RUN_CMD timeout 120 git clone \
          https://github.com/ava-silver/pi-config.git "$agent" \
          || echo "pi: pi-config clone failed; switch again once online" >&2
      fi

      # Linked straight into the repo so settings changed in Pi write back; assumes the clone lives at ~/nix-config.
      if [[ -d "$agent" ]]; then
        $DRY_RUN_CMD ln -sfn "$HOME/nix-config/modules/home/pi/${profile}/settings.json" "$agent/settings.json"
      fi

      if [[ -d "$agent/.git" && ! -d "$agent/extensions/node_modules" ]]; then
        $DRY_RUN_CMD timeout 300 bash "$agent/setup.sh" \
          || echo "pi: pi-config setup failed; switch again once online" >&2
      fi

      if [[ -f "$agent/extensions/package.json" ]]; then
        $DRY_RUN_CMD timeout 300 ${piInstall}/bin/pi-install \
          || echo "pi: install failed; switch again once online" >&2
      fi
    )
  '';

  # Personal machines only: the personal settings load this provider from ~/repos.
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
