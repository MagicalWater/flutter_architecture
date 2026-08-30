#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
environment="$1"; scheme="$2"; configuration="$3"; sdk="$4"; entrypoint="$5"; api_mode="$6"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/tools/ci/python_runtime.sh"
[[ -n "${ARTIFACT_DIR:-}" ]] || { echo "ARTIFACT_DIR is required for iOS verification." >&2; exit 64; }
artifact_dir="$ARTIFACT_DIR"; api_base_url="${API_BASE_URL:-}"
build_workspace="$artifact_dir/.build"
derived_data_dir="$build_workspace/DerivedData"
commit_sha="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD)}"
run_key="${CI_RUN_KEY:-unmanaged}"
job_key="${CI_JOB_KEY:-unmanaged-ios-$environment}"
python_bin="$(resolve_repository_python)" || exit 69
app_dir="$("$python_bin" -c 'from pathlib import Path; import sys; root=Path(sys.argv[1]); c=[p.parent.parent for p in (root/"apps").glob("*/config/environments.json") if p.is_file()]; len(c)==1 or sys.exit("expected exactly one app environment manifest"); print(c[0])' "$repo_root")"; ios_dir="$app_dir/ios"
if [[ "$api_mode" == "real" && -z "$api_base_url" ]]; then echo "API_BASE_URL is required for $environment iOS verification." >&2; exit 1; fi
observability_remote_collection="${OBSERVABILITY_REMOTE_COLLECTION_ENABLED:-false}"
observability_acceptance_event="${OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED:-false}"
case "$observability_remote_collection" in true|false) ;; *) echo "OBSERVABILITY_REMOTE_COLLECTION_ENABLED must be true or false." >&2; exit 64 ;; esac
case "$observability_acceptance_event" in true|false) ;; *) echo "OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED must be true or false." >&2; exit 64 ;; esac

cleanup_ios_build_workspace() {
  [[ "$artifact_dir" == /* ]] || { echo "iOS artifact directory must be absolute." >&2; return 64; }
  [[ "$artifact_dir" != "/" && "$artifact_dir" != "$HOME" ]] || { echo "Unsafe iOS artifact directory." >&2; return 64; }
  [[ "$build_workspace" == "$artifact_dir/.build" ]] || { echo "Unexpected iOS build workspace: $build_workspace" >&2; return 64; }
  [[ ! -L "$build_workspace" ]] || { echo "iOS build workspace cannot be a symlink." >&2; return 64; }
  [[ ! -e "$build_workspace" ]] || rm -rf -- "$build_workspace"
}

trap cleanup_ios_build_workspace EXIT
"$python_bin" "$repo_root/tools/ci/verify_ios_firebase_config.py" "$environment"
mkdir -p "$artifact_dir"
cleanup_ios_build_workspace
rm -rf "$artifact_dir"/*.app "$artifact_dir/dSYMs"
rm -f "$artifact_dir/artifact-metadata.txt"
mkdir -p "$derived_data_dir"
(cd "$app_dir" && flutter pub get); (cd "$ios_dir" && pod install)
encode_define() { printf '%s' "$1" | base64 | tr -d '\n'; }
dart_defines="$(encode_define "NATIVE_ENVIRONMENT=$environment"),$(encode_define "API_MODE=$api_mode"),$(encode_define "APP_COMMIT_SHA=$commit_sha")"
[[ "$observability_remote_collection" == "true" ]] && dart_defines="$dart_defines,$(encode_define "OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true")"
[[ "$observability_acceptance_event" == "true" ]] && dart_defines="$dart_defines,$(encode_define "OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true")"
[[ -z "$api_base_url" ]] || dart_defines="$dart_defines,$(encode_define "API_BASE_URL=$api_base_url")"
xcodebuild -workspace "$ios_dir/Runner.xcworkspace" -scheme "$scheme" -configuration "$configuration" -sdk "$sdk" -derivedDataPath "$derived_data_dir" FLUTTER_TARGET="$entrypoint" DART_DEFINES="$dart_defines" CODE_SIGNING_ALLOWED=NO build
products="$derived_data_dir/Build/Products"; app_bundle="$(find "$products" -maxdepth 2 -type d -name '*.app' -print -quit)"
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
require_complete_dsym_set=false
if [[ "$configuration" == Release-* ]] || [[ "${GENERATE_DSYM_FOR_ACCEPTANCE:-false}" == "true" ]]; then
  require_complete_dsym_set=true
fi
if [[ "$require_complete_dsym_set" == "true" ]]; then
  [[ -d "$dsym_set_dir" ]] || {
    echo "Expected complete dSYM set was not generated: $dsym_set_dir" >&2
    exit 1
  }
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
expected_id="$("$python_bin" -c 'import json,sys; p=json.load(open(sys.argv[1], encoding="utf-8")); print(next(e["iosBundleIdentifier"] for e in p["environments"] if e["name"] == sys.argv[2]))' "$app_dir/config/environments.json" "$environment")"
[[ "$bundle_id" == "$expected_id" ]] || { echo "Unexpected bundle id: $bundle_id" >&2; exit 1; }
cat > "$artifact_dir/artifact-metadata.txt" <<EOF
commit_sha=$commit_sha
run_key=$run_key
job_key=$job_key
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
observability_remote_collection=$observability_remote_collection
observability_acceptance_event=$observability_acceptance_event
dsym=$([[ -d "$dsym_set_dir" ]] && echo present || echo not-generated)
EOF
cleanup_ios_build_workspace
trap - EXIT
echo "iOS verification artifact: $target_app"; cat "$artifact_dir/artifact-metadata.txt"
