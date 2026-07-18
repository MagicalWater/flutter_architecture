import 'package:design_system/design_system.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

String localizedThemeName(AppLocalizations l10n, DsThemeMetadata metadata) {
  return switch (metadata.id.value) {
    'default' => l10n.themeDefaultName,
    'ocean' => l10n.themeOceanName,
    _ => metadata.displayName,
  };
}
