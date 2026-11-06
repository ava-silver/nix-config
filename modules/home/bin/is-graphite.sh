#!/usr/bin/env bash
set -euo pipefail

quiet=false
while getopts 'q' opt; do
  case "$opt" in
    q) quiet=true ;;
    *) exit 2 ;;
  esac
done

status="graphite not set up"
code=1
if common_dir=$(git rev-parse --git-common-dir 2>/dev/null) &&
   [[ -n "$common_dir" && -f "$common_dir/.graphite_repo_config" ]]; then
  status="graphite set up"
  code=0
fi

if [[ "$quiet" == false ]]; then
  echo "$status"
fi
exit "$code"
