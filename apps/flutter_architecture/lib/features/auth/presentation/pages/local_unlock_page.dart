import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

@RoutePage()
class LocalUnlockPage extends StatelessWidget {
  const LocalUnlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: getIt<StartupLocalUnlockCoordinator>(),
      builder: (context, _) => LocalUnlockView(
        state: getIt<StartupLocalUnlockCoordinator>().state,
        onRetry: getIt<StartupLocalUnlockCoordinator>().retry,
        onUseLogin: getIt<StartupLocalUnlockCoordinator>().useServerLogin,
      ),
    );
  }
}

final class LocalUnlockView extends StatelessWidget {
  const LocalUnlockView({
    required this.state,
    required this.onRetry,
    required this.onUseLogin,
    super.key,
  });

  final StartupLocalUnlockState state;
  final Future<void> Function() onRetry;
  final Future<void> Function() onUseLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prompting =
        state == StartupLocalUnlockState.prompting ||
        state == StartupLocalUnlockState.checkingPreference;
    final message = switch (state) {
      StartupLocalUnlockState.unavailable => l10n.localUnlockUnavailableMessage,
      StartupLocalUnlockState.preferenceCorrupted ||
      StartupLocalUnlockState.operationalFailure =>
        l10n.localUnlockFailureMessage,
      _ => l10n.localUnlockRequiredMessage,
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: DsConstrainedContent(
            maxWidth: 440,
            child: Semantics(
              namesRoute: true,
              label: l10n.localUnlockSemanticsLabel,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.lock_outline,
                    size: 56,
                    semanticLabel: l10n.localUnlockIconSemanticsLabel,
                  ),
                  const SizedBox(height: DsSpace.lg),
                  Text(
                    l10n.localUnlockTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: DsSpace.md),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: DsSpace.xl),
                  FilledButton(
                    onPressed: prompting ? null : () => onRetry(),
                    child: DsButtonContent(
                      label: prompting
                          ? l10n.localUnlockPromptingLabel
                          : l10n.localUnlockRetryAction,
                      isLoading: prompting,
                      progressSemanticsLabel:
                          l10n.localUnlockPromptProgressSemanticsLabel,
                    ),
                  ),
                  const SizedBox(height: DsSpace.md),
                  TextButton(
                    onPressed: prompting ? null : () => onUseLogin(),
                    child: Text(l10n.localUnlockUseLoginAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
