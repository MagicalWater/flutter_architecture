#!/usr/bin/env bash
# shellcheck shell=bash
set -uo pipefail

requested_suite="${1:-all}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script_path="$repo_root/tools/ci/run_local_ci.sh"
cd "$repo_root"

resolve_python() {
  local candidate
  if [[ -n "${PYTHON_BIN:-}" ]] && "$PYTHON_BIN" -c 'import sys; raise SystemExit(0)' >/dev/null 2>&1; then
    printf '%s\n' "$PYTHON_BIN"
    return 0
  fi
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys; raise SystemExit(0)' >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo "A working Python 3 interpreter is required." >&2
  return 1
}

python_bin="$(resolve_python)" || exit 69
export PYTHON_BIN="$python_bin"
managed_execution_mode="${CI_MANAGED_EXECUTION_MODE:-manual-local}"
export CI_MANAGED_EXECUTION_MODE="$managed_execution_mode"

case "$requested_suite" in
  plan-range)
    [[ $# -eq 3 ]] || {
      echo "Usage: $0 plan-range <base> <head>" >&2
      exit 64
    }
    "$python_bin" tools/ci/validation_planner.py \
      --event push \
      --base "$2" \
      --head "$3" \
      --repository "$repo_root" \
      --stdout-json
    exit $?
    ;;
esac

python_repo_root="$repo_root"
if command -v cygpath >/dev/null 2>&1; then
  python_repo_root="$(cygpath -w "$repo_root")"
fi

utc_now() {
  "$python_bin" -c 'from datetime import datetime, timezone; print(datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"))'
}

json_fragment() {
  local payload="$1"
  local key="$2"
  JSON_PAYLOAD="$payload" "$python_bin" -c 'import json, os, sys; print(json.dumps(json.loads(os.environ["JSON_PAYLOAD"])[sys.argv[1]], separators=(",", ":")))' "$key"
}

json_path_value() {
  local payload="$1"
  local key="$2"
  JSON_PAYLOAD="$payload" "$python_bin" -c 'import json, os, sys; from pathlib import Path; print(Path(json.loads(os.environ["JSON_PAYLOAD"])[sys.argv[1]]).as_posix())' "$key"
}

resolve_managed_root() {
  CI_ARTIFACT_ROOT_INPUT="${CI_ARTIFACT_ROOT:-}" \
    CI_MANAGED_EXECUTION_MODE_INPUT="$managed_execution_mode" \
    REPO_ROOT_INPUT="$python_repo_root" \
    "$python_bin" -c '
import os
import platform
from pathlib import Path
from tools.ci.artifact_contract import resolve_artifact_root, validate_artifact_root

root = resolve_artifact_root(
    os.environ.get("CI_ARTIFACT_ROOT_INPUT") or None,
    os.environ["CI_MANAGED_EXECUTION_MODE_INPUT"],
    platform.system(),
    os.environ,
)
runner_work = (
    Path(os.environ["RUNNER_WORKSPACE"])
    if os.environ.get("RUNNER_WORKSPACE")
    else None
)
runner_temp = (
    Path(os.environ["RUNNER_TEMP"])
    if os.environ.get("RUNNER_TEMP")
    else None
)
validated = validate_artifact_root(
    root,
    Path(os.environ["REPO_ROOT_INPUT"]),
    runner_work=runner_work,
    runner_temp=runner_temp,
    home=Path.home(),
)
print(validated.as_posix())
'
}

new_manual_run_key() {
  SHELL_PID="$$" "$python_bin" -c '
from datetime import datetime, timezone
import os
import secrets

stamp = datetime.now(timezone.utc).strftime("%Y%m%dt%H%M%Sz").lower()
shell_pid = os.environ["SHELL_PID"]
print(f"local-{stamp}-{shell_pid}-{secrets.token_hex(4)}")
'
}

host_platform="$("$python_bin" -c 'import platform; value=platform.system(); print("macos" if value == "Darwin" else value.lower())')"
host_arch="$("$python_bin" -c 'import platform; print(platform.machine() or "unknown")')"
runner_name="${RUNNER_NAME:-$(hostname 2>/dev/null || echo local-host)}"
repository_id="${GITHUB_REPOSITORY:-local/$(basename "$repo_root")}"
commit_sha="${GITHUB_SHA:-$(git rev-parse HEAD)}"
git_ref="$(git symbolic-ref -q HEAD || git rev-parse HEAD)"
dirty_state=false
[[ -z "$(git status --porcelain)" ]] || dirty_state=true

execute_quality() {
  local artifact_dir="$1"
  dart pub get || return $?
  "$python_bin" tools/docs/check_docs.py . || return $?
  "$python_bin" -m unittest discover -s tools/ci -p 'test_*.py' || return $?
  dart run melos run analyze || return $?
  bash tools/ci/verify_generated.sh || return $?
  dart run melos exec -- flutter test || return $?
  git diff --check || return $?
  mkdir -p "$artifact_dir/quality"
  printf 'suite=quality\ncommit_sha=%s\nresult=success\n' "$commit_sha" > "$artifact_dir/quality/quality-result.txt"
}

execute_android() {
  local artifact_dir="$1"
  ARTIFACT_DIR="$artifact_dir/android/development" \
    bash tools/ci/build_android_development.sh || return $?
  API_BASE_URL="${API_BASE_URL:-https://api.acme.test}" \
    ARTIFACT_DIR="$artifact_dir/android/production" \
    bash tools/ci/build_android_production.sh
}

execute_ios() {
  local artifact_dir="$1"
  [[ "$host_platform" == "macos" ]] || {
    echo "iOS verification requires macOS." >&2
    return 69
  }
  ARTIFACT_DIR="$artifact_dir/ios/development" \
    bash tools/ci/build_ios_development.sh || return $?
  API_BASE_URL="${API_BASE_URL:-https://api.acme.test}" \
    ARTIFACT_DIR="$artifact_dir/ios/production" \
    bash tools/ci/build_ios_production.sh
}

execute_observability() {
  local artifact_dir="$1"
  local api_base_url="${API_BASE_URL:-https://api.acme.test}"
  local observability_acceptance_event_enabled="${OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED:-false}"
  case "$observability_acceptance_event_enabled" in
    true|false) ;;
    *) echo "OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED must be true or false." >&2; return 64 ;;
  esac

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$artifact_dir/observability/android-production" \
    bash tools/ci/build_android_production.sh || return $?
  if [[ -n "${FIREBASE_ANDROID_APP_ID:-}" ]]; then
    bash tools/ci/upload_android_flutter_symbols.sh \
      "$artifact_dir/observability/android-production/flutter-symbols" || return $?
  else
    echo "Android production symbol upload skipped: FIREBASE_ANDROID_APP_ID is unset."
  fi

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$artifact_dir/observability/android-staging" \
    OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true \
    OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED="$observability_acceptance_event_enabled" \
    bash tools/ci/build_android_environment.sh \
      staging release lib/main_staging.dart real || return $?
  if [[ -n "${FIREBASE_ANDROID_STAGING_APP_ID:-}" ]]; then
    FIREBASE_ANDROID_APP_ID="$FIREBASE_ANDROID_STAGING_APP_ID" \
      bash tools/ci/upload_android_flutter_symbols.sh \
      "$artifact_dir/observability/android-staging/flutter-symbols" || return $?
  else
    echo "Android staging symbol upload skipped: FIREBASE_ANDROID_STAGING_APP_ID is unset."
  fi

  if [[ "$host_platform" != "macos" ]]; then
    echo "iOS observability skipped: current host is $host_platform."
    return 0
  fi

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$artifact_dir/observability/ios-production" \
    bash tools/ci/build_ios_production.sh || return $?
  bash tools/ci/upload_ios_dsyms.sh production \
    "$artifact_dir/observability/ios-production/dSYMs" || return $?

  API_BASE_URL="$api_base_url" \
    ARTIFACT_DIR="$artifact_dir/observability/ios-staging" \
    OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true \
    OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED="$observability_acceptance_event_enabled" \
    GENERATE_DSYM_FOR_ACCEPTANCE=true \
    bash tools/ci/build_ios_environment.sh \
      staging Staging Debug-staging iphonesimulator lib/main_staging.dart real || return $?
  bash tools/ci/upload_ios_dsyms.sh staging \
    "$artifact_dir/observability/ios-staging/dSYMs"
}

