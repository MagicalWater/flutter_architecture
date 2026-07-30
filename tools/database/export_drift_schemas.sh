#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_root="$repo_root/apps/flutter_architecture"
schema_root="$app_root/test/drift_schemas/app_database"

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
  echo "A working Python 3 interpreter is required for Drift schema export." >&2
  return 1
}

python_bin="$(resolve_python)" || exit 69

mkdir -p "$schema_root"
cd "$app_root"

for version in 1 2 3 4 5 6; do
  dart run drift_dev schema dump \
    "test/app/database/fixtures/v${version}.db" \
    "$schema_root/drift_schema_v${version}.json"
done

dart run drift_dev schema dump \
  lib/app/database/app_database.dart \
  "$schema_root/drift_schema_current.json"

"$python_bin" "$repo_root/tools/database/normalize_drift_schema_json.py" \
  "$schema_root"
