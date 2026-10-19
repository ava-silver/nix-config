{ lib, pkgs, ... }@args:
let
  isWork = args.isWork or false;
  git = "${pkgs.git}/bin/git";
  configBranch = if isWork then "main" else "personal";
in
{
  # Branch is only chosen at clone time; existing clones are left alone since pi rewrites tracked files.
  home.activation.piConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -d "$HOME/.pi/agent/.git" ]]; then
      $DRY_RUN_CMD ${git} clone --branch ${configBranch} \
        https://github.com/ava-silver/pi-config.git "$HOME/.pi/agent" \
        && PATH="${pkgs.bun}/bin:$PATH" $DRY_RUN_CMD bash "$HOME/.pi/agent/setup.sh" \
        || echo "pi-config: setup failed; check the output above and switch again" >&2
    fi
  '';

  # Private repo: needs `gh auth login`. Skips with a warning until then; the next switch retries.
  home.activation.piSpotifyProvider = lib.mkIf (!isWork) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dir="$HOME/repos/pi-spotify-provider"
      if [[ ! -d "$dir/.git" ]]; then
        bus="/run/user/$(id -u)/bus"
        [[ -S "$bus" ]] && export DBUS_SESSION_BUS_ADDRESS="unix:path=$bus"
        mkdir -p "$HOME/repos"
        GIT_TERMINAL_PROMPT=0 $DRY_RUN_CMD ${git} clone \
          https://github.com/ava-silver/pi-spotify-provider.git "$dir" \
          || echo "pi-spotify-provider: clone failed; run 'gh auth login' and switch again" >&2
      fi
    ''
  );
}
