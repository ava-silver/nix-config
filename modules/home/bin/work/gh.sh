#!/usr/bin/env bash
# Picks the GitHub account from the origin remote's org (ddoghq -> ava-silver_ddog, else ava-silver).
# Shadows gh on PATH, so it calls the real binary by absolute path to avoid recursion.
GH=@gh@/bin/gh
if [[ -z "${GH_TOKEN:-}${GITHUB_TOKEN:-}" && "${1:-}" != "auth" ]]; then
  url=$(git remote get-url origin 2>/dev/null)
  case "$url" in
    *ddoghq*) user=ava-silver_ddog ;;
    *)        user=ava-silver ;;
  esac
  token=$("$GH" auth token --user "$user" 2>/dev/null)
  [[ -n "$token" ]] && export GH_TOKEN="$token"
fi
exec "$GH" "$@"
