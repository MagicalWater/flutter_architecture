import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/auth/presentation/local_unlock_settings_dialog.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('authenticated user can enable and disable local unlock', (
    tester,
  ) async {
    final store = _Store();
    final policy = LocalUnlockPolicy(
      SessionManager()..setAuthenticated(accessToken: 'token', userId: 'u1'),
      AuthStateMutationCoordinator(),
      _Verifier(),
      store,
    );

    await tester.pumpWidget(_app(policy: policy, store: store));
    await tester.pumpAndSettle();

    expect(find.text('Use local unlock'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.preference, LocalUnlockPreference.enabled);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.preference, LocalUnlockPreference.disabled);
  });
}

Widget _app({
  required LocalUnlockPolicy policy,
  required LocalUnlockPreferenceStore store,
}) => MaterialApp(
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: LocalUnlockSettingsDialog(policy: policy, preferenceStore: store),
);

final class _Store implements LocalUnlockPreferenceStore {
  LocalUnlockPreference preference = LocalUnlockPreference.disabled;

  @override
  Future<LocalUnlockPreferenceReadResult> read() async =>
      LocalUnlockPreferenceReadResult.present(preference);

  @override
  Future<void> write(LocalUnlockPreference preference) async {
    this.preference = preference;
  }

  @override
  Future<void> clear() async {
    preference = LocalUnlockPreference.disabled;
  }
}

final class _Verifier implements LocalUserPresenceVerifier {
  @override
  Future<LocalUserPresenceCapability> checkCapability() async =>
      const LocalUserPresenceCapability.available();

  @override
  Future<LocalUserPresenceVerification> verify({
    required String reason,
  }) async => const LocalUserPresenceVerification.verified();
}
