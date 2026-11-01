#!/usr/bin/env bash
# Compiled binary that loads extensions from disk, so /reload picks up edits.
bin="$HOME/.pi/binary/pi-dev"
[[ -x "$bin" ]] && exec "$bin" "$@"
exec bun "$HOME/.bun/install/global/node_modules/@earendil-works/pi-coding-agent/dist/cli.js" "$@"
