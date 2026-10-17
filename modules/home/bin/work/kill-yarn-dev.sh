#!/usr/bin/env bash
set -euo pipefail

common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
  echo "Not inside a Git worktree." >&2
  exit 2
}

worktrees=()
while IFS= read -r worktree; do
  worktrees+=("$worktree")
done < <(git --git-dir="$common_dir" worktree list --porcelain | awk '/^worktree / { sub(/^worktree /, ""); print }')

repo_dir=$(dirname "$common_dir")
repo_name=$(basename "$repo_dir")
worktrees_prefix="$(dirname "$repo_dir")/${repo_name}.worktrees/"

in_worktree() {
  local cwd=$1 worktree
  [[ "$cwd" == "$worktrees_prefix"* ]] && return 0
  for worktree in "${worktrees[@]}"; do
    [[ "$cwd" == "$worktree" || "$cwd" == "$worktree"/* ]] && return 0
  done
  return 1
}

cwd_for_pid() {
  lsof -a -d cwd -p "$1" -Fn 2>/dev/null | awk '/^n/ { sub(/^n/, ""); print; exit }'
}

candidates=()
while IFS= read -r pid; do
  candidates+=("$pid")
done < <(ps -axo pid=,command= | awk '$0 ~ /(^|[[:space:]])yarn(\.js)?([[:space:]]+(run[[:space:]]+)?)?[[:space:]]+dev([[:space:]]|$)/ || $0 ~ /(^|[[:space:]])dev-local([[:space:]]|$)/ { print $1 }')

pids=()
for pid in "${candidates[@]}"; do
  cwd=$(cwd_for_pid "$pid")
  [[ -n "$cwd" ]] && in_worktree "$cwd" && pids+=("$pid")
done

if ((${#pids[@]} == 0)); then
  echo "No yarn dev servers found for this repository's worktrees."
  exit 0
fi

echo "Yarn dev servers to stop:"
for pid in "${pids[@]}"; do
  ps -p "$pid" -o pid=,command=
  echo "  cwd: $(cwd_for_pid "$pid")"
done

kill_tree() {
  local parent=$1 child
  while read -r child; do
    [[ -n "$child" ]] && kill_tree "$child"
  done < <(pgrep -P "$parent" || true)
  kill -TERM "$parent" 2>/dev/null || true
}

for pid in "${pids[@]}"; do
  kill_tree "$pid"
done

echo "Stopped ${#pids[@]} yarn dev server(s)."
