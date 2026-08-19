import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/theme/app_theme_visuals.dart';
import 'package:flutter_architecture/app/theme/presentation/theme_localization.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

final class AppearanceSelectorDialog extends StatelessWidget {
  const AppearanceSelectorDialog({required this.controller, super.key});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final visuals = resolveAppThemeVisuals(
          registry: controller.registry,
          themeId: ThemeControllerScope.themeIdOf(context),
          brightness: Theme.of(context).brightness,
        );

        return AlertDialog(
          title: Text(l10n.appearanceDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: SizedBox.square(
                    dimension: 48,
                    child: visuals.referenceVisual.image(fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.appearanceThemeSectionLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                for (final metadata in controller.registry.availableThemes)
                  ListTile(
                    selected: metadata.id == controller.preference.themeId,
                    leading: Icon(
                      metadata.id == controller.preference.themeId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(localizedThemeName(l10n, metadata)),
                    onTap: () => controller.selectTheme(metadata.id),
                  ),
                const Divider(),
                Text(
                  l10n.appearanceModeSectionLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                for (final mode in AppThemeMode.values)
                  ListTile(
                    selected: mode == controller.preference.mode,
                    leading: Icon(
                      mode == controller.preference.mode
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(switch (mode) {
                      AppThemeMode.system => l10n.appearanceModeSystemLabel,
                      AppThemeMode.light => l10n.appearanceModeLightLabel,
                      AppThemeMode.dark => l10n.appearanceModeDarkLabel,
                    }),
                    onTap: () => controller.selectMode(mode),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonDoneAction),
            ),
          ],
        );
      },
    );
  }
}
