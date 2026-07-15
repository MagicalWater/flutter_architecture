import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('configureDependencies 會註冊設定並建立 Mock API graph', () async {
    final config = AppConfig(
      environment: AppEnvironment.development,
      api: ApiConfig(
        mode: ApiMode.mock,
        baseUri: Uri.parse('https://mock.local'),
      ),
    );

    await configureDependencies(config);

    expect(getIt<AppConfig>(), same(config));
    expect(getIt<ApiConfig>(), same(config.api));
    expect(getIt<AuthApi>(), isA<MockAuthApi>());
    expect(getIt<AuthRefreshApi>(), isA<MockAuthRefreshApi>());
    expect(getIt<AuthRefresher>(), isA<AuthSessionRefresher>());
    expect(getIt<ProfileApi>(), isA<MockProfileApi>());
    final mainDio = getIt<Dio>(instanceName: 'mainDio');
    final refreshDio = getIt<Dio>(instanceName: 'refreshDio');
    expect(mainDio.options.baseUrl, 'https://mock.local');
    expect(refreshDio.options.baseUrl, 'https://mock.local');
    expect(mainDio.interceptors.whereType<AuthHeaderInterceptor>(), hasLength(1));
    expect(refreshDio.interceptors.whereType<AuthHeaderInterceptor>(), isEmpty);
  });
}
