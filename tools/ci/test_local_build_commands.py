from pathlib import Path
import os
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[2]


class LocalBuildCommandsTest(unittest.TestCase):
    def test_four_explicit_environment_wrappers_exist(self) -> None:
        for name in (
            "build_android_development.sh",
            "build_android_production.sh",
            "build_ios_development.sh",
            "build_ios_production.sh",
        ):
            self.assertTrue((ROOT / "tools" / "ci" / name).is_file(), name)

    def test_local_ci_switch_entrypoint_exists(self) -> None:
        entrypoint = ROOT / "tools/ci/run_local_ci.sh"
        self.assertTrue(entrypoint.is_file())
        if os.name == "nt":
            result = subprocess.run(
                [
                    "git",
                    "ls-files",
                    "-s",
                    "--",
                    entrypoint.relative_to(ROOT).as_posix(),
                ],
                cwd=ROOT,
                check=True,
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.stdout.split()[0], "100755")
        else:
            self.assertTrue(entrypoint.stat().st_mode & 0o111)

    def test_ios_production_uses_unsigned_device_release_not_simulator_aot(self) -> None:
        wrapper = (ROOT / "tools" / "ci" / "build_ios_production.sh").read_text(
            encoding="utf-8"
        )

        self.assertIn("Production", wrapper)
        self.assertIn("Release-production", wrapper)
        self.assertIn("iphoneos", wrapper)
        self.assertIn("lib/main_production.dart", wrapper)
        self.assertFalse(
            (ROOT / "tools" / "ci" / "build_ios_production_simulator.sh").exists()
        )

    def test_android_wrappers_use_explicit_flavor_and_entrypoint(self) -> None:
        development = (ROOT / "tools/ci/build_android_development.sh").read_text()
        production = (ROOT / "tools/ci/build_android_production.sh").read_text()
        self.assertIn('development debug lib/main_development.dart mock', development)
        self.assertIn('production release lib/main_production.dart real', production)
        self.assertNotIn("lib/main.dart", production)

    def test_ios_wrappers_use_explicit_scheme_configuration_and_entrypoint(self) -> None:
        development = (ROOT / "tools/ci/build_ios_development.sh").read_text()
        production = (ROOT / "tools/ci/build_ios_production.sh").read_text()
        self.assertIn('Development Debug-development iphonesimulator', development)
        self.assertIn('Production Release-production iphoneos', production)
        self.assertNotIn("lib/main.dart", production)

    def test_metadata_contract_records_environment_and_distribution(self) -> None:
        android = (ROOT / "tools/ci/build_android_environment.sh").read_text()
        ios = (ROOT / "tools/ci/build_ios_environment.sh").read_text()
        for script in (android, ios):
            for field in (
                "commit_sha=",
                "environment=",
                "entrypoint=",
                "api_mode=",
                "signing=",
                "distribution=",
                "artifact=",
                "observability_remote_collection=",
                "observability_acceptance_event=",
            ):
                self.assertIn(field, script)
        self.assertIn("not production-ready", android)
        self.assertIn("sdk=$sdk", ios)
        self.assertIn("plutil -extract CFBundleIdentifier", ios)

    def test_local_ci_uses_managed_job_lifecycle(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")

        for token in (
            "run_managed_job",
            "tools/ci/artifact_store.py begin-job",
            "tools/ci/artifact_store.py finalize-job",
            "tools/ci/artifact_store.py aggregate-run",
            "tools/ci/artifact_cleanup.py evaluate",
            "CI_ARTIFACT_ROOT",
            "CI_RUN_KEY",
            "CI_JOB_KEY",
            "CI_RETENTION_CLASS",
        ):
            self.assertIn(token, script)
        self.assertIn("primary_exit_code", script)
        self.assertIn("finalize_exit_code", script)
        self.assertIn('return "$primary_exit_code"', script)
        self.assertNotIn("$repo_root/artifacts", script)

    def test_local_ci_uses_external_root_resolution_and_unique_manual_run_key(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")

        self.assertIn("resolve_artifact_root", script)
        self.assertIn("home=Path.home()", script)
        self.assertIn("runner_work=runner_work", script)
        self.assertIn("runner_temp=runner_temp", script)
        self.assertIn("manual-local", script)
        self.assertIn("local-", script)
        self.assertIn("secrets.token_hex", script)
        self.assertNotIn(".tmp-artifact-smoke", script)

    def test_managed_metadata_separates_host_from_target_platform(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")

        self.assertIn("artifact_platform", script)
        self.assertIn("METADATA_PLATFORM", script)
        self.assertIn('android) target_platform=android', script)
        self.assertIn('ios) target_platform=ios', script)
        self.assertIn('observability) target_platform=multiple', script)
        self.assertIn('"platform": os.environ["METADATA_PLATFORM"]', script)

    def test_primary_failure_precedes_evidence_preparation_failure(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")

        self.assertIn("evidence_prepare_exit_code", script)
        primary_gate = script.index('if [[ "$primary_exit_code" -ne 0 ]]')
        evidence_gate = script.index('if [[ "$evidence_prepare_exit_code" -ne 0 ]]')
        self.assertLess(primary_gate, evidence_gate)

    def test_local_entrypoint_exposes_exact_managed_command_wrapper(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")

        self.assertIn("managed-command)", script)
        self.assertIn("run_managed_job", script)
        self.assertIn("GITHUB_STEP_SUMMARY", script)
        self.assertIn("write-summary", script)
        self.assertIn("CI_ARTIFACT_ENVIRONMENT", script)
        self.assertIn("CI_ARTIFACT_BUILD_MODE", script)

    def test_self_hosted_managed_root_is_explicit_and_fail_closed(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")

        self.assertIn("CI_MANAGED_EXECUTION_MODE", script)
        self.assertIn('managed_execution_mode="${CI_MANAGED_EXECUTION_MODE:-manual-local}"', script)
        self.assertIn("CI_MANAGED_EXECUTION_MODE_INPUT", script)
        self.assertIn("resolve_artifact_root", script)
        self.assertIn("managed_execution_mode", script)

    def test_job_finalize_and_run_aggregation_are_separate_commands(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")
        managed_job = script.split("run_managed_job() {", 1)[1].split(
            "aggregate_managed_run() {", 1
        )[0]

        self.assertNotIn("aggregate-run", managed_job)
        self.assertNotIn("artifact_cleanup.py evaluate", managed_job)
        self.assertIn("aggregate-managed-run)", script)
        self.assertIn("aggregate_managed_run", script)

    def test_platform_builds_require_explicit_external_artifact_dir(self) -> None:
        for relative_path in (
            "tools/ci/build_android_environment.sh",
            "tools/ci/build_ios_environment.sh",
        ):
            script = (ROOT / relative_path).read_text(encoding="utf-8")
            self.assertIn("ARTIFACT_DIR is required", script, relative_path)
            self.assertNotRegex(
                script,
                r"ARTIFACT_DIR:-\$repo_root/artifacts",
                relative_path,
            )
            self.assertIn("run_key=$run_key", script, relative_path)
            self.assertIn("job_key=$job_key", script, relative_path)

    def test_platform_build_cleanup_is_bounded_to_passed_staging_dir(self) -> None:
        android = (ROOT / "tools/ci/build_android_environment.sh").read_text(
            encoding="utf-8"
        )
        ios = (ROOT / "tools/ci/build_ios_environment.sh").read_text(
            encoding="utf-8"
        )

        self.assertIn('rm -rf "$flutter_symbols_dir"', android)
        self.assertIn('rm -f "$artifact_dir"/*.apk', android)
        self.assertNotIn('rm -rf "$artifact_dir"', android)
        self.assertIn('rm -rf "$artifact_dir"/*.app', ios)
        self.assertIn('build_workspace="$artifact_dir/.build"', ios)
        self.assertIn('derived_data_dir="$build_workspace/DerivedData"', ios)
        self.assertIn('cleanup_ios_build_workspace', ios)
        self.assertIn('trap cleanup_ios_build_workspace EXIT', ios)
        self.assertIn('[[ "$build_workspace" == "$artifact_dir/.build" ]]', ios)
        self.assertNotIn('"$artifact_dir/DerivedData"', ios)
        self.assertNotIn('rm -rf "$repo_root/artifacts"', android)
        self.assertNotIn('rm -rf "$repo_root/artifacts"', ios)

    def test_android_release_symbols_use_invocation_specific_staging_before_promotion(self) -> None:
        android = (ROOT / "tools/ci/build_android_environment.sh").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            'flutter_symbols_staging_dir="$artifact_dir/.flutter-symbols-build-$$"',
            android,
        )
        self.assertIn('"--split-debug-info=$flutter_symbols_staging_dir"', android)
        self.assertIn(
            'mv "$flutter_symbols_staging_dir" "$flutter_symbols_dir"',
            android,
        )
        self.assertNotIn('"--split-debug-info=$flutter_symbols_dir"', android)

    def test_local_observability_controlled_event_defaults_off(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")
        observability = script.split("execute_observability() {", 1)[1].split(
            "execute_suite() {", 1
        )[0]

        self.assertIn(
            'observability_acceptance_event_enabled="${OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED:-false}"',
            observability,
        )
        self.assertIn(
            'OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED="$observability_acceptance_event_enabled"',
            observability,
        )
        self.assertNotIn("OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true", observability)


if __name__ == "__main__":
    unittest.main()
