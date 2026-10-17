#!/usr/bin/env bash
# Picks the GitHub account from the origin remote's org so ddoghq repos use
# ava-silver_ddog and everything else uses ava-silver. Shadows the real gh
# binary on PATH; calls it by absolute path to avoid infinite recursion.
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