execute_suite() {
  local suite_name="$1"
  local artifact_dir="$2"
  case "$suite_name" in
    quality) execute_quality "$artifact_dir" ;;
    android) execute_android "$artifact_dir" ;;
    ios) execute_ios "$artifact_dir" ;;
    observability) execute_observability "$artifact_dir" ;;
    *) echo "Unsupported internal suite: $suite_name" >&2; return 64 ;;
  esac
}

if [[ "$requested_suite" == "__execute" ]]; then
  [[ $# -eq 2 && -n "${ARTIFACT_DIR:-}" ]] || { echo "Invalid internal invocation." >&2; exit 64; }
  execute_suite "$2" "$ARTIFACT_DIR"
  exit $?
fi

artifact_root="$(resolve_managed_root)" || exit $?
run_key="${CI_RUN_KEY:-$(new_manual_run_key)}"
if [[ "$requested_suite" == "all" && -n "${CI_JOB_KEY:-}" ]]; then
  echo "CI_JOB_KEY cannot be shared by the all suite because each job requires a unique key." >&2
  exit 64
fi

build_metadata_json() {
  local suite_name="$1"
  local artifact_platform="$2"
  local job_key="$3"
  local started_at="$4"
  local artifact_environment="${CI_ARTIFACT_ENVIRONMENT:-}"
  local artifact_build_mode="${CI_ARTIFACT_BUILD_MODE:-}"
  local artifact_kind="${CI_ARTIFACT_KIND:-${suite_name}-evidence}"
  [[ -n "$artifact_environment" ]] || artifact_environment="$(
    [[ "$suite_name" == "quality" ]] && printf repository || printf multiple
  )"
  [[ -n "$artifact_build_mode" ]] || artifact_build_mode="$(
    [[ "$suite_name" == "quality" ]] && printf verification || printf multiple
  )"
  METADATA_REPOSITORY="$repository_id" \
    METADATA_GIT_REF="${GITHUB_REF:-$git_ref}" \
    METADATA_DIRTY_STATE="$dirty_state" \
    METADATA_JOB="$job_key" \
    METADATA_HOST_OS="$host_platform" \
    METADATA_HOST_ARCH="$host_arch" \
    METADATA_RUNNER_NAME="$runner_name" \
    METADATA_SUITE="$suite_name" \
    METADATA_PLATFORM="$artifact_platform" \
    METADATA_ENVIRONMENT="$artifact_environment" \
    METADATA_BUILD_MODE="$artifact_build_mode" \
    METADATA_ARTIFACT_KIND="$artifact_kind" \
    METADATA_STARTED_AT="$started_at" \
    "$python_bin" -c '
import json
import os

suite = os.environ["METADATA_SUITE"]
payload = {
    "repository": os.environ["METADATA_REPOSITORY"],
    "git_ref": os.environ["METADATA_GIT_REF"],
    "dirty_state": os.environ["METADATA_DIRTY_STATE"] == "true",
    "run_id": os.environ.get("GITHUB_RUN_ID"),
    "run_attempt": int(os.environ["GITHUB_RUN_ATTEMPT"]) if os.environ.get("GITHUB_RUN_ATTEMPT") else None,
    "workflow": os.environ.get("GITHUB_WORKFLOW"),
    "job": os.environ.get("GITHUB_JOB") or os.environ["METADATA_JOB"],
    "execution_mode": os.environ.get("CI_MANAGED_EXECUTION_MODE", "manual-local"),
    "host_os": os.environ["METADATA_HOST_OS"],
    "host_arch": os.environ["METADATA_HOST_ARCH"],
    "runner_name": os.environ["METADATA_RUNNER_NAME"],
    "suite": suite,
    "classifier_reason": os.environ.get("CI_CLASSIFIER_REASON", "manual-local-explicit-suite"),
    "started_at": os.environ["METADATA_STARTED_AT"],
    "platform": os.environ["METADATA_PLATFORM"],
    "environment": os.environ["METADATA_ENVIRONMENT"],
    "build_mode": os.environ["METADATA_BUILD_MODE"],
    "artifact_kind": os.environ["METADATA_ARTIFACT_KIND"],
    "sensitivity": "internal-verification",
    "signing": "verification-only",
    "distribution": "not-for-distribution",
}
print(json.dumps(payload, separators=(",", ":")))
'
}

