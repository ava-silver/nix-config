#!/usr/bin/env bash
# Picks the Graphite profile from the origin remote's GitHub org so ddoghq
# repos use the ddog token and everything else uses the default token.
if [[ -z "${GRAPHITE_PROFILE:-}" ]]; then
  url=$(git remote get-url origin 2>/dev/null)
  case "$url" in
    *ddoghq*) export GRAPHITE_PROFILE=ddog ;;
    *)        export GRAPHITE_PROFILE=default ;;
  esac
fi
exec /opt/homebrew/bin/gt "$@"
