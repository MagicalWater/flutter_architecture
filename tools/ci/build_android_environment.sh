#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
environment="$1"; build_mode="$2"; entrypoint="$3"; api_mode="$4"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/tools/ci/python_runtime.sh"
[[ -n "${ARTIFACT_DIR:-}" ]] || { echo "ARTIFACT_DIR is required for Android verification." >&2; exit 64; }
artifact_dir="$ARTIFACT_DIR"
flutter_symbols_dir="$artifact_dir/flutter-symbols"
flutter_symbols_staging_dir="$artifact_dir/.flutter-symbols-build-$$"
api_base_url="${API_BASE_URL:-}"
commit_sha="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD)}"
run_key="${CI_RUN_KEY:-unmanaged}"
job_key="${CI_JOB_KEY:-unmanaged-android-$environment}"
python_bin="$(resolve_repository_python)" || exit 69
app_dir="$("$python_bin" -c 'from pathlib import Path; import sys; root=Path(sys.argv[1]); c=[p.parent.parent for p in (root/"apps").glob("*/config/environments.json") if p.is_file()]; len(c)==1 or sys.exit("expected exactly one app environment manifest"); print(c[0])' "$repo_root")"

cleanup_android_symbol_staging() {
  if [[ "$flutter_symbols_staging_dir" == "$artifact_dir"/.flutter-symbols-build-* ]]; then
    rm -rf "$flutter_symbols_staging_dir"
  fi
}
trap cleanup_android_symbol_staging EXIT

if [[ "$api_mode" == "real" && -z "$api_base_url" ]]; then echo "API_BASE_URL is required for $environment Android verification." >&2; exit 1; fi
observability_remote_collection="${OBSERVABILITY_REMOTE_COLLECTION_ENABLED:-false}"
observability_acceptance_event="${OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED:-false}"
case "$observability_remote_collection" in true|false) ;; *) echo "OBSERVABILITY_REMOTE_COLLECTION_ENABLED must be true or false." >&2; exit 64 ;; esac
case "$observability_acceptance_event" in true|false) ;; *) echo "OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED must be true or false." >&2; exit 64 ;; esac
"$python_bin" "$repo_root/tools/ci/verify_android_firebase_config.py" "$environment"
mkdir -p "$artifact_dir"; rm -rf "$flutter_symbols_dir" "$flutter_symbols_staging_dir"; rm -f "$artifact_dir"/*.apk "$artifact_dir/artifact-metadata.txt" "$artifact_dir/mapping.txt"
args=(apk "--$build_mode" --flavor "$environment" -t "$entrypoint" "--dart-define=API_MODE=$api_mode")
args+=("--dart-define=APP_COMMIT_SHA=$commit_sha")
[[ "$observability_remote_collection" == "true" ]] && args+=("--dart-define=OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true")
[[ "$observability_acceptance_event" == "true" ]] && args+=("--dart-define=OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true")
[[ -z "$api_base_url" ]] || args+=("--dart-define=API_BASE_URL=$api_base_url")
if [[ "$build_mode" == "release" ]]; then
  mkdir -p "$flutter_symbols_staging_dir"
  args+=(--obfuscate "--split-debug-info=$flutter_symbols_staging_dir")
fi
(cd "$app_dir" && flutter build "${args[@]}")
if [[ "$build_mode" == "release" ]]; then
  if ! find "$flutter_symbols_staging_dir" -type f -name '*.symbols' -print -quit | grep -q .; then
    echo "Expected Flutter symbols were not generated: $flutter_symbols_staging_dir" >&2
    exit 1
  fi
  rm -rf "$flutter_symbols_dir"
  mv "$flutter_symbols_staging_dir" "$flutter_symbols_dir"
fi
source_apk="$app_dir/build/app/outputs/flutter-apk/app-$environment-$build_mode.apk"
target_apk="$artifact_dir/flutter-architecture-$environment-$build_mode.apk"
[[ -f "$source_apk" ]] || { echo "Expected APK not found: $source_apk" >&2; exit 1; }
cp "$source_apk" "$target_apk"
case "$build_mode" in
  release) variant_suffix="Release" ;;
  debug) variant_suffix="Debug" ;;
  profile) variant_suffix="Profile" ;;
  *) echo "Unsupported Android build mode: $build_mode" >&2; exit 1 ;;
esac
mapping_source="$(find "$app_dir/build/app/outputs/mapping" -path "*/${environment}${variant_suffix}/mapping.txt" -print -quit 2>/dev/null || true)"
if [[ -n "$mapping_source" && -f "$mapping_source" ]]; then cp "$mapping_source" "$artifact_dir/mapping.txt"; fi

resolve_apkanalyzer() {
  local sdk_root candidate local_sdk

  candidate="$(command -v apkanalyzer || true)"
  if [[ -n "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  local_sdk="${LOCALAPPDATA:-}"
  if [[ -n "$local_sdk" ]]; then
    local_sdk="$local_sdk/Android/Sdk"
    if command -v cygpath >/dev/null 2>&1; then
      local_sdk="$(cygpath -u "$local_sdk")"
    fi
  fi

  for sdk_root in \
    "${ANDROID_SDK_ROOT:-}" \
    "${ANDROID_HOME:-}" \
    "$local_sdk" \
    "$HOME/Library/Android/sdk"; do
    [[ -n "$sdk_root" ]] || continue
    for candidate in \
      "$sdk_root/cmdline-tools/latest/bin/apkanalyzer" \
      "$sdk_root/cmdline-tools/latest/bin/apkanalyzer.bat" \
      "$sdk_root/tools/bin/apkanalyzer" \
      "$sdk_root/tools/bin/apkanalyzer.bat"; do
      if [[ -f "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done
  done

  return 1
}

apkanalyzer="$(resolve_apkanalyzer || true)"
[[ -n "$apkanalyzer" ]] || { echo "apkanalyzer not found" >&2; exit 1; }
if ! java -version >/dev/null 2>&1 && [[ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
package_id="$($apkanalyzer manifest application-id "$target_apk")"
expected_id="$("$python_bin" -c 'import json,sys; p=json.load(open(sys.argv[1], encoding="utf-8")); print(next(e["androidApplicationId"] for e in p["environments"] if e["name"] == sys.argv[2]))' "$app_dir/config/environments.json" "$environment")"
[[ "$package_id" == "$expected_id" ]] || { echo "Unexpected package id: $package_id" >&2; exit 1; }
cat > "$artifact_dir/artifact-metadata.txt" <<EOF
commit_sha=$commit_sha
run_key=$run_key
job_key=$job_key
environment=$environment
platform=android
flavor=$environment
entrypoint=$entrypoint
api_mode=$api_mode
build_mode=$build_mode
package_id=$package_id
signing=debug signing for verification only
distribution=not production-ready
artifact=$(basename "$target_apk")
observability_remote_collection=$observability_remote_collection
observability_acceptance_event=$observability_acceptance_event
flutter_symbols=$([[ -d "$flutter_symbols_dir" ]] && find "$flutter_symbols_dir" -type f | wc -l | tr -d ' ' || echo 0)
mapping_file=$([[ -f "$artifact_dir/mapping.txt" ]] && echo present || echo not-generated)
EOF
echo "Android verification artifact: $target_apk"; cat "$artifact_dir/artifact-metadata.txt"
