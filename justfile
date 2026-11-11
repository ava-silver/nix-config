os := `uname -s`
user := `whoami`

droid := path_exists("/data/data/com.termux.nix")

host := if droid == "true" { "phone" } else if user == "ava.silver" { "work" } else if os == "Linux" { `hostname` } else { "slate" }

_rebuild := if os == "Linux" { "nixos-rebuild" } else { "darwin-rebuild" }

# Nix-on-Droid has no sudo and its own switch command.
_switch := if droid == "true" { "nix-on-droid switch" } else { "sudo " + _rebuild + " switch" }

switch: && _hooks _restart-apps
    {{ _switch }} --flake .#{{ host }}

# Runs after the switch so prek exists on a fresh machine. --force: see install-hooks in rc.zsh.
_hooks:
    @[ -e "$(git rev-parse --git-path hooks/pre-commit)" ] || prek install --force

# Raycast keeps a stale index after its cask updates. Relaunch it only if it was running.
_restart-apps:
    @[ "{{ os }}" != Darwin ] || ! pgrep -qx Raycast || { pkill -x Raycast; sleep 1; open -a Raycast; }

attr := if droid == "true" { "nixOnDroidConfigurations." + host + ".activationPackage" } else if os == "Linux" { "nixosConfigurations." + host + ".config.system.build.toplevel" } else { "darwinConfigurations." + host + ".system" }

others := `jq -r '.nodes.root.inputs | keys - ["nixpkgs"] | join(" ")' flake.lock`

# nixpkgs is excluded; use update-nixpkgs once the packages you need are cached.
update: (_update others) && switch

update-nixpkgs: (_update "nixpkgs") && switch

# Rolls back flake.lock unless you confirm when the update would compile packages (those missing from the binary cache).
_update inputs:
    #!/usr/bin/env bash
    set -euo pipefail
    backup=$(mktemp)
    cp flake.lock "$backup"
    nix flake update {{ inputs }}
    built=$(nix build --dry-run .#{{ attr }} 2>&1 | awk '/will be built/{f=1;next} /will be fetched/{f=0} f&&/^ *\/nix\/store/{print $1}')
    from_source=$(echo "$built" | xargs -r nix derivation show | jq -r '(.derivations // .) | to_entries[] | select(.value.env.src != null or (.value.env.__json // "{}" | fromjson | has("src"))) | .value.name // .value.env.name // .key')
    if [ -n "$from_source" ]; then
        echo "These packages compile from source:"; echo "$from_source" | sed 's/^/  /'
        read -rp "Keep the update? [y/N] " answer
        [[ $answer == [yY]* ]] || { cp "$backup" flake.lock; echo "Restored flake.lock"; exit 1; }
    fi
