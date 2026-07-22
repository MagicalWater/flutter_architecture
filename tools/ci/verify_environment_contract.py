#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
import json
from pathlib import Path
import re
import sys
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MANIFEST = (
    ROOT / "apps" / "flutter_architecture" / "config" / "environments.json"
)

EXPECTED_ENVIRONMENTS = ("development", "staging", "production")
REQUIRED_ROOT_FIELDS = (
    "schemaVersion",
    "templateBaseIdentifier",
    "androidFlavorDimension",
    "environments",
)
REQUIRED_ENVIRONMENT_FIELDS = (
    "name",
    "androidFlavor",
    "iosScheme",
    "dartEntrypoint",
    "displayName",
    "androidApplicationId",
    "iosBundleIdentifier",
)
UNIQUE_ENVIRONMENT_FIELDS = (
    "androidFlavor",
    "iosScheme",
    "dartEntrypoint",
    "androidApplicationId",
    "iosBundleIdentifier",
)
IDENTIFIER_PATTERN = re.compile(r"^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z0-9]+)+$")


@dataclass(frozen=True)
class ContractError:
    path: str
    message: str

    def __str__(self) -> str:
        return f"{self.path}: {self.message}"


def load_manifest(path: Path = DEFAULT_MANIFEST) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise RuntimeError(f"Environment contract not found: {path}") from error
    except json.JSONDecodeError as error:
        raise RuntimeError(
            f"Invalid JSON in environment contract {path}:{error.lineno}:{error.colno}: "
            f"{error.msg}"
        ) from error

    if not isinstance(value, dict):
        raise RuntimeError(f"Environment contract root must be an object: {path}")
    return value


def validate_contract(contract: dict[str, Any]) -> list[ContractError]:
    errors: list[ContractError] = []

    _require_exact_fields(contract, REQUIRED_ROOT_FIELDS, "$", errors)

    if contract.get("schemaVersion") != 1:
        errors.append(ContractError("$.schemaVersion", "must equal 1"))

    base_identifier = contract.get("templateBaseIdentifier")
    if not _is_non_empty_string(base_identifier):
        errors.append(
            ContractError("$.templateBaseIdentifier", "must be a non-empty string")
        )
    elif not IDENTIFIER_PATTERN.fullmatch(base_identifier):
        errors.append(
            ContractError(
                "$.templateBaseIdentifier",
                "must be a reverse-domain identifier",
            )
        )

    if contract.get("androidFlavorDimension") != "environment":
        errors.append(
            ContractError(
                "$.androidFlavorDimension",
                'must equal "environment"',
            )
        )

    environments = contract.get("environments")
    if not isinstance(environments, list):
        errors.append(ContractError("$.environments", "must be an array"))
        return errors

    if len(environments) != 3:
        errors.append(ContractError("$.environments", "must contain exactly 3 items"))

    names: list[Any] = []
    for index, environment in enumerate(environments):
        path = f"$.environments[{index}]"
        if not isinstance(environment, dict):
            errors.append(ContractError(path, "must be an object"))
            continue

        _require_exact_fields(environment, REQUIRED_ENVIRONMENT_FIELDS, path, errors)
        for field in REQUIRED_ENVIRONMENT_FIELDS:
            if not _is_non_empty_string(environment.get(field)):
                errors.append(
                    ContractError(f"{path}.{field}", "must be a non-empty string")
                )

        for field in ("androidApplicationId", "iosBundleIdentifier"):
            value = environment.get(field)
            if _is_non_empty_string(value) and not IDENTIFIER_PATTERN.fullmatch(value):
                errors.append(
                    ContractError(
                        f"{path}.{field}",
                        "must be a reverse-domain identifier",
                    )
                )

        entrypoint = environment.get("dartEntrypoint")
        if _is_non_empty_string(entrypoint):
            expected_entrypoint = f"lib/main_{environment.get('name')}.dart"
            if entrypoint != expected_entrypoint:
                errors.append(
                    ContractError(
                        f"{path}.dartEntrypoint",
                        f'must equal "{expected_entrypoint}"',
                    )
                )

        names.append(environment.get("name"))

    if names != list(EXPECTED_ENVIRONMENTS):
        errors.append(
            ContractError(
                "$.environments[*].name",
                "must be ordered as development, staging, production",
            )
        )

    for field in UNIQUE_ENVIRONMENT_FIELDS:
        values = [
            environment.get(field)
            for environment in environments
            if isinstance(environment, dict)
        ]
        if len(values) != len(set(values)):
            errors.append(
                ContractError(
                    f"$.environments[*].{field}",
                    "values must be unique",
                )
            )

    if len(environments) >= 3 and isinstance(environments[2], dict):
        production = environments[2]
        for field in ("androidApplicationId", "iosBundleIdentifier"):
            if production.get(field) != base_identifier:
                errors.append(
                    ContractError(
                        f"$.environments[2].{field}",
                        "production must use templateBaseIdentifier without a suffix",
                    )
                )

    if _is_non_empty_string(base_identifier):
        for index, name in enumerate(("development", "staging")):
            if len(environments) <= index or not isinstance(environments[index], dict):
                continue
            environment = environments[index]
            expected_identifier = f"{base_identifier}.{name}"
            for field in ("androidApplicationId", "iosBundleIdentifier"):
                if environment.get(field) != expected_identifier:
                    errors.append(
                        ContractError(
                            f"$.environments[{index}].{field}",
                            f'must use the approved environment suffix ".{name}"',
                        )
                    )

    return errors