build_finalize_json() {
  local label="$1"
  local result="$2"
  local exit_code="$3"
  local started_at="$4"
  local completed_at="$5"
  local retention_class="$6"
  FINALIZE_LABEL="$label" \
    FINALIZE_RESULT="$result" \
    FINALIZE_EXIT_CODE="$exit_code" \
    FINALIZE_STARTED_AT="$started_at" \
    FINALIZE_COMPLETED_AT="$completed_at" \
    FINALIZE_RETENTION_CLASS="$retention_class" \
    "$python_bin" -c '
import json
import os
from datetime import datetime, timedelta
from tools.ci.artifact_contract import RETENTION_CLASSES

completed = datetime.fromisoformat(os.environ["FINALIZE_COMPLETED_AT"].replace("Z", "+00:00"))
retention_class = os.environ["FINALIZE_RETENTION_CLASS"]
eligible = completed + timedelta(days=RETENTION_CLASSES[retention_class]["max_age_days"])
payload = {
    "validations": [{
        "label": os.environ["FINALIZE_LABEL"],
        "result": os.environ["FINALIZE_RESULT"],
        "started_at": os.environ["FINALIZE_STARTED_AT"],
        "completed_at": os.environ["FINALIZE_COMPLETED_AT"],
        "exit_code": int(os.environ["FINALIZE_EXIT_CODE"]),
    }],
    "cleanup": {
        "status": "retained",
        "retention_class": retention_class,
        "eligible_at": eligible.replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "reason": "within-policy",
    },
}
print(json.dumps(payload, separators=(",", ":")))
'
}

