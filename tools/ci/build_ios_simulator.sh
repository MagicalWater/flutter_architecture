#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/apps/flutter_architecture"
ios_dir="$app_dir/ios"
app_bundle="$app_dir/build/ios/iphonesimulator/Flutter Architecture.app"
project_file="$ios_dir/Runner.xcodeproj/project.pbxproj"
registrant_file="$ios_dir/Runner/GeneratedPluginRegistrant.m"

command -v flutter >/dev/null
command -v pod >/dev/null
command -v plutil >/dev/null
command -v xcodebuild >/dev/null

(
  cd "$app_dir"
  flutter clean
  flutter pub get
)

(
  cd "$ios_dir"
  pod install
)

(
  cd "$app_dir"
  flutter build ios --simulator --no-codesign -t lib/main.dart
)

if [[ ! -d "$app_bundle" ]]; then
  echo "Expected iOS Simulator app not found: $app_bundle" >&2
  exit 1
fi

bundle_identifier="$(plutil -extract CFBundleIdentifier raw "$app_bundle/Info.plist")"
deployment_target="$(
  xcodebuild \
    -workspace "$ios_dir/Runner.xcworkspace" \
    -scheme Runner \
    -sdk iphonesimulator \
    -configuration Debug \
    -showBuildSettings \
    | awk -F ' = ' '/^[[:space:]]*IPHONEOS_DEPLOYMENT_TARGET = / {print $2; exit}'
)"

if [[ "$bundle_identifier" != "com.example.flutterarchitecture" ]]; then
  echo "Unexpected bundle identifier: $bundle_identifier" >&2
  exit 1
fi

if [[ "$deployment_target" != "13.0" ]]; then
  echo "Unexpected IPHONEOS_DEPLOYMENT_TARGET: $deployment_target" >&2
  exit 1
fi

for plugin in \
  FlutterSecureStorageDarwinPlugin \
  LocalAuthPlugin \
  SharedPreferencesPlugin \
  SqflitePlugin; do
  if ! grep -Fq "$plugin registerWithRegistrar" "$registrant_file"; then
    echo "Expected plugin registration not found: $plugin" >&2
    exit 1
  fi
done

if grep -Eq 'DEVELOPMENT_TEAM =|PROVISIONING_PROFILE(_SPECIFIER)? =' "$project_file"; then
  echo "Personal signing or provisioning configuration must not be committed." >&2
  exit 1
fi

echo "iOS Simulator verification build passed."
echo "Artifact: $app_bundle"
echo "Bundle identifier: $bundle_identifier"
echo "IPHONEOS_DEPLOYMENT_TARGET: $deployment_target"
echo "Signing: no Apple Development Team or provisioning profile required"
