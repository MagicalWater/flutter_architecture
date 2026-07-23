#!/usr/bin/env bash
set -euo pipefail

suite="${1:-all}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

run_quality() {
  dart pub get
  python3 tools/docs/check_docs.py .
  python3 -m unittest discover -s tools/ci -p 'test_*.py'
  dart run melos run analyze
  bash tools/ci/verify_generated.sh
  dart run melos exec -- flutter test
  git diff --check
}

run_android() {
  ARTIFACT_DIR="$repo_root/artifacts/android/development" \
    bash tools/ci/build_android_development.sh
  API_BASE_URL="${API_BASE_URL:-https://api.acme.test}" \
    ARTIFACT_DIR="$repo_root/artifacts/android/production" \
    bash tools/ci/build_android_production.sh
}

run_ios() {
  ARTIFACT_DIR="$repo_root/artifacts/ios/development" \
    bash tools/ci/build_ios_development.sh
  API_BASE_URL="${API_BASE_URL:-https://api.acme.test}" \
    ARTIFACT_DIR="$repo_root/artifacts/ios/production" \
    bash tools/ci/build_ios_production.sh
}

run_observability() {
  local api_base_url="${API_BASE_URL:-https://api.acme.test}"

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$repo_root/artifacts/observability/android-production" \
    bash tools/ci/build_android_production.sh
  if [[ -n "${FIREBASE_ANDROID_APP_ID:-}" ]]; then
    bash tools/ci/upload_android_flutter_symbols.sh \
      "$repo_root/artifacts/observability/android-production/flutter-symbols"
  else
    echo "Android production symbol upload skipped: FIREBASE_ANDROID_APP_ID is unset."
  fi

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$repo_root/artifacts/observability/android-staging" \
    OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true \
    OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true \
    bash tools/ci/build_android_environment.sh \
      staging release lib/main_staging.dart real
  if [[ -n "${FIREBASE_ANDROID_STAGING_APP_ID:-}" ]]; then
    FIREBASE_ANDROID_APP_ID="$FIREBASE_ANDROID_STAGING_APP_ID" \
      bash tools/ci/upload_android_flutter_symbols.sh \
      "$repo_root/artifacts/observability/android-staging/flutter-symbols"
  else
    echo "Android staging symbol upload skipped: FIREBASE_ANDROID_STAGING_APP_ID is unset."
  fi

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$repo_root/artifacts/observability/ios-production" \
    bash tools/ci/build_ios_production.sh
  bash tools/ci/upload_ios_dsyms.sh production \
    "$repo_root/artifacts/observability/ios-production/dSYMs"

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$repo_root/artifacts/observability/ios-staging" \
    OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true \
    OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true \
    GENERATE_DSYM_FOR_ACCEPTANCE=true \
    bash tools/ci/build_ios_environment.sh \
      staging Staging Debug-staging iphonesimulator lib/main_staging.dart real
  bash tools/ci/upload_ios_dsyms.sh staging \
    "$repo_root/artifacts/observability/ios-staging/dSYMs"
}

case "$suite" in
  quality) run_quality ;;
  android) run_android ;;
  ios) run_ios ;;
  observability) run_observability ;;
  all)
    run_quality
    run_android
    run_ios
    ;;
  *)
    echo "Usage: $0 {quality|android|ios|observability|all}" >&2
    exit 64
    ;;
esac
