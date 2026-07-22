from pathlib import Path
import unittest

from tools.ci.verify_environment_contract import (
    ContractError,
    load_manifest,
    validate_android_projection,
    validate_contract,
    validate_dart_projection,
    validate_ios_projection,
)


ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "apps" / "flutter_architecture" / "config" / "environments.json"


class EnvironmentContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self.contract = load_manifest(MANIFEST)

    def test_declares_exactly_three_named_environments(self) -> None:
        self.assertEqual(
            [environment["name"] for environment in self.contract["environments"]],
            ["development", "staging", "production"],
        )

    def test_mapping_values_are_unique_and_entrypoints_are_explicit(self) -> None:
        environments = self.contract["environments"]

        for key in (
            "androidFlavor",
            "iosScheme",
            "dartEntrypoint",
            "androidApplicationId",
            "iosBundleIdentifier",
        ):
            values = [environment[key] for environment in environments]
            self.assertEqual(len(values), len(set(values)), key)

        self.assertEqual(
            [environment["dartEntrypoint"] for environment in environments],
            [
                "lib/main_development.dart",
                "lib/main_staging.dart",
                "lib/main_production.dart",
            ],
        )

    def test_production_uses_base_identity_without_environment_suffix(self) -> None:
        production = self.contract["environments"][2]
        self.assertEqual(
            production["androidApplicationId"],
            self.contract["templateBaseIdentifier"],
        )
        self.assertEqual(
            production["iosBundleIdentifier"],
            self.contract["templateBaseIdentifier"],
        )
        self.assertEqual(production["displayName"], "Flutter Architecture")

    def test_manifest_has_no_signing_or_secret_fields(self) -> None:
        forbidden_fragments = ("sign", "secret", "team", "certificate", "provision")

        def assert_safe(value: object, path: str = "$") -> None:
            if isinstance(value, dict):
                for key, nested in value.items():
                    lowered = key.lower()
                    self.assertFalse(
                        any(fragment in lowered for fragment in forbidden_fragments),
                        f"forbidden field at {path}.{key}",
                    )
                    assert_safe(nested, f"{path}.{key}")
            elif isinstance(value, list):
                for index, nested in enumerate(value):
                    assert_safe(nested, f"{path}[{index}]")

        assert_safe(self.contract)

    def test_contract_and_dart_projection_validate(self) -> None:
        self.assertEqual(validate_contract(self.contract), [])
        self.assertEqual(validate_dart_projection(ROOT, self.contract), [])

    def test_android_projection_validates(self) -> None:
        self.assertEqual(validate_android_projection(ROOT, self.contract), [])

    def test_ios_projection_validates(self) -> None:
        self.assertEqual(validate_ios_projection(ROOT, self.contract), [])

    def test_errors_include_the_failing_path(self) -> None:
        invalid = {
            **self.contract,
            "environments": [
                {**self.contract["environments"][0], "iosScheme": ""},
                *self.contract["environments"][1:],
            ],
        }

        errors = validate_contract(invalid)

        self.assertTrue(errors)
        self.assertIsInstance(errors[0], ContractError)
        self.assertIn("$.environments[0].iosScheme", str(errors[0]))

    def test_non_production_identifiers_require_the_approved_suffix(self) -> None:
        invalid = {
            **self.contract,
            "environments": [
                {
                    **self.contract["environments"][0],
                    "androidApplicationId": "com.example.flutterarchitecture.dev",
                },
                *self.contract["environments"][1:],
            ],
        }

        errors = validate_contract(invalid)

        self.assertTrue(
            any(
                error.path == "$.environments[0].androidApplicationId"
                and "approved environment suffix" in error.message
                for error in errors
            )
        )


if __name__ == "__main__":
    unittest.main()
