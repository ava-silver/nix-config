{ lib, pkgs, ... }@args:
let
  isWork = args.isWork or false;
  configBranch = if isWork then "main" else "personal";
in
{
  bootstrap.packages = [
    pkgs.git
    pkgs.gh
    pkgs.bun
  ];

  bootstrap.steps = [
    # Branch is only chosen at clone time; pi rewrites tracked files, so existing clones are left alone.
    ''
      if [[ ! -d "$HOME/.pi/agent/.git" ]]; then
        git clone --branch ${configBranch} https://github.com/ava-silver/pi-config.git "$HOME/.pi/agent" || failed=1
      fi
      if [[ -d "$HOME/.pi/agent/.git" && ! -d "$HOME/.pi/agent/extensions/node_modules" ]]; then
        bash "$HOME/.pi/agent/setup.sh" || failed=1
      fi
    ''
    ''
      if [[ ! -d "$HOME/.bun/install/global/node_modules/@earendil-works/pi-coding-agent" ]]; then
        bun install -g --ignore-scripts @earendil-works/pi-coding-agent || failed=1
      fi
    ''
  ]
  # Private repo: skipped (not an error) until `gh auth login`; the path unit re-runs us afterwards.
  ++ lib.optional (!isWork) ''
    if [[ ! -d "$HOME/repos/pi-spotify-provider/.git" ]] && gh auth status >/dev/null 2>&1; then
      mkdir -p "$HOME/repos"
      GIT_TERMINAL_PROMPT=0 git clone https://github.com/ava-silver/pi-spotify-provider.git \
        "$HOME/repos/pi-spotify-provider" || failed=1
    fi
  '';
}
