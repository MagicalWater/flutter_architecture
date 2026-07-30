#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

resolve_python() {
  local candidate
  if [[ -n "${PYTHON_BIN:-}" ]] && "$PYTHON_BIN" -c 'import sys; raise SystemExit(0)' >/dev/null 2>&1; then
    printf '%s\n' "$PYTHON_BIN"
    return 0
  fi
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys; raise SystemExit(0)' >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo "A working Python 3 interpreter is required for generated verification." >&2
  return 1
}

python_bin="$(resolve_python)" || exit 69

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Generated consistency requires a clean Git working tree." >&2
  git status --short >&2
  exit 1
fi

dart run melos run build_runner
bash tools/database/export_drift_schemas.sh

(
  cd apps/flutter_architecture
  dart compile js web/drift_worker.dart -O4 -o web/drift_worker.js
  rm -f web/drift_worker.js.deps web/drift_worker.js.map
)

"$python_bin" -m unittest tools.ci.test_drift_schema_governance

if ! git diff --ignore-space-at-eol --quiet --exit-code; then
  echo "Generated tracked files are out of date." >&2
  git diff --stat >&2
  exit 1
fi

# Freezed can emit whitespace-only differences on Windows while producing the
# same semantic output as the Ubuntu CI authority. Restore only those tracked
# whitespace-only changes so the verification remains cross-platform without
# hiding substantive generated-source drift.
whitespace_only_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] && whitespace_only_files+=("$file")
done < <(git diff --name-only)
if (( ${#whitespace_only_files[@]} > 0 )); then
  git restore --worktree -- "${whitespace_only_files[@]}"
fi

if ! git diff --quiet --exit-code; then
  echo "Code generation changed tracked file content:" >&2
  git diff --stat >&2
  exit 1
fi

untracked_files="$(git ls-files --others --exclude-standard)"
if [[ -n "$untracked_files" ]]; then
  echo "Code generation created untracked files:" >&2
  printf '%s\n' "$untracked_files" >&2
  exit 1
fi

echo "Generated files are consistent with source."
