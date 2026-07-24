import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_architecture/app/database/app_database_opener.dart';
import 'package:flutter_architecture/app/di/injection.config.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

/// 全域 DI 容器。
///
/// ## 為什麼使用 get_it + injectable？
///
/// get_it 是依賴容器。
/// injectable 負責根據註解產生註冊程式碼。
///
/// UI 仍然可以用 BlocProvider 取得 Bloc，
/// 但 Bloc、UseCase、Repository、DataSource 的建立交給 DI 管理。
final GetIt getIt = GetIt.instance;

@InjectableInit(ignoreUnregisteredTypes: [ApiConfig, ErrorReporter, AppDatabase])
Future<void> configureDependencies(
  AppConfig config,
  ErrorReporter errorReporter, {
  AppDatabase? database,
}) async {
  if (getIt.isRegistered<AppConfig>()) {
    await getIt.reset();
  }

  getIt.registerSingleton<AppConfig>(config);
  getIt.registerSingleton<ApiConfig>(config.api);
  getIt.registerSingleton<ErrorReporter>(errorReporter);
  getIt.registerSingleton<AppDatabase>(
    database ?? await openAppDatabase(),
    dispose: (database) => database.close(),
  );
  await getIt.init();
}