run_managed_job() {
  local suite_name="$1"
  local platform_name="$2"
  shift 2
  local job_key="${CI_JOB_KEY:-${suite_name}-${platform_name}}"
  local configured_retention="${CI_RETENTION_CLASS:-}"
  if [[ -z "$configured_retention" ]]; then
    if [[ "$suite_name" == "observability" ]]; then
      configured_retention="observability-raw"
    else
      configured_retention="verification-success"
    fi
  fi

  local started_at
  started_at="$(utc_now)" || return $?
  local metadata_json
  metadata_json="$(build_metadata_json "$suite_name" "$platform_name" "$job_key" "$started_at")" || return $?
  local begin_json
  begin_json="$(
    "$python_bin" tools/ci/artifact_store.py begin-job \
      --root "$artifact_root" \
      --repo-root "$python_repo_root" \
      --commit-sha "$commit_sha" \
      --run-key "$run_key" \
      --job-key "$job_key" \
      --metadata-json-value "$metadata_json"
  )" || return $?

  local context_path artifact_dir
  context_path="$(json_path_value "$begin_json" context_path)" || return $?
  artifact_dir="$(json_path_value "$begin_json" artifact_dir)" || return $?

  echo "Managed local job: suite=$suite_name run_key=$run_key job_key=$job_key"
  echo "Artifact transport: local-only ($artifact_root)"

  CI_ARTIFACT_ROOT="$artifact_root" \
    CI_RUN_KEY="$run_key" \
    CI_JOB_KEY="$job_key" \
    CI_RETENTION_CLASS="$configured_retention" \
    ARTIFACT_DIR="$artifact_dir" \
    "$@"
  local primary_exit_code=$?

  local completed_at result effective_retention finalize_payload validations_json cleanup_json
  local evidence_prepare_exit_code
  completed_at="$(utc_now)"
  result=success
  effective_retention="$configured_retention"
  if [[ "$primary_exit_code" -ne 0 ]]; then
    result=failure
    effective_retention=verification-failure
  fi
  evidence_prepare_exit_code=0
  finalize_payload="$(
    build_finalize_json \
      "$suite_name" \
      "$result" \
      "$primary_exit_code" \
      "$started_at" \
      "$completed_at" \
      "$effective_retention"
  )" || evidence_prepare_exit_code=$?
  if [[ "$evidence_prepare_exit_code" -eq 0 ]]; then
    validations_json="$(json_fragment "$finalize_payload" validations)" || evidence_prepare_exit_code=$?
  fi
  if [[ "$evidence_prepare_exit_code" -eq 0 ]]; then
    cleanup_json="$(json_fragment "$finalize_payload" cleanup)" || evidence_prepare_exit_code=$?
  fi

  local finalize_exit_code summary_exit_code
  local finalize_json published_dir manifest_path
  finalize_exit_code="$evidence_prepare_exit_code"
  summary_exit_code=0

  if [[ "$evidence_prepare_exit_code" -eq 0 ]]; then
    finalize_json="$("$python_bin" tools/ci/artifact_store.py finalize-job \
      --context-json "$context_path" \
      --result "$result" \
      --validations-json-value "$validations_json" \
      --cleanup-json-value "$cleanup_json")"
    finalize_exit_code=$?
    if [[ "$finalize_exit_code" -eq 0 ]]; then
      published_dir="$(json_path_value "$finalize_json" published_dir)" || finalize_exit_code=$?
      manifest_path="$published_dir/manifest.json"
    fi
  else
    echo "Artifact evidence preparation failed for job_key=$job_key" >&2
  fi

  if [[ "$finalize_exit_code" -eq 0 ]]; then
    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
      "$python_bin" tools/ci/artifact_store.py write-summary \
        --manifest "$manifest_path" \
        --output "$GITHUB_STEP_SUMMARY" >/dev/null
      summary_exit_code=$?
      echo "Local-only evidence; not downloadable from GitHub."
    fi
  else
    echo "Artifact finalize failed for job_key=$job_key" >&2
  fi

  if [[ "$primary_exit_code" -ne 0 ]]; then
    return "$primary_exit_code"
  fi
  if [[ "$evidence_prepare_exit_code" -ne 0 ]]; then
    return "$evidence_prepare_exit_code"
  fi
  if [[ "$finalize_exit_code" -ne 0 ]]; then
    return "$finalize_exit_code"
  fi
  if [[ "$summary_exit_code" -ne 0 ]]; then
    return "$summary_exit_code"
  fi
  return 0
}

