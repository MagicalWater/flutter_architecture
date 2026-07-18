import 'package:design_system/src/theme/ds_theme_id.dart';

/// Theme selector 可使用的純 presentation metadata。
final class DsThemeMetadata {
  factory DsThemeMetadata({
    required DsThemeId id,
    required String displayName,
  }) {
    if (displayName.trim().isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'Theme display name 不可為空',
      );
    }

    return DsThemeMetadata._(id: id, displayName: displayName);
  }

  const DsThemeMetadata._({required this.id, required this.displayName});

  final DsThemeId id;
  final String displayName;
}
