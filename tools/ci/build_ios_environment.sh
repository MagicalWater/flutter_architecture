#!/usr/bin/env bash
set -euo pipefail
environment="$1"; scheme="$2"; configuration="$3"; sdk="$4"; entrypoint="$5"; api_mode="$6"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/apps/flutter_architecture"; ios_dir="$app_dir/ios"
artifact_dir="${ARTIFACT_DIR:-$repo_root/artifacts/ios/$environment}"; api_base_url="${API_BASE_URL:-}"
commit_sha="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD)}"
if [[ "$api_mode" == "real" && -z "$api_base_url" ]]; then echo "API_BASE_URL is required for $environment iOS verification." >&2; exit 1; fi
mkdir -p "$artifact_dir"; rm -rf "$artifact_dir"/*.app "$artifact_dir/artifact-metadata.txt" "$artifact_dir/DerivedData"
(cd "$app_dir" && flutter pub get); (cd "$ios_dir" && pod install)
encode_define() { printf '%s' "$1" | base64 | tr -d '\n'; }
dart_defines="$(encode_define "NATIVE_ENVIRONMENT=$environment"),$(encode_define "API_MODE=$api_mode")"
[[ -z "$api_base_url" ]] || dart_defines="$dart_defines,$(encode_define "API_BASE_URL=$api_base_url")"
xcodebuild -workspace "$ios_dir/Runner.xcworkspace" -scheme "$scheme" -configuration "$configuration" -sdk "$sdk" -derivedDataPath "$artifact_dir/DerivedData" FLUTTER_TARGET="$entrypoint" DART_DEFINES="$dart_defines" CODE_SIGNING_ALLOWED=NO build
products="$artifact_dir/DerivedData/Build/Products"; app_bundle="$(find "$products" -maxdepth 2 -type d -name '*.app' -print -quit)"
[[ -n "$app_bundle" ]] || { echo "Expected iOS app not found under $products" >&2; exit 1; }
target_app="$artifact_dir/$(basename "$app_bundle")"; cp -R "$app_bundle" "$target_app"
bundle_id="$(plutil -extract CFBundleIdentifier raw "$target_app/Info.plist")"
expected_id="com.example.flutterarchitecture"; [[ "$environment" == "production" ]] || expected_id+=".$environment"
[[ "$bundle_id" == "$expected_id" ]] || { echo "Unexpected bundle id: $bundle_id" >&2; exit 1; }
cat > "$artifact_dir/artifact-metadata.txt" <<EOF
commit_sha=$commit_sha
environment=$environment
platform=ios
scheme=$scheme
configuration=$configuration
sdk=$sdk
entrypoint=$entrypoint
api_mode=$api_mode
bundle_id=$bundle_id
signing=unsigned verification build
distribution=not production-ready
artifact=$(basename "$target_app")
EOF
echo "iOS verification artifact: $target_app"; cat "$artifact_dir/artifact-metadata.txt"
