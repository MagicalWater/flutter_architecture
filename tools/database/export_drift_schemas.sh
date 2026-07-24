#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_root="$repo_root/apps/flutter_architecture"
schema_root="$app_root/test/drift_schemas/app_database"

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
