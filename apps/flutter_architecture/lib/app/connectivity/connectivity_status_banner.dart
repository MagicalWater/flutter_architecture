import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_scope.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

/// App-wide non-blocking offline context。
///
/// 只有明確[ConnectivityState.offline]才顯示；unknown不會被誤標為離線。
final class ConnectivityStatusBanner extends StatelessWidget {
  const ConnectivityStatusBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = ConnectivityScope.of(context);
    return StreamBuilder<ConnectivityState>(
      stream: controller.states,
      initialData: controller.state,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == ConnectivityState.offline;
        return Column(
          children: <Widget>[
            if (isOffline)
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.cloud_off_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).connectivityOfflineMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
