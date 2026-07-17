import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_policy.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_clock.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
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
    expect(getIt<CatalogApi>(), isA<MockCatalogApi>());
    expect(getIt<CatalogLocalDataSource>(), isNotNull);
    expect(getIt<CatalogRemoteDataSource>(), isNotNull);
    expect(getIt<CatalogCachePolicy>(), isNotNull);
    expect(getIt<CatalogClock>(), isA<SystemCatalogClock>());
    expect(getIt<CatalogRepository>(), isA<CatalogRepositoryImpl>());
    expect(getIt<SearchCatalogUseCase>(), isNotNull);
    await _expectCatalogScopes();
    final mainDio = getIt<Dio>(instanceName: 'mainDio');
    final refreshDio = getIt<Dio>(instanceName: 'refreshDio');
    expect(mainDio.options.baseUrl, 'https://mock.local');
    expect(refreshDio.options.baseUrl, 'https://mock.local');
    expect(
      mainDio.interceptors.whereType<AuthHeaderInterceptor>(),
      hasLength(1),
    );
    expect(
      mainDio.interceptors.whereType<AuthRefreshInterceptor>(),
      hasLength(1),
    );
    expect(refreshDio.interceptors.whereType<AuthHeaderInterceptor>(), isEmpty);
    expect(
      refreshDio.interceptors.whereType<AuthRefreshInterceptor>(),
      isEmpty,
    );
  });

  test('configureDependencies 會建立 Real API graph', () async {
    final config = AppConfig(
      environment: AppEnvironment.development,
      api: ApiConfig(
        mode: ApiMode.real,
        baseUri: Uri.parse('https://api.example.test'),
      ),
    );

    await configureDependencies(config);

    expect(getIt<AuthApi>(), isNot(isA<MockAuthApi>()));
    expect(getIt<AuthRefreshApi>(), isNot(isA<MockAuthRefreshApi>()));
    expect(getIt<ProfileApi>(), isNot(isA<MockProfileApi>()));
    expect(getIt<CatalogApi>(), isNot(isA<MockCatalogApi>()));
    expect(getIt<CatalogLocalDataSource>(), isNotNull);
    expect(getIt<CatalogRemoteDataSource>(), isNotNull);
    expect(getIt<CatalogCachePolicy>(), isNotNull);
    expect(getIt<CatalogClock>(), isA<SystemCatalogClock>());
    expect(getIt<CatalogRepository>(), isA<CatalogRepositoryImpl>());
    expect(getIt<SearchCatalogUseCase>(), isNotNull);
    await _expectCatalogScopes();
    expect(getIt<AuthRefresher>(), isA<AuthSessionRefresher>());
    final mainDio = getIt<Dio>(instanceName: 'mainDio');
    final refreshDio = getIt<Dio>(instanceName: 'refreshDio');
    expect(mainDio.options.baseUrl, 'https://api.example.test');
    expect(refreshDio.options.baseUrl, 'https://api.example.test');
    expect(
      mainDio.interceptors.whereType<AuthHeaderInterceptor>(),
      hasLength(1),
    );
    expect(
      mainDio.interceptors.whereType<AuthRefreshInterceptor>(),
      hasLength(1),
    );
    expect(refreshDio.interceptors.whereType<AuthHeaderInterceptor>(), isEmpty);
    expect(
      refreshDio.interceptors.whereType<AuthRefreshInterceptor>(),
      isEmpty,
    );
  });
}

Future<void> _expectCatalogScopes() async {
  expect(
    identical(getIt<CatalogLocalDataSource>(), getIt<CatalogLocalDataSource>()),
    isTrue,
  );
  expect(
    identical(getIt<CatalogCachePolicy>(), getIt<CatalogCachePolicy>()),
    isTrue,
  );
  expect(identical(getIt<CatalogClock>(), getIt<CatalogClock>()), isTrue);
  expect(
    identical(getIt<CatalogRepository>(), getIt<CatalogRepository>()),
    isTrue,
  );
  expect(
    identical(getIt<SearchCatalogUseCase>(), getIt<SearchCatalogUseCase>()),
    isFalse,
  );

  final firstBloc = getIt<CatalogBloc>();
  final secondBloc = getIt<CatalogBloc>();
  expect(identical(firstBloc, secondBloc), isFalse);
  await firstBloc.close();
  await secondBloc.close();
}
