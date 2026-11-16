# Herdr

Your settings, keybindings, purple theme, Islands layout, and custom mods link from `~/.config/herdr-app` into this directory. Sessions, machine connections, window positions, generated files, and built-in mods stay local. Because `keys.json` is edited, Herdr no longer adds new default shortcuts to it; add them by hand.

Run `just switch` from the repository root to apply changes. On macOS, nix-darwin installs the GUI through the official `herdr-app` Homebrew cask. Home Manager installs the pinned terminal core from Herdr's signed release on macOS and its static release on Linux. The GUI keeps its own update mechanism; update the core version and hashes in `../desktop.nix` through Nix.

New installations select Islands. Existing installations keep their selected layout; switch with `herdr-app do layout.switch '{"name":"islands"}'`.

The layout and six mods come from [CodeyPacker's Islands](https://github.com/CodeyPacker/herdr-mods/tree/main/islands), with local title, spacing, and opacity changes. These copies do not receive upstream updates automatically. Keep the included MIT license when redistributing them.

## Sub-agents

A sub-agent (a terminal another agent started with `hc run`) belongs to that agent, which starts and stops it. In the Islands layout, closing a sub-agent sends it back under its parent (`terminal.park`) instead of ending it: the tab and pane **X** buttons, **cmd-w**, **cmd-shift-w**, and the tab's **Close** menu item. A sub-agent pane's right-click menu offers **Send back** without **Close pane**. `islands-menu` is a copy of Herdr's `menu` mod with these changes; it does not receive Herdr's updates.

Validate a mod with `herdr-app check ~/.config/herdr-app/mods/<name>`.
