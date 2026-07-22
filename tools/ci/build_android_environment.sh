#!/usr/bin/env bash
set -euo pipefail
environment="$1"; build_mode="$2"; entrypoint="$3"; api_mode="$4"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/apps/flutter_architecture"
artifact_dir="${ARTIFACT_DIR:-$repo_root/artifacts/android/$environment}"
api_base_url="${API_BASE_URL:-}"
if [[ "$api_mode" == "real" && -z "$api_base_url" ]]; then echo "API_BASE_URL is required for $environment Android verification." >&2; exit 1; fi
mkdir -p "$artifact_dir"; rm -f "$artifact_dir"/*.apk "$artifact_dir/artifact-metadata.txt"
args=(apk "--$build_mode" --flavor "$environment" -t "$entrypoint" "--dart-define=API_MODE=$api_mode")
[[ -z "$api_base_url" ]] || args+=("--dart-define=API_BASE_URL=$api_base_url")
(cd "$app_dir" && flutter build "${args[@]}")
source_apk="$app_dir/build/app/outputs/flutter-apk/app-$environment-$build_mode.apk"
target_apk="$artifact_dir/flutter-architecture-$environment-$build_mode.apk"
[[ -f "$source_apk" ]] || { echo "Expected APK not found: $source_apk" >&2; exit 1; }
cp "$source_apk" "$target_apk"
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
EOF
echo "Android verification artifact: $target_apk"; cat "$artifact_dir/artifact-metadata.txt"
