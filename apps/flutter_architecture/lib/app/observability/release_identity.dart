import 'package:flutter_architecture/app/config/app_environment.dart';

/// 這筆 release／crash 診斷資料來自哪一類平台。
enum ReleasePlatform {
  /// Android App。
  android,

  /// iOS App。
  ios,

  /// 目前未列入正式 Android／iOS release contract 的其他平台。
  other,
}

/// 一筆可送到 observability provider 的 App 版本識別資訊。
///
/// 用來把 crash／error 對應到 environment、版本、build number、原生 configuration
/// 與 commit；不包含 token、使用者資料或其他 runtime state。
final class ReleaseIdentity {
  ReleaseIdentity({
    required this.environment,
    required String version,
    required String buildNumber,
    required this.platform,
    required String nativeConfiguration,
    String? commitSha,
  }) : version = _requireValue(version, 'version'),
       buildNumber = _requireValue(buildNumber, 'buildNumber'),
       nativeConfiguration = _requireValue(
         nativeConfiguration,
         'nativeConfiguration',
       ),
       commitSha = _optionalValue(commitSha, 'commitSha');

  final AppEnvironment environment;
  final String version;
  final String buildNumber;
  final ReleasePlatform platform;
  final String nativeConfiguration;
  final String? commitSha;

  static String _requireValue(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, name, '不可為空白');
    }
    return normalized;
  }

  static String? _optionalValue(String? value, String name) {
    if (value == null) return null;
    return _requireValue(value, name);
  }

  @override
  String toString() {
    return 'ReleaseIdentity('
        'environment: ${environment.name}, '
        'version: $version, '
        'buildNumber: $buildNumber, '
        'platform: ${platform.name}, '
        'nativeConfiguration: $nativeConfiguration, '
        'hasCommitSha: ${commitSha != null})';
  }
}
