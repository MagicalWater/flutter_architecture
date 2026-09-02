#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
android_root="$repo_root/apps/flutter_architecture/android"
(cd "$android_root" && ./gradlew :app:verifyFlutterTargetPathContract --console=plain)
"$(dirname "$0")/build_android_environment.sh" development debug lib/main_development.dart mock