aggregate_managed_run() {
  [[ -n "$run_key" ]] || {
    echo "A managed run key is required for aggregation." >&2
    return 64
  }

  local manifest_count
  manifest_count="$(
    ARTIFACT_ROOT_INPUT="$artifact_root" \
      COMMIT_SHA_INPUT="$commit_sha" \
      RUN_KEY_INPUT="$run_key" \
      "$python_bin" -c '
import os
from pathlib import Path

jobs = (
    Path(os.environ["ARTIFACT_ROOT_INPUT"])
    / "runs"
    / os.environ["COMMIT_SHA_INPUT"]
    / os.environ["RUN_KEY_INPUT"]
    / "jobs"
)
print(sum(1 for _ in jobs.glob("*/manifest.json")))
'
  )" || return $?

  if [[ "$manifest_count" -eq 0 ]]; then
    if [[ "${CI_ALLOW_EMPTY_AGGREGATION:-false}" == "true" ]]; then
      echo "No finalized managed jobs were produced for run_key=$run_key."
      if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
        printf '# Managed CI Artifact Run\n\nNo finalized managed jobs were produced.\n' >> "$GITHUB_STEP_SUMMARY"
      fi
      return 0
    fi
    echo "No finalized managed jobs were produced for run_key=$run_key." >&2
    return 66
  fi

  local aggregate_json run_manifest_path run_summary_path
  aggregate_json="$(
    "$python_bin" tools/ci/artifact_store.py aggregate-run \
      --root "$artifact_root" \
      --commit-sha "$commit_sha" \
      --run-key "$run_key"
  )" || return $?
  run_manifest_path="$(json_path_value "$aggregate_json" run_manifest_path)" || return $?
  run_summary_path="$(dirname "$run_manifest_path")/run-summary.md"

  "$python_bin" tools/ci/artifact_cleanup.py evaluate \
    --root "$artifact_root" \
    --dry-run >/dev/null || return $?

  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    cat "$run_summary_path" >> "$GITHUB_STEP_SUMMARY"
    printf '\nLocal-only evidence; not downloadable from GitHub.\n' >> "$GITHUB_STEP_SUMMARY"
  fi
  echo "Managed run aggregated: run_key=$run_key jobs=$manifest_count"
}

