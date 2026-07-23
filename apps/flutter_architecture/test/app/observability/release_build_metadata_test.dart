import 'package:flutter_architecture/app/observability/release_build_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('未提供commit SHA時保持absent', () {
    expect(ReleaseBuildMetadata.fromValue('').commitSha, isNull);
    expect(ReleaseBuildMetadata.fromValue('  ').commitSha, isNull);
  });

  test('受控build-time commit SHA會trim後保留', () {
    expect(ReleaseBuildMetadata.fromValue(' abc123 ').commitSha, 'abc123');
  });
}
