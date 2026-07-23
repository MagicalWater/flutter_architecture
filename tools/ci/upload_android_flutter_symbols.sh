#!/usr/bin/env bash
set -euo pipefail

symbols_dir="${1:-}"
if [[ -z "$symbols_dir" || ! -d "$symbols_dir" ]]; then
  echo "Flutter symbols upload not executed: symbols directory is missing." >&2
  exit 0
fi

if [[ -z "${FIREBASE_ANDROID_APP_ID:-}" ]]; then
  echo "Flutter symbols upload not executed: FIREBASE_ANDROID_APP_ID is not configured."
  exit 0
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "Flutter symbols upload not executed: Firebase CLI is unavailable."
  exit 0
fi

firebase crashlytics:symbols:upload \
  --app="$FIREBASE_ANDROID_APP_ID" \
  "$symbols_dir"
