#!/usr/bin/env bash
if common_dir=$(git rev-parse --git-common-dir 2>/dev/null) &&
   [[ -n "$common_dir" && -f "$common_dir/.graphite_repo_config" ]]; then
  exit 0
fi
exit 1
