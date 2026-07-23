#!/usr/bin/env bash
set -euo pipefail
environment="$1"; scheme="$2"; configuration="$3"; sdk="$4"; entrypoint="$5"; api_mode="$6"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/apps/flutter_architecture"; ios_dir="$app_dir/ios"
artifact_dir="${ARTIFACT_DIR:-$repo_root/artifacts/ios/$environment}"; api_base_url="${API_BASE_URL:-}"
commit_sha="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD)}"
if [[ "$api_mode" == "real" && -z "$api_base_url" ]]; then echo "API_BASE_URL is required for $environment iOS verification." >&2; exit 1; fi
python3 "$repo_root/tools/ci/verify_ios_firebase_config.py" "$environment"
mkdir -p "$artifact_dir"; rm -rf "$artifact_dir"/*.app "$artifact_dir/artifact-metadata.txt" "$artifact_dir/DerivedData"
(cd "$app_dir" && flutter pub get); (cd "$ios_dir" && pod install)
encode_define() { printf '%s' "$1" | base64 | tr -d '\n'; }
dart_defines="$(encode_define "NATIVE_ENVIRONMENT=$environment"),$(encode_define "API_MODE=$api_mode"),$(encode_define "APP_COMMIT_SHA=$commit_sha")"
[[ "${OBSERVABILITY_REMOTE_COLLECTION_ENABLED:-false}" == "true" ]] && dart_defines="$dart_defines,$(encode_define "OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true")"
[[ "${OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED:-false}" == "true" ]] && dart_defines="$dart_defines,$(encode_define "OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true")"
[[ -z "$api_base_url" ]] || dart_defines="$dart_defines,$(encode_define "API_BASE_URL=$api_base_url")"
xcodebuild -workspace "$ios_dir/Runner.xcworkspace" -scheme "$scheme" -configuration "$configuration" -sdk "$sdk" -derivedDataPath "$artifact_dir/DerivedData" FLUTTER_TARGET="$entrypoint" DART_DEFINES="$dart_defines" CODE_SIGNING_ALLOWED=NO build
products="$artifact_dir/DerivedData/Build/Products"; app_bundle="$(find "$products" -maxdepth 2 -type d -name '*.app' -print -quit)"
[[ -n "$app_bundle" ]] || { echo "Expected iOS app not found under $products" >&2; exit 1; }
target_app="$artifact_dir/$(basename "$app_bundle")"; cp -R "$app_bundle" "$target_app"
expected_dsym_name="$(basename "$app_bundle").dSYM"
dsym_bundle="$(find "$products" -maxdepth 3 -type d -name "$expected_dsym_name" -print -quit)"
if [[ -z "$dsym_bundle" && "${GENERATE_DSYM_FOR_ACCEPTANCE:-false}" == "true" ]]; then
  executable_name="$(plutil -extract CFBundleExecutable raw "$app_bundle/Info.plist")"
  generated_dsym="$products/$expected_dsym_name"
  xcrun dsymutil "$app_bundle/$executable_name" -o "$generated_dsym"
  dsym_bundle="$generated_dsym"
fi
if [[ "$configuration" == Release-* && -z "$dsym_bundle" ]]; then
  echo "Expected Runner dSYM was not generated under $products" >&2
  exit 1
fi
dsym_set_dir="$artifact_dir/dSYMs"
if [[ -n "$dsym_bundle" ]]; then
  mkdir -p "$dsym_set_dir"
  cp -R "$dsym_bundle" "$dsym_set_dir/$expected_dsym_name"
fi
app_framework_dsym="$(find "$products" -maxdepth 4 -type d -name 'App.framework.dSYM' -print -quit)"
if [[ -n "$app_framework_dsym" ]]; then
  mkdir -p "$dsym_set_dir"
  cp -R "$app_framework_dsym" "$dsym_set_dir/App.framework.dSYM"
fi
if [[ "${GENERATE_DSYM_FOR_ACCEPTANCE:-false}" == "true" ]]; then
  app_framework_binary="$app_bundle/Frameworks/App.framework/App"
  if [[ -f "$app_framework_binary" && ! -d "$dsym_set_dir/App.framework.dSYM" ]]; then
    mkdir -p "$dsym_set_dir"
    xcrun dsymutil "$app_framework_binary" -o "$dsym_set_dir/App.framework.dSYM"
  fi
fi
bundle_id="$(plutil -extract CFBundleIdentifier raw "$target_app/Info.plist")"
if [[ -d "$dsym_set_dir" ]]; then
  dsym_uuids="$(find "$dsym_set_dir" -type f -path '*/DWARF/*' -print0 | while IFS= read -r -d '' file; do xcrun dwarfdump --uuid "$file"; done | awk '{print $2}' | sort -u)"
  required_binaries=("$target_app/$(plutil -extract CFBundleExecutable raw "$target_app/Info.plist")")
  [[ ! -f "$target_app/Frameworks/App.framework/App" ]] || required_binaries+=("$target_app/Frameworks/App.framework/App")
  for binary in "${required_binaries[@]}"; do
    while read -r uuid; do
      [[ -z "$uuid" ]] && continue
      grep -qx "$uuid" <<< "$dsym_uuids" || {
        echo "Required binary UUID is missing from dSYM set: binary=$binary uuid=$uuid" >&2
        exit 1
      }
    done < <(xcrun dwarfdump --uuid "$binary" | awk '{print $2}' | sort -u)
  done
fi
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
dsym=$([[ -d "$dsym_set_dir" ]] && echo present || echo not-generated)
EOF
echo "iOS verification artifact: $target_app"; cat "$artifact_dir/artifact-metadata.txt"
