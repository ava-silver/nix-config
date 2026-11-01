#!/usr/bin/env bash
# Rebuild the pi and pi-dev binaries (pass --if-stale to skip when nothing changed).
exec bun "$HOME/.pi/agent/scripts/build-binary.ts" "$@"
