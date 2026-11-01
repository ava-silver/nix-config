#!/usr/bin/env bash
# Compiled binary (built by pi-build); falls back to the bun install if it isn't built yet.
bin="$HOME/.pi/binary/pi"
[[ -x "$bin" ]] && exec "$bin" "$@"
exec bun "$HOME/.bun/install/global/node_modules/@earendil-works/pi-coding-agent/dist/cli.js" "$@"
