import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

final class LocalUnlockSettingsDialog extends StatefulWidget {
  const LocalUnlockSettingsDialog({
    required this.policy,
    required this.preferenceStore,
    super.key,
  });

  final LocalUnlockPolicy policy;
  final LocalUnlockPreferenceStore preferenceStore;

  @override
  State<LocalUnlockSettingsDialog> createState() =>
      _LocalUnlockSettingsDialogState();
}

final class _LocalUnlockSettingsDialogState
    extends State<LocalUnlockSettingsDialog> {
  bool? _enabled;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final enabled = await widget.preferenceStore.readEnabled();
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _error = AppLocalizations.of(context).localUnlockSettingsFailureMessage;
      });
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      final result = enabled
          ? await widget.policy.enable(reason: l10n.localUnlockEnableReason)
          : await widget.policy.disable();
      if (!mounted) return;
      final succeeded = enabled
          ? result == LocalUnlockPolicyResult.enabled
          : result == LocalUnlockPolicyResult.disabled;
      setState(() {
        if (succeeded) _enabled = enabled;
        _error = succeeded ? null : l10n.localUnlockSettingsFailureMessage;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = l10n.localUnlockSettingsFailureMessage;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.localUnlockSettingsTitle),
      content: _enabled == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.localUnlockSettingsToggleLabel),
                  subtitle: Text(l10n.localUnlockSettingsDescription),
                  value: _enabled!,
                  onChanged: _isSaving ? null : _setEnabled,
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonDoneAction),
        ),
      ],
    );
  }
}