def validate_dart_projection(
    repository_root: Path,
    contract: dict[str, Any],
) -> list[ContractError]:
    errors: list[ContractError] = []
    app_root = repository_root / "apps" / "flutter_architecture"
    environments = contract.get("environments")
    if not isinstance(environments, list):
        return [ContractError("$.environments", "must be an array")]

    for index, environment in enumerate(environments):
        if not isinstance(environment, dict):
            continue
        name = environment.get("name")
        entrypoint = environment.get("dartEntrypoint")
        if not _is_non_empty_string(name) or not _is_non_empty_string(entrypoint):
            continue

        entrypoint_path = app_root / entrypoint
        path = f"$.environments[{index}].dartEntrypoint"
        if not entrypoint_path.is_file():
            errors.append(ContractError(path, f"file does not exist: {entrypoint}"))
            continue

        entrypoint_text = entrypoint_path.read_text(encoding="utf-8")
        expected_bootstrap = f"bootstrap(AppEnvironment.{name})"
        if expected_bootstrap not in entrypoint_text:
            errors.append(
                ContractError(
                    path,
                    f"must bootstrap AppEnvironment.{name}",
                )
            )

    compatibility_entrypoint = app_root / "lib" / "main.dart"
    if not compatibility_entrypoint.is_file():
        errors.append(ContractError("$.dartCompatibilityEntrypoint", "lib/main.dart missing"))
    elif "bootstrap(AppEnvironment.development)" not in compatibility_entrypoint.read_text(
        encoding="utf-8"
    ):
        errors.append(
            ContractError(
                "$.dartCompatibilityEntrypoint",
                "lib/main.dart must remain the development compatibility entrypoint",
            )
        )

    enum_path = app_root / "lib" / "app" / "config" / "app_environment.dart"
    if not enum_path.is_file():
        errors.append(ContractError("$.dartEnvironmentEnum", "AppEnvironment file missing"))
    else:
        enum_text = enum_path.read_text(encoding="utf-8")
        for name in EXPECTED_ENVIRONMENTS:
            if not re.search(rf"^\s*{re.escape(name)},?\s*$", enum_text, re.MULTILINE):
                errors.append(
                    ContractError(
                        "$.dartEnvironmentEnum",
                        f"AppEnvironment.{name} is missing",
                    )
                )

    return errors


def validate_android_projection(
    repository_root: Path,
    contract: dict[str, Any],
) -> list[ContractError]:
    errors: list[ContractError] = []
    app_root = repository_root / "apps" / "flutter_architecture"
    gradle_path = app_root / "android" / "app" / "build.gradle.kts"
    manifest_path = app_root / "android" / "app" / "src" / "main" / "AndroidManifest.xml"

    if not gradle_path.is_file():
        return [ContractError("$.android.gradle", "android/app/build.gradle.kts missing")]
    if not manifest_path.is_file():
        return [ContractError("$.android.manifest", "AndroidManifest.xml missing")]

    gradle_text = gradle_path.read_text(encoding="utf-8")
    manifest_text = manifest_path.read_text(encoding="utf-8")

    required_gradle_fragments = (
        'flavorDimensions += "environment"',
        'manifestPlaceholders["appDisplayName"]',
        'manifestPlaceholders["nativeEnvironment"]',
        'buildConfigField(',
        '"NATIVE_ENVIRONMENT"',
        "tasks.withType<FlutterTask>().configureEach",
        'project.findProperty("target")',
        'targetPath = environment.dartEntrypoint',
        '"NATIVE_ENVIRONMENT=${environment.name}"',
    )
    for fragment in required_gradle_fragments:
        if fragment not in gradle_text:
            errors.append(
                ContractError(
                    "$.android.gradle",
                    f"required contract fragment missing: {fragment}",
                )
            )

    required_manifest_fragments = (
        'android:label="${appDisplayName}"',
        'android:name="flutter.native_environment"',
        'android:value="${nativeEnvironment}"',
    )
    for fragment in required_manifest_fragments:
        if fragment not in manifest_text:
            errors.append(
                ContractError(
                    "$.android.manifest",
                    f"required contract fragment missing: {fragment}",
                )
            )

    environments = contract.get("environments")
    if not isinstance(environments, list):
        return errors

    for index, environment in enumerate(environments):
        if not isinstance(environment, dict):
            continue
        expected_fragments = (
            f'name = "{environment.get("androidFlavor")}"',
            f'applicationId = "{environment.get("androidApplicationId")}"',
            f'displayName = "{environment.get("displayName")}"',
            f'dartEntrypoint = "{environment.get("dartEntrypoint")}"',
        )
        for fragment in expected_fragments:
            if fragment not in gradle_text:
                errors.append(
                    ContractError(
                        f"$.environments[{index}].androidProjection",
                        f"Gradle projection missing: {fragment}",
                    )
                )

    return errors


def _require_exact_fields(
    value: dict[str, Any],
    expected_fields: tuple[str, ...],
    path: str,
    errors: list[ContractError],
) -> None:
    expected = set(expected_fields)
    actual = set(value)
    for field in sorted(expected - actual):
        errors.append(ContractError(f"{path}.{field}", "required field is missing"))
    for field in sorted(actual - expected):
        errors.append(ContractError(f"{path}.{field}", "unexpected field"))


def _is_non_empty_string(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def main() -> int:
    try:
        contract = load_manifest()
    except RuntimeError as error:
        print(error, file=sys.stderr)
        return 1

    errors = [
        *validate_contract(contract),
        *validate_dart_projection(ROOT, contract),
        *validate_android_projection(ROOT, contract),
    ]
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print("Environment mapping contract verified.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
