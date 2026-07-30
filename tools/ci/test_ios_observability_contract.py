from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class IosObservabilityContractTest(unittest.TestCase):
    def test_xcode_project_contains_config_and_crashlytics_phases(self) -> None:
        project = (
            ROOT
            / "apps/flutter_architecture/ios/Runner.xcodeproj/project.pbxproj"
        ).read_text()

        self.assertIn("Copy Firebase Config", project)
        self.assertIn("Upload Crashlytics Symbols", project)
        self.assertIn("GoogleService-Info.plist", project)
        self.assertIn("FirebaseCrashlytics/run", project)

    def test_release_configurations_generate_dsym(self) -> None:
        for environment in ("development", "staging", "production"):
            config = (
                ROOT
                / f"apps/flutter_architecture/ios/Flutter/Release-{environment}.xcconfig"
            ).read_text()
            self.assertIn("DEBUG_INFORMATION_FORMAT = dwarf-with-dsym", config)

    def test_config_projection_and_manual_upload_are_explicit(self) -> None:
        verifier = (ROOT / "tools/ci/verify_ios_firebase_config.py").read_text()
        uploader = (ROOT / "tools/ci/upload_ios_dsyms.sh").read_text()
        build = (ROOT / "tools/ci/build_ios_environment.sh").read_text()
        podfile = (ROOT / "apps/flutter_architecture/ios/Podfile").read_text()

        self.assertIn("BUNDLE_ID", verifier)
        self.assertIn("GOOGLE_APP_ID", verifier)
        self.assertIn("upload-symbols", uploader)
        self.assertIn("not executed", uploader)
        self.assertIn("Expected Runner dSYM was not generated", build)
        self.assertIn("expected_dsym_name", build)
        self.assertIn("GENERATE_DSYM_FOR_ACCEPTANCE", build)
        self.assertIn("xcrun dsymutil", build)
        self.assertIn("App.framework.dSYM", build)
        self.assertIn("Required binary UUID is missing from dSYM set", build)
        self.assertIn("require_complete_dsym_set", build)
        self.assertIn(
            '[[ "$configuration" == Release-* ]] || '
            '[[ "${GENERATE_DSYM_FOR_ACCEPTANCE:-false}" == "true" ]]',
            build,
        )
        self.assertIn("IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'", podfile)

    def test_dsym_acceptance_does_not_require_controlled_event(self) -> None:
        workflow = (
            ROOT / ".github/workflows/observability-acceptance.yml"
        ).read_text()
        ios_job = workflow.split("  ios-symbols:", 1)[1].split(
            "  observability-summary:", 1
        )[0]

        self.assertIn("Build iOS production dSYM", ios_job)
        self.assertIn("Upload iOS dSYM", ios_job)
        self.assertIn("inputs.emit_controlled_event == true", ios_job)
        self.assertNotIn(
            "if: inputs.emit_controlled_event == true",
            ios_job,
        )

        upload_block = ios_job.split(
            "      - name: Upload iOS observability full artifact",
            1,
        )[1].split("      - name: Clean iOS observability secrets", 1)[0]
        self.assertIn("runner.temp }}/observability/", upload_block)
        self.assertNotIn("ios-staging-acceptance", upload_block)
        self.assertNotIn("dSYMs", upload_block)


if __name__ == "__main__":
    unittest.main()
