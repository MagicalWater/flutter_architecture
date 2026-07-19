import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/database/database_initializer.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/app_bloc_observer.dart';
import 'package:flutter_architecture/app/error_reporting/app_uncaught_error_handler.dart';
import 'package:flutter_architecture/app/error_reporting/bootstrap_error_guard.dart';
import 'package:flutter_architecture/app/error_reporting/debug_error_reporter.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_bootstrap.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/theme/theme_bootstrap.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 共用 App bootstrap。
Future<void> bootstrap(AppEnvironment environment) async {
  final errorReporter = DebugErrorReporter();
  final deduplicator = ErrorReportDeduplicator();

  await runBootstrapGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppUncaughtErrorHooks.install(
        AppUncaughtErrorHandler(errorReporter, deduplicator),
      );
      Bloc.observer = AppBlocObserver(errorReporter, deduplicator);

      await initializeDatabaseFactory();

      final config = AppConfigFactory.fromEnvironment(environment: environment);
      await configureDependencies(config, errorReporter);

      final defaultTheme = DefaultThemeDefinition();
      final oceanTheme = OceanThemeDefinition();
      final registry = DsThemeRegistry(
        definitions: <DsThemeDefinition>[defaultTheme, oceanTheme],
        defaultThemeId: defaultTheme.id,
      );
      final preferences = getIt<SharedPreferences>();
      final compositionRootReporter = getIt<ErrorReporter>();
      final themeController = await restoreThemeController(
        registry: registry,
        storage: SharedPreferencesThemePreferenceStorage(preferences),
        errorReporter: compositionRootReporter,
      );
      final localeController = await restoreLocaleController(
        storage: SharedPreferencesLocalePreferenceStorage(preferences),
        errorReporter: compositionRootReporter,
      );

      runApp(
        HookedBlocConfigProvider(
          injector: () => getIt.get,
          child: ArchitectureApp(
            themeController: themeController,
            localeController: localeController,
          ),
        ),
      );
    },
    errorReporter,
    deduplicator,
  );
}
