#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

environment="${1:-}"
dsym_dir="${2:-}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
config="$repo_root/apps/flutter_architecture/ios/Firebase/$environment/GoogleService-Info.plist"
uploader="$repo_root/apps/flutter_architecture/ios/Pods/FirebaseCrashlytics/upload-symbols"

if [[ -z "$environment" || -z "$dsym_dir" || ! -d "$dsym_dir" ]]; then
  echo "iOS dSYM upload not executed: dSYM directory is missing."
  exit 0
fi
if [[ ! -f "$config" ]]; then
  echo "iOS dSYM upload not executed: Firebase config is missing for $environment."
  exit 0
fi
if [[ ! -x "$uploader" ]]; then
  echo "iOS dSYM upload not executed: Firebase Crashlytics upload-symbols is unavailable."
  exit 0
fi

"$uploader" -gsp "$config" -p ios "$dsym_dir"
