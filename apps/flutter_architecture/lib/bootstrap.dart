import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/database/database_initializer.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// 共用 App bootstrap。
Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDatabaseFactory();

  final config = AppConfigFactory.fromEnvironment(environment: environment);
  await configureDependencies(config);

  runApp(
    HookedBlocConfigProvider(
      injector: () => getIt.get,
      child: const ArchitectureApp(),
    ),
  );
}
