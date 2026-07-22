#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/apps/flutter_architecture"
artifact_dir="${ARTIFACT_DIR:-$repo_root/artifacts/android}"
commit_sha="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD)}"
short_sha="${commit_sha:0:7}"
git_ref="${GITHUB_REF:-$(git -C "$repo_root" symbolic-ref --quiet --short HEAD || echo detached)}"
run_id="${GITHUB_RUN_ID:-local}"

mkdir -p "$artifact_dir"

(
  cd "$app_dir"
  flutter build apk --release -t lib/main.dart
)

source_apk="$app_dir/build/app/outputs/flutter-apk/app-release.apk"
target_apk="$artifact_dir/flutter-architecture-${short_sha}-release.apk"

if [[ ! -f "$source_apk" ]]; then
  echo "Expected APK not found: $source_apk" >&2
  exit 1
fi

cp "$source_apk" "$target_apk"

flutter_version_output="$(flutter --version)"
flutter_version="${flutter_version_output%%$'\n'*}"
dart_version="$(dart --version 2>&1)"
java_bin="java"
if ! java -version >/dev/null 2>&1 && [[ -x "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java" ]]; then
  java_bin="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java"
fi
java_version_output="$("$java_bin" -version 2>&1)"
java_version="${java_version_output%%$'\n'*}"

cat > "$artifact_dir/artifact-metadata.txt" <<EOF
repository=${GITHUB_REPOSITORY:-local}
commit_sha=$commit_sha
short_sha=$short_sha
git_ref=$git_ref
workflow_run_id=$run_id
flutter_version=$flutter_version
dart_version=$dart_version
java_version=$java_version
entrypoint=lib/main.dart
build_mode=release
build_command=flutter build apk --release -t lib/main.dart
signing=debug signing for verification only
distribution=not production-ready
artifact=$(basename "$target_apk")
EOF

echo "Android verification artifact: $target_apk"
echo "Metadata: $artifact_dir/artifact-metadata.txt"
