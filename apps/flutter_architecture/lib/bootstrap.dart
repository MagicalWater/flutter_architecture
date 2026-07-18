import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/database/database_initializer.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/theme/theme_bootstrap.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 共用 App bootstrap。
Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDatabaseFactory();

  final config = AppConfigFactory.fromEnvironment(environment: environment);
  await configureDependencies(config);

  final defaultTheme = DefaultThemeDefinition();
  final oceanTheme = OceanThemeDefinition();
  final registry = DsThemeRegistry(
    definitions: <DsThemeDefinition>[defaultTheme, oceanTheme],
    defaultThemeId: defaultTheme.id,
  );
  final themeController = await restoreThemeController(
    registry: registry,
    storage: SharedPreferencesThemePreferenceStorage(
      getIt<SharedPreferences>(),
    ),
  );

  runApp(
    HookedBlocConfigProvider(
      injector: () => getIt.get,
      child: ArchitectureApp(themeController: themeController),
    ),
  );
}
