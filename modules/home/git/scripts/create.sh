#!/usr/bin/env bash
set -euo pipefail
if ! is-graphite >/dev/null 2>&1; then
  slug=$(printf '%s' "$*" \
    | LC_ALL=C tr '[:upper:]' '[:lower:]' \
    | LC_ALL=C sed -E 's/[^a-z0-9._-]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')
  [[ -n "$slug" ]] || { echo "description must produce a non-empty branch name" >&2; exit 1; }
  branch="$USER/$slug"
  if [[ -z "$(git status --porcelain)" ]]; then
    echo "Created empty branch $branch -- nothing to submit"
    exit 0
  fi
  git add -A
  git commit -m "$*"
  base_branch="$(git rev-parse --abbrev-ref HEAD)"
  git branch "$branch"
  git reset --hard HEAD~1
  git switch "$branch"
  git push -u origin HEAD
  gh pr create --fill-first --draft --base "$base_branch"
  exit 0
fi
if [ "$#" -lt 2 ]; then
  gt create --all -m "$*"
else
  ticket=$(basename "$1")
  shift
  branch=$(echo "$ticket/$*" | tr '[:upper:]' '[:lower:]')
  if [[ "$(tr '[:upper:]' '[:lower:]' <<<"$ticket")" = "chore" ]]; then
    msg="chore: $*"
  else
    msg="[$(echo "$ticket" | tr '[:lower:]' '[:upper:]')] $*"
  fi
  gt create --all "$branch" -m "$msg"
fi
gt ss
