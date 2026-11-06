#!/usr/bin/env bash
if [ $# -eq 0 ]; then
  msg=$(gum input --placeholder 'Summary of this change')
else
  msg="$*"
fi
ticket=$(git-ticket)
if [ -n "$ticket" ]; then
  ticket="[$ticket] "
fi
if is-graphite -q; then
  gt cm -m "$ticket$msg"
else
  git commit -m "$ticket$msg"
fi
