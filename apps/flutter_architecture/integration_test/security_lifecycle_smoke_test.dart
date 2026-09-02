import 'dart:async';

import 'package:auth/auth_infrastructure.dart';
import 'package:flutter_architecture/app/auth/local_unlock_lifecycle_coordinator.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    if (getIt.isRegistered<StartupLocalUnlockCoordinator>()) {
      await getIt.unregister<StartupLocalUnlockCoordinator>();
    }
    await getIt.reset();
  });

  testWidgets('iOS Keychain可跨composition restart讀取並由Logout刪除', (_) async {
    await _configureDependencies();

    final store = getIt<AuthCredentialStore>();
    await store.clearCredential();
    const tokens = StoredAuthTokens(
      accessToken: 'm25-access-token',
      refreshToken: 'm25-refresh-token',
      userId: 'm25-user',
    );
    await store.writeCredential(tokens);
    expect(await store.readCredential(), isA<AuthCredentialReadPresent>());

    await getIt.reset();
    await _configureDependencies();

    final restored = await getIt<AuthCredentialStore>().readCredential();
    expect(restored, isA<AuthCredentialReadPresent>());
    final restoredTokens = (restored as AuthCredentialReadPresent).tokens;
    expect(restoredTokens.accessToken, tokens.accessToken);
    expect(restoredTokens.refreshToken, tokens.refreshToken);
    expect(restoredTokens.userId, tokens.userId);

    await getIt<AuthRepository>().logout();
    expect(
      await getIt<AuthCredentialStore>().readCredential(),
      isA<AuthCredentialReadAbsent>(),
    );
  });

  testWidgets('enabled cold start在user presence成功前不讀取credential', (_) async {
    await _configureDependencies();

    final preferenceStore = getIt<LocalUnlockPreferenceStore>();
    await preferenceStore.writeEnabled(true);
    final sessionManager = getIt<SessionManager>()
      ..setAuthenticated(accessToken: 'runtime-token', userId: 'm25-user');
    final verification = Completer<LocalUserPresenceVerification>();
    var credentialReads = 0;
    final coordinator = StartupLocalUnlockCoordinator(
      preferenceStore: preferenceStore,
      verifier: _PendingVerifier(verification.future),
      sessionManager: sessionManager,
      mutationCoordinator: getIt<AuthStateMutationCoordinator>(),
      restoreSession: () async {
        credentialReads += 1;
        await getIt<AuthCredentialStore>().readCredential();
      },
    );

    final start = coordinator.start();
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.state, StartupLocalUnlockState.prompting);
    expect(sessionManager.currentSession, isNull);
    expect(credentialReads, 0);

    verification.complete(const LocalUserPresenceVerification.verified());
    await start;
    expect(credentialReads, 1);
    expect(coordinator.state, StartupLocalUnlockState.restoring);
  });

  testWidgets('prompt lifecycle bounce不重複prompt且grace period後fail closed', (
    _,
  ) async {
    await _configureDependencies();

    final preferenceStore = getIt<LocalUnlockPreferenceStore>();
    await preferenceStore.writeEnabled(true);
    final verifier = _CountingVerifier();
    final sessionManager = getIt<SessionManager>()
      ..setAuthenticated(accessToken: 'runtime-token', userId: 'm25-user');
    final unlock = StartupLocalUnlockCoordinator(
      preferenceStore: preferenceStore,
      verifier: verifier,
      sessionManager: sessionManager,
      mutationCoordinator: getIt<AuthStateMutationCoordinator>(),
      restoreSession: () {},
    );
    await unlock.start();

    var now = Duration.zero;
    final lifecycle = LocalUnlockLifecycleCoordinator(
      unlockCoordinator: unlock,
      preferenceStore: preferenceStore,
      sessionManager: sessionManager,
      now: () => now,
    );

    lifecycle.onBackgrounded();
    await lifecycle.onResumed();
    expect(verifier.verifyCalls, 1);

    sessionManager.setAuthenticated(
      accessToken: 'runtime-token',
      userId: 'm25-user',
    );
    lifecycle.onBackgrounded();
    now = const Duration(minutes: 6);
    expect(await lifecycle.onResumed(), isTrue);
    expect(sessionManager.currentSession, isNull);
    expect(verifier.verifyCalls, 2);
  });

  testWidgets('iOS local_auth capability回傳typed disposition', (_) async {
    await _configureDependencies();

    final capability = await getIt<LocalUserPresenceVerifier>()
        .checkCapability();
    expect(capability, isA<LocalUserPresenceCapability>());
  });
}

Future<void> _configureDependencies() async {
  await configureDependencies(
    AppConfigFactory.fromValues(
      environment: AppEnvironment.development,
      apiModeValue: 'mock',
      apiBaseUrlValue: '',
    ),
    const NoopErrorReporter(),
  );
}

final class _PendingVerifier implements LocalUserPresenceVerifier {
  const _PendingVerifier(this.verification);

  final Future<LocalUserPresenceVerification> verification;

  @override
  Future<LocalUserPresenceCapability> checkCapability() async =>
      const LocalUserPresenceCapability.available();

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) =>
      verification;
}

final class _CountingVerifier implements LocalUserPresenceVerifier {
  int verifyCalls = 0;

  @override
  Future<LocalUserPresenceCapability> checkCapability() async =>
      const LocalUserPresenceCapability.available();

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) async {
    verifyCalls += 1;
    return const LocalUserPresenceVerification.verified();
  }
}
