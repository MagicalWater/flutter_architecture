import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/observability/release_build_metadata.dart';
import 'package:flutter_architecture/app/observability/release_identity.dart';
import 'package:flutter_architecture/app/observability/release_identity_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('Factory以reader提供的native package metadata建立identity', () async {
    final identity =
        await ReleaseIdentityFactory(
          const _FakeReleaseMetadataReader(
            ReleasePackageMetadata(version: '1.8.0', buildNumber: '9'),
          ),
        ).create(
          environment: AppEnvironment.development,
          platform: ReleasePlatform.android,
          nativeConfiguration: 'development',
          buildMetadata: const ReleaseBuildMetadata.absent(),
        );

    expect(identity.version, '1.8.0');
    expect(identity.buildNumber, '9');
    expect(identity.commitSha, isNull);
  });

  test('Factory保留reader failure且不偽造release metadata', () async {
    final error = StateError('metadata unavailable');
    final factory = ReleaseIdentityFactory(
      _ThrowingReleaseMetadataReader(error),
    );

    await expectLater(
      factory.create(
        environment: AppEnvironment.production,
        platform: ReleasePlatform.ios,
        nativeConfiguration: 'Production',
      ),
      throwsA(same(error)),
    );
  });

  test('PackageInfo reader使用安裝產物package metadata', () async {
    PackageInfo.setMockInitialValues(
      appName: 'Flutter Architecture',
      packageName: 'com.example.flutterarchitecture',
      version: '1.8.0',
      buildNumber: '27',
      buildSignature: '',
      installerStore: null,
    );

    final metadata = await const PackageInfoReleaseMetadataReader().read();

    expect(metadata.version, '1.8.0');
    expect(metadata.buildNumber, '27');
  });
}

final class _FakeReleaseMetadataReader implements ReleaseMetadataReader {
  const _FakeReleaseMetadataReader(this.metadata);

  final ReleasePackageMetadata metadata;

  @override
  Future<ReleasePackageMetadata> read() async => metadata;
}

final class _ThrowingReleaseMetadataReader implements ReleaseMetadataReader {
  const _ThrowingReleaseMetadataReader(this.error);

  final Object error;

  @override
  Future<ReleasePackageMetadata> read() async => throw error;
}
