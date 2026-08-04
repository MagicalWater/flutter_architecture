from __future__ import annotations

import hashlib
import tempfile
import unittest
from pathlib import Path

from tools.visual.verify_visual_authority import verify_visual_authority


class VisualAuthorityVerifierTest(unittest.TestCase):
    def test_valid_manifest_passes(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)

            self.assertEqual(verify_visual_authority(root, manifest), ())

    def test_missing_authority_fails(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            (root / "docs/design_sources/example/source.pen").unlink()

            self.assertIn("visual-authority-missing-authority", _codes(root, manifest))

    def test_authority_hash_drift_fails(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            _write_bytes(root, "docs/design_sources/example/source.pen", b"drift")

            self.assertIn("visual-authority-hash-drift", _codes(root, manifest))

    def test_path_escape_fails(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            text = manifest.read_text(encoding="utf-8")
            manifest.write_text(
                text.replace(
                    "../../design_sources/example/original-reference.png",
                    "../../../../outside.png",
                ),
                encoding="utf-8",
                newline="",
            )

            self.assertIn("visual-authority-path-escape", _codes(root, manifest))

    def test_missing_derived_file_fails(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            (root / "docs/design_sources/example/pencil-preview.png").unlink()

            self.assertIn("visual-authority-missing-file", _codes(root, manifest))

    def test_duplicate_role_fails(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            text = manifest.read_text(encoding="utf-8")
            manifest.write_text(
                text.replace(
                    "| supplementary-reference |",
                    "| derived-preview |",
                ),
                encoding="utf-8",
                newline="",
            )

            self.assertIn("visual-authority-duplicate-role", _codes(root, manifest))

    def test_different_roles_cannot_share_the_same_file(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            source_hash = hashlib.sha256(
                (root / "docs/design_sources/example/source.pen").read_bytes()
            ).hexdigest()
            text = manifest.read_text(encoding="utf-8")
            benchmark_hash = hashlib.sha256(
                (root / "docs/design_sources/example/historical-flutter-benchmark.png").read_bytes()
            ).hexdigest()
            manifest.write_text(
                text.replace(
                    "../../design_sources/example/historical-flutter-benchmark.png",
                    "../../design_sources/example/source.pen",
                ).replace(benchmark_hash, source_hash),
                encoding="utf-8",
                newline="",
            )

            self.assertIn("visual-authority-duplicate-file", _codes(root, manifest))

    def test_invalid_viewport_fails(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            text = manifest.read_text(encoding="utf-8")
            manifest.write_text(
                text.replace("canonical_width: 941", "canonical_width: 0"),
                encoding="utf-8",
                newline="",
            )

            self.assertIn("visual-authority-invalid-viewport", _codes(root, manifest))

    def test_benchmark_marked_primary_fails(self) -> None:
        with _fixture() as root:
            manifest = _write_valid_manifest(root)
            text = manifest.read_text(encoding="utf-8")
            manifest.write_text(
                text.replace(" | benchmark |\n", " | primary |\n"),
                encoding="utf-8",
                newline="",
            )

            self.assertIn("visual-authority-invalid-primary", _codes(root, manifest))


def _codes(root: Path, manifest: Path) -> list[str]:
    return [issue.code for issue in verify_visual_authority(root, manifest)]


class _fixture:
    def __enter__(self) -> Path:
        self._temp = tempfile.TemporaryDirectory()
        return Path(self._temp.name)

    def __exit__(self, exc_type: object, exc: object, traceback: object) -> None:
        self._temp.cleanup()


def _write_valid_manifest(root: Path) -> Path:
    files = {
        "source.pen": b"pen source\n",
        "pencil-preview.png": b"preview png",
        "original-reference.png": b"reference png",
        "historical-flutter-benchmark.png": b"benchmark png",
    }
    for name, content in files.items():
        _write_bytes(root, f"docs/design_sources/example/{name}", content)

    hashes = {name: hashlib.sha256(content).hexdigest() for name, content in files.items()}
    manifest = root / "docs/visual_authority/example/manifest.md"
    manifest.parent.mkdir(parents=True, exist_ok=True)
    manifest.write_text(
        "---\n"
        "document_type: runtime-evidence\n"
        "status: accepted\n"
        "authoritative_for:\n"
        "  - example-visual-authority\n"
        "last_reviewed_baseline: 1.14.0\n"
        "initiative: example\n"
        "authority_file: ../../design_sources/example/source.pen\n"
        f"authority_sha256: {hashes['source.pen']}\n"
        "canonical_width: 941\n"
        "canonical_height: 1672\n"
        "canonical_dpr: 1.0\n"
        "---\n\n"
        "# Example Visual Authority\n\n"
        "| Role | Path | SHA-256 | Authority status |\n"
        "|---|---|---|---|\n"
        f"| primary-source | ../../design_sources/example/source.pen | {hashes['source.pen']} | primary |\n"
        f"| derived-preview | ../../design_sources/example/pencil-preview.png | {hashes['pencil-preview.png']} | derived |\n"
        f"| supplementary-reference | ../../design_sources/example/original-reference.png | {hashes['original-reference.png']} | supplementary |\n"
        f"| historical-benchmark | ../../design_sources/example/historical-flutter-benchmark.png | {hashes['historical-flutter-benchmark.png']} | benchmark |\n",
        encoding="utf-8",
        newline="",
    )
    return manifest


def _write_bytes(root: Path, relative_path: str, content: bytes) -> None:
    path = root / relative_path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(content)


if __name__ == "__main__":
    unittest.main()
