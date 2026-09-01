import 'package:auth/auth.dart';
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/auth/local_unlock_lifecycle_coordinator.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/database/app_database.dart'
    show AppDatabase;
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  tearDown(() => getIt.reset());

  test('restore without credential clears stale enabled preference', () async {
    await _configure();
    final store = getIt<LocalUnlockPreferenceStore>();
    await store.writeEnabled(true);

    final result = await getIt<AuthRepository>().restoreSession();

    expect(result, isA<SuccessResult<AuthUser?>>());
    expect(await store.readEnabled(), isFalse);
    expect(getIt<SessionManager>().currentSession, isNull);
  });

  test('logout clears local unlock preference with auth stores', () async {
    await _configure();
    final repository = getIt<AuthRepository>();
    final store = getIt<LocalUnlockPreferenceStore>();
    final login = await repository.login(account: 'demo', password: 'password');
    expect(login, isA<SuccessResult<AuthLoginResult>>());
    await store.writeEnabled(true);

    final result = await repository.logout();

    expect(result, isA<SuccessResult<void>>());
    expect(await store.readEnabled(), isFalse);
    expect(getIt<SessionManager>().currentSession, isNull);
  });

  test(
    'legacy v1 JSON preference remains readable after storage simplification',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'auth.localUnlock.preference': '{"version":1,"enabled":true}',
      });
      await _configure();

      expect(await getIt<LocalUnlockPreferenceStore>().readEnabled(), isTrue);
    },
  );

  test(
    'corrupted preference fails closed when resume grace period expires',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'auth.localUnlock.preference': 'not-a-valid-preference',
      });
      await _configure();

      final store = getIt<LocalUnlockPreferenceStore>();
      final sessionManager = getIt<SessionManager>()
        ..setAuthenticated(accessToken: 'runtime-token', userId: 'demo-user');
      final unlock = StartupLocalUnlockCoordinator(
        preferenceStore: store,
        verifier: const _UnexpectedVerifier(),
        sessionManager: sessionManager,
        mutationCoordinator: getIt<AuthStateMutationCoordinator>(),
        restoreSession: () {},
      );
      var now = Duration.zero;
      final lifecycle = LocalUnlockLifecycleCoordinator(
        unlockCoordinator: unlock,
        preferenceStore: store,
        sessionManager: sessionManager,
        now: () => now,
      );

      lifecycle.onBackgrounded();
      now = const Duration(minutes: 6);

      expect(await lifecycle.onResumed(), isTrue);
      expect(sessionManager.currentSession, isNull);
      expect(unlock.state, StartupLocalUnlockState.operationalFailure);
    },
  );
}

final class _UnexpectedVerifier implements LocalUserPresenceVerifier {
  const _UnexpectedVerifier();

  @override
  Future<LocalUserPresenceCapability> checkCapability() =>
      throw StateError('Verifier must not run for corrupted preference.');

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) =>
      throw StateError('Verifier must not run for corrupted preference.');
}

Future<void> _configure() {
  return configureDependencies(
    AppConfig(
      environment: AppEnvironment.development,
      api: ApiConfig(
        mode: ApiMode.mock,
        baseUri: Uri.parse('https://mock.local'),
      ),
    ),
    const NoopErrorReporter(),
    database: AppDatabase.forTesting(NativeDatabase.memory()),
  );
}
