from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class AndroidObservabilityContractTest(unittest.TestCase):
    def test_gradle_plugins_are_available_but_config_gated(self) -> None:
        settings = (ROOT / "apps/flutter_architecture/android/settings.gradle.kts").read_text()
        app_gradle = (ROOT / "apps/flutter_architecture/android/app/build.gradle.kts").read_text()

        self.assertIn('id("com.google.gms.google-services") version "4.5.0" apply false', settings)
        self.assertIn('id("com.google.firebase.crashlytics") version "3.0.7" apply false', settings)
        self.assertIn('pluginManager.apply("com.google.gms.google-services")', app_gradle)
        self.assertIn('pluginManager.apply("com.google.firebase.crashlytics")', app_gradle)
        self.assertIn("google-services.json", app_gradle)

    def test_production_build_generates_flutter_symbols(self) -> None:
        script = (ROOT / "tools/ci/build_android_environment.sh").read_text()

        self.assertIn('--obfuscate', script)
        self.assertIn('--split-debug-info=', script)
        self.assertIn('flutter_symbols_dir=', script)
        self.assertIn('mapping.txt', script)

    def test_symbol_upload_is_explicit_and_optional(self) -> None:
        upload = (ROOT / "tools/ci/upload_android_flutter_symbols.sh").read_text()

        self.assertIn('firebase crashlytics:symbols:upload', upload)
        self.assertIn('FIREBASE_ANDROID_APP_ID', upload)
        self.assertIn('not executed', upload)

    def test_firebase_config_projection_is_validated(self) -> None:
        verifier = (ROOT / "tools/ci/verify_android_firebase_config.py").read_text()
        build = (ROOT / "tools/ci/build_android_environment.sh").read_text()

        self.assertIn('package_name', verifier)
        self.assertIn('mobilesdk_app_id', verifier)
        self.assertIn('verify_android_firebase_config.py', build)
        self.assertIn('Expected Flutter symbols were not generated', build)


if __name__ == "__main__":
    unittest.main()
