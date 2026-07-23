#!/usr/bin/env bash
set -euo pipefail
environment="$1"; build_mode="$2"; entrypoint="$3"; api_mode="$4"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/apps/flutter_architecture"
artifact_dir="${ARTIFACT_DIR:-$repo_root/artifacts/android/$environment}"
flutter_symbols_dir="$artifact_dir/flutter-symbols"
api_base_url="${API_BASE_URL:-}"
commit_sha="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD)}"
if [[ "$api_mode" == "real" && -z "$api_base_url" ]]; then echo "API_BASE_URL is required for $environment Android verification." >&2; exit 1; fi
python3 "$repo_root/tools/ci/verify_android_firebase_config.py" "$environment"
mkdir -p "$artifact_dir"; rm -rf "$flutter_symbols_dir"; rm -f "$artifact_dir"/*.apk "$artifact_dir/artifact-metadata.txt" "$artifact_dir/mapping.txt"
args=(apk "--$build_mode" --flavor "$environment" -t "$entrypoint" "--dart-define=API_MODE=$api_mode")
args+=("--dart-define=APP_COMMIT_SHA=$commit_sha")
[[ "${OBSERVABILITY_REMOTE_COLLECTION_ENABLED:-false}" == "true" ]] && args+=("--dart-define=OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true")
[[ "${OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED:-false}" == "true" ]] && args+=("--dart-define=OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true")
[[ -z "$api_base_url" ]] || args+=("--dart-define=API_BASE_URL=$api_base_url")
if [[ "$environment" == "production" && "$build_mode" == "release" ]]; then
  mkdir -p "$flutter_symbols_dir"
  args+=(--obfuscate "--split-debug-info=$flutter_symbols_dir")
fi
(cd "$app_dir" && flutter build "${args[@]}")
if [[ "$environment" == "production" && "$build_mode" == "release" ]] && ! find "$flutter_symbols_dir" -type f -name '*.symbols' -print -quit | grep -q .; then
  echo "Expected Flutter symbols were not generated: $flutter_symbols_dir" >&2
  exit 1
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
apkanalyzer="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}/cmdline-tools/latest/bin/apkanalyzer"
[[ -x "$apkanalyzer" ]] || apkanalyzer="$(command -v apkanalyzer || true)"
[[ -n "$apkanalyzer" ]] || { echo "apkanalyzer not found" >&2; exit 1; }
if ! java -version >/dev/null 2>&1 && [[ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
package_id="$($apkanalyzer manifest application-id "$target_apk")"
expected_id="com.example.flutterarchitecture"; [[ "$environment" == "production" ]] || expected_id+=".$environment"
[[ "$package_id" == "$expected_id" ]] || { echo "Unexpected package id: $package_id" >&2; exit 1; }
cat > "$artifact_dir/artifact-metadata.txt" <<EOF
commit_sha=$commit_sha
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
flutter_symbols=$([[ -d "$flutter_symbols_dir" ]] && find "$flutter_symbols_dir" -type f | wc -l | tr -d ' ' || echo 0)
mapping_file=$([[ -f "$artifact_dir/mapping.txt" ]] && echo present || echo not-generated)
EOF
echo "Android verification artifact: $target_apk"; cat "$artifact_dir/artifact-metadata.txt"
