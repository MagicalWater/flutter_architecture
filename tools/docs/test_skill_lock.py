from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from tools.docs.check_docs import check_repository
from tools.docs.skill_lock import inspect_skill_lock


class SkillLockTest(unittest.TestCase):
    def test_locked_unmodified_english_skill_is_exempt(self) -> None:
        with _fixture() as root:
            _write_valid_skill_lock(root)

            codes = _codes(root)

            self.assertNotIn("agent-skill-language", codes)
            self.assertEqual(inspect_skill_lock(root).issues, ())

    def test_hash_drift_fails(self) -> None:
        with _fixture() as root:
            _write_valid_skill_lock(root)
            _write(root, ".agents/skills/example/SKILL.md", _english_skill() + "drift\n")

            self.assertIn("skill-lock-hash-drift", _inspection_codes(root))

    def test_install_path_escape_fails(self) -> None:
        with _fixture() as root:
            _write_license(root)
            lock = _valid_lock(root)
            lock["skills"]["example"]["installPath"] = "../outside"
            _write_lock(root, lock)

            self.assertIn("skill-lock-install-path-escape", _inspection_codes(root))

    def test_non_immutable_commit_fails(self) -> None:
        with _fixture() as root:
            _write_valid_skill_lock(root)
            lock = json.loads((root / "skills-lock.json").read_text(encoding="utf-8"))
            lock["skills"]["example"]["source"]["commit"] = "main"
            _write_lock(root, lock)

            self.assertIn("skill-lock-invalid-commit", _inspection_codes(root))

    def test_modified_third_party_cannot_masquerade_as_unmodified(self) -> None:
        with _fixture() as root:
            _write_valid_skill_lock(root, ownership="repository-maintained-fork")

            inspection = inspect_skill_lock(root)

            self.assertEqual(inspection.exempt_markdown_paths, frozenset())
            self.assertIn("agent-skill-language", _codes(root))

    def test_invalid_json_fails_closed(self) -> None:
        with _fixture() as root:
            _write(root, "skills-lock.json", "{not json\n")

            self.assertIn("skill-lock-invalid-json", _inspection_codes(root))


def _codes(root: Path) -> list[str]:
    return [issue.code for issue in check_repository(root)]


def _inspection_codes(root: Path) -> list[str]:
    return [issue.code for issue in inspect_skill_lock(root).issues]


class _fixture:
    def __enter__(self) -> Path:
        self._temp = tempfile.TemporaryDirectory()
        return Path(self._temp.name)

    def __exit__(self, exc_type: object, exc: object, traceback: object) -> None:
        self._temp.cleanup()


def _write(root: Path, relative_path: str, content: str) -> None:
    path = root / relative_path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="")


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _english_skill() -> str:
    return (
        "---\n"
        "name: example\n"
        "description: Use when validating an external skill.\n"
        "---\n\n"
        "# Example Skill\n\n"
        "English-only upstream content.\n"
    )


def _write_license(root: Path) -> None:
    _write(root, "third_party/skills/example/LICENSE", "Example license bytes.\n")


def _valid_lock(root: Path, *, ownership: str = "third-party-unmodified") -> dict[str, object]:
    skill_path = root / ".agents" / "skills" / "example" / "SKILL.md"
    license_path = root / "third_party" / "skills" / "example" / "LICENSE"
    skill_hash = _sha256(skill_path) if skill_path.exists() else hashlib.sha256(_english_skill().encode()).hexdigest()
    license_hash = (
        _sha256(license_path)
        if license_path.exists()
        else hashlib.sha256(b"Example license bytes.\n").hexdigest()
    )
    return {
        "version": 1,
        "skills": {
            "example": {
                "ownership": ownership,
                "status": "Pilot",
                "source": {
                    "repository": "https://github.com/example/source.git",
                    "commit": "0123456789abcdef0123456789abcdef01234567",
                    "path": "skills/example",
                },
                "license": {
                    "identity": "Example License",
                    "sourcePath": "LICENSE",
                    "localPath": "third_party/skills/example/LICENSE",
                    "sha256": license_hash,
                },
                "installPath": ".agents/skills/example",
                "files": [
                    {
                        "path": "SKILL.md",
                        "sha256": skill_hash,
                    }
                ],
            }
        },
    }


def _write_lock(root: Path, lock: dict[str, object]) -> None:
    _write(root, "skills-lock.json", json.dumps(lock, indent=2) + "\n")


def _write_valid_skill_lock(
    root: Path,
    *,
    ownership: str = "third-party-unmodified",
) -> None:
    _write(root, ".agents/skills/example/SKILL.md", _english_skill())
    _write_license(root)
    _write_lock(root, _valid_lock(root, ownership=ownership))


if __name__ == "__main__":
    unittest.main()
