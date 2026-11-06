#!/usr/bin/env bash
# IT's Privileges alias only covers commands typed into an interactive shell, so
# scripts (just, anything run from an agent) still need the elevation first.
set -euo pipefail

# stderr because callers capture sudo's stdout.
/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI -a >&2

exec /usr/bin/sudo "$@"
