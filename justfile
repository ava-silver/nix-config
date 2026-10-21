os := `uname -s`
user := `whoami`

host := if user == "ava.silver" { "work" } else if os == "Linux" { `hostname` } else { "slate" }

_rebuild := if os == "Linux" { "nixos-rebuild" } else { "darwin-rebuild" }

switch: && _hooks
    sudo {{ _rebuild }} switch --flake .#{{ host }}

# Runs after the switch so prek exists on a fresh machine. --force: see install-hooks in rc.zsh.
_hooks:
    @[ -e "$(git rev-parse --git-path hooks/pre-commit)" ] || prek install --force

update: && switch
    nix flake update
