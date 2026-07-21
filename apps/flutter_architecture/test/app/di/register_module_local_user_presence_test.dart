import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/auth/data/local_user_presence/local_auth_user_presence_verifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

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

      await configureDependencies(config, const NoopErrorReporter());

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
