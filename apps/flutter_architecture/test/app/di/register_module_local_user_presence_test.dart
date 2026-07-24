import 'package:auth/auth.dart';
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/database/app_database.dart'
    show AppDatabase;
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/auth/data/local_user_presence/local_auth_user_presence_verifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'Composition Root registers App-owned local presence adapter lazily',
    () async {
      final config = AppConfig(
        environment: AppEnvironment.development,
        api: ApiConfig(
          mode: ApiMode.mock,
          baseUri: Uri.parse('https://mock.local'),
        ),
      );

      await configureDependencies(
        config,
        const NoopErrorReporter(),
        database: AppDatabase.forTesting(NativeDatabase.memory()),
      );

      expect(
        getIt<LocalUserPresenceVerifier>(),
        isA<LocalAuthUserPresenceVerifier>(),
      );
      expect(
        identical(
          getIt<LocalUserPresenceVerifier>(),
          getIt<LocalUserPresenceVerifier>(),
        ),
        isTrue,
      );
    },
  );
}
