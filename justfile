os   := `uname -s`
user := `whoami`

host := if user == "ava.silver" { "work" } else if os == "Linux" { "pegasus" } else { "slate" }

_rebuild := if os == "Linux" { "nixos-rebuild" } else { "darwin-rebuild" }

switch:
    sudo {{ _rebuild }} switch --flake .#{{ host }}

update: && switch
    nix flake update
