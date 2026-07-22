#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Generated consistency requires a clean Git working tree." >&2
  git status --short >&2
  exit 1
fi

dart run melos run build_runner

if ! git diff --ignore-space-at-eol --quiet --exit-code; then
  echo "Generated tracked files are out of date." >&2
  git diff --stat >&2
  exit 1
fi

# Freezed can emit whitespace-only differences on Windows while producing the
# same semantic output as the Ubuntu CI authority. Restore only those tracked
# whitespace-only changes so the verification remains cross-platform without
# hiding substantive generated-source drift.
mapfile -t whitespace_only_files < <(git diff --name-only)
if (( ${#whitespace_only_files[@]} > 0 )); then
  git restore --worktree -- "${whitespace_only_files[@]}"
fi

status="$(git status --porcelain)"
if [[ -n "$status" ]]; then
  echo "Code generation changed the Git working tree:" >&2
  printf '%s\n' "$status" >&2
  exit 1
fi

echo "Generated files are consistent with source."
