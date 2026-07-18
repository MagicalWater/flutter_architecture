import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';

final class AppearanceSelectorDialog extends StatelessWidget {
  const AppearanceSelectorDialog({required this.controller, super.key});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => AlertDialog(
        title: const Text('Appearance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Theme', style: Theme.of(context).textTheme.titleSmall),
              for (final metadata in controller.registry.availableThemes)
                ListTile(
                  selected: metadata.id == controller.preference.themeId,
                  leading: Icon(
                    metadata.id == controller.preference.themeId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(metadata.displayName),
                  onTap: () => controller.selectTheme(metadata.id),
                ),
              const Divider(),
              Text('Mode', style: Theme.of(context).textTheme.titleSmall),
              for (final mode in AppThemeMode.values)
                ListTile(
                  selected: mode == controller.preference.mode,
                  leading: Icon(
                    mode == controller.preference.mode
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(switch (mode) {
                    AppThemeMode.system => 'System',
                    AppThemeMode.light => 'Light',
                    AppThemeMode.dark => 'Dark',
                  }),
                  onTap: () => controller.selectMode(mode),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
