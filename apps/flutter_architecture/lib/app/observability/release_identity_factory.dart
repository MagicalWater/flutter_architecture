import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/observability/release_build_metadata.dart';
import 'package:flutter_architecture/app/observability/release_identity.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class ReleasePackageMetadata {
  const ReleasePackageMetadata({
    required this.version,
    required this.buildNumber,
  });

  final String version;
  final String buildNumber;
}

abstract interface class ReleaseMetadataReader {
  Future<ReleasePackageMetadata> read();
}

final class PackageInfoReleaseMetadataReader implements ReleaseMetadataReader {
  const PackageInfoReleaseMetadataReader();

  @override
  Future<ReleasePackageMetadata> read() async {
    final info = await PackageInfo.fromPlatform();
    return ReleasePackageMetadata(
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }
}

/// 組合 package metadata、native configuration 與 build metadata 成 canonical release identity。
final class ReleaseIdentityFactory {
  const ReleaseIdentityFactory(this._metadataReader);

  final ReleaseMetadataReader _metadataReader;

  Future<ReleaseIdentity> create({
    required AppEnvironment environment,
    required ReleasePlatform platform,
    required String nativeConfiguration,
    ReleaseBuildMetadata buildMetadata = const ReleaseBuildMetadata.absent(),
  }) async {
    final metadata = await _metadataReader.read();
    return ReleaseIdentity(
      environment: environment,
      version: metadata.version,
      buildNumber: metadata.buildNumber,
      platform: platform,
      nativeConfiguration: nativeConfiguration,
      commitSha: buildMetadata.commitSha,
    );
  }
}
