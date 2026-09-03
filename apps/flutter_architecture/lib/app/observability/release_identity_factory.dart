import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/observability/release_build_metadata.dart';
import 'package:flutter_architecture/app/observability/release_identity.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 從 platform package metadata 讀出的 App version 與 build number。
final class ReleasePackageMetadata {
  const ReleasePackageMetadata({
    required this.version,
    required this.buildNumber,
  });

  final String version;
  final String buildNumber;
}

/// 讀取目前安裝 App 的 version／build number；抽成介面方便測試時替換。
abstract interface class ReleaseMetadataReader {
  Future<ReleasePackageMetadata> read();
}

/// 使用 `package_info_plus` 讀取實際 App metadata。
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

/// 把 App version、build number、environment、platform、native configuration 與 commit SHA
/// 組合成一份 [ReleaseIdentity]，讓 crash／error 可以精確對應到實際 build。
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
