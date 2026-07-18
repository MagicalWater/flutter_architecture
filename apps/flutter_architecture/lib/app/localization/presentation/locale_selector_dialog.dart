import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

final class LocaleSelectorDialog extends StatelessWidget {
  const LocaleSelectorDialog({required this.controller, super.key});

  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AlertDialog(
          title: Text(l10n.localeDialogTitle),
          content: RadioGroup<AppLocalePreference>(
            groupValue: controller.preference,
            onChanged: (value) {
              if (value != null) controller.select(value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioListTile<AppLocalePreference>(
                  value: AppLocalePreference.system,
                  title: Text(l10n.localeSystemLabel),
                ),
                RadioListTile<AppLocalePreference>(
                  value: AppLocalePreference.english,
                  title: Text(l10n.localeEnglishLabel),
                ),
                RadioListTile<AppLocalePreference>(
                  value: AppLocalePreference.traditionalChinese,
                  title: Text(l10n.localeTraditionalChineseLabel),
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
