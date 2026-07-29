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
            ):
                self.assertIn(field, script)
        self.assertIn("not production-ready", android)
        self.assertIn("sdk=$sdk", ios)
        self.assertIn("plutil -extract CFBundleIdentifier", ios)


if __name__ == "__main__":
    unittest.main()