run_requested_suite() {
  local suite_name="$1"
  local target_platform
  case "$suite_name" in
    quality) target_platform="$host_platform" ;;
    android) target_platform=android ;;
    ios) target_platform=ios ;;
    observability) target_platform=multiple ;;
    *) echo "Unsupported suite: $suite_name" >&2; return 64 ;;
  esac
  run_managed_job \
    "$suite_name" \
    "$target_platform" \
    bash "$script_path" __execute "$suite_name"
}

echo "CI execution mode: $managed_execution_mode (repository-owned managed artifact entrypoint)"
echo "Run key: $run_key"

case "$requested_suite" in
  aggregate-managed-run)
    aggregate_managed_run
    exit $?
    ;;
  managed-command)
    [[ $# -ge 4 ]] || {
      echo "Usage: $0 managed-command <suite> <platform> <command...>" >&2
      exit 64
    }
    managed_suite="$2"
    managed_platform="$3"
    shift 3
    run_managed_job "$managed_suite" "$managed_platform" "$@"
    exit $?
    ;;
  quality|android|observability)
    run_requested_suite "$requested_suite"
    primary_exit_code=$?
    aggregate_managed_run
    aggregate_exit_code=$?
    [[ "$primary_exit_code" -eq 0 ]] || exit "$primary_exit_code"
    exit "$aggregate_exit_code"
    ;;
  ios)
    [[ "$host_platform" == "macos" ]] || {
      echo "iOS verification requires macOS." >&2
      exit 69
    }
    run_requested_suite ios
    primary_exit_code=$?
    aggregate_managed_run
    aggregate_exit_code=$?
    [[ "$primary_exit_code" -eq 0 ]] || exit "$primary_exit_code"
    exit "$aggregate_exit_code"
    ;;
  all)
    primary_exit_code=0
    run_requested_suite quality || primary_exit_code=$?
    if [[ "$primary_exit_code" -eq 0 ]]; then
      run_requested_suite android || primary_exit_code=$?
    fi
    if [[ "$primary_exit_code" -eq 0 && "$host_platform" == "macos" ]]; then
      run_requested_suite ios || primary_exit_code=$?
    elif [[ "$host_platform" != "macos" ]]; then
      echo "iOS suite skipped in all: current host is $host_platform."
    fi
    aggregate_managed_run
    aggregate_exit_code=$?
    [[ "$primary_exit_code" -eq 0 ]] || exit "$primary_exit_code"
    exit "$aggregate_exit_code"
    ;;
  *)
    echo "Usage: $0 {quality|android|ios|observability|all}" >&2
    exit 64
    ;;
esac
