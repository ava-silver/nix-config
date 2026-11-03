os := `uname -s`
user := `whoami`

droid := path_exists("/data/data/com.termux.nix")

host := if droid == "true" { "phone" } else if user == "ava.silver" { "work" } else if os == "Linux" { `hostname` } else { "slate" }

_rebuild := if os == "Linux" { "nixos-rebuild" } else { "darwin-rebuild" }

# Nix-on-Droid has no sudo and its own switch command.
_switch := if droid == "true" { "nix-on-droid switch" } else { "sudo " + _rebuild + " switch" }

switch: && _hooks
    {{ _switch }} --flake .#{{ host }}

# Runs after the switch so prek exists on a fresh machine. --force: see install-hooks in rc.zsh.
_hooks:
    @[ -e "$(git rev-parse --git-path hooks/pre-commit)" ] || prek install --force

update: && switch
    nix flake update
