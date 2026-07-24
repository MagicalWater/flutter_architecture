import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/app_bloc_observer.dart';
import 'package:flutter_architecture/app/error_reporting/app_uncaught_error_handler.dart';
import 'package:flutter_architecture/app/error_reporting/bootstrap_error_guard.dart';
import 'package:flutter_architecture/app/error_reporting/debug_error_reporter.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporting_router.dart';
import 'package:flutter_architecture/app/localization/locale_bootstrap.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/observability/firebase_crashlytics_adapter.dart';
import 'package:flutter_architecture/app/observability/observability_acceptance_event.dart';
import 'package:flutter_architecture/app/observability/observability_runtime_config.dart';
import 'package:flutter_architecture/app/observability/release_build_metadata.dart';
import 'package:flutter_architecture/app/observability/release_identity.dart';
import 'package:flutter_architecture/app/observability/release_identity_factory.dart';
import 'package:flutter_architecture/app/theme/theme_bootstrap.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 共用 App bootstrap。
Future<void> bootstrap(
  AppEnvironment environment, {
  bool allowMissingNativeEnvironment = false,
}) async {
  ErrorReporter errorReporter = ErrorReportingRouter(
    delegate: DebugErrorReporter(),
  );
  final deduplicator = ErrorReportDeduplicator();

  await runBootstrapGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final observabilityConfig =
          ObservabilityRuntimeConfig.fromBuildEnvironment(environment);
      final releaseIdentity =
          await ReleaseIdentityFactory(
            const PackageInfoReleaseMetadataReader(),
          ).create(
            environment: environment,
            platform: switch (defaultTargetPlatform) {
              TargetPlatform.android => ReleasePlatform.android,
              TargetPlatform.iOS => ReleasePlatform.ios,
              _ => ReleasePlatform.other,
            },
            nativeConfiguration: environment.name,
            buildMetadata: ReleaseBuildMetadata.fromEnvironment(),
          );
      final releaseKeys = <String, String>{
        'release': '${releaseIdentity.version}+${releaseIdentity.buildNumber}',
        'environment': releaseIdentity.environment.name,
        'platform': releaseIdentity.platform.name,
        'native_configuration': releaseIdentity.nativeConfiguration,
      };
      final commitSha = releaseIdentity.commitSha;
      if (commitSha != null) {
        releaseKeys['commit_sha'] = commitSha;
      }
      final observability = await FirebaseObservabilityComposition(
        gateway: const FirebaseSdkCrashlyticsGateway(),
        collectionPolicy: observabilityConfig.collectionPolicy,
        localFallback: errorReporter,
        initialKeys: releaseKeys,
      ).compose();
      errorReporter = ErrorReportingRouter(delegate: observability.reporter);
      AppUncaughtErrorHooks.install(
        AppUncaughtErrorHandler(errorReporter, deduplicator),
      );
      Bloc.observer = AppBlocObserver(errorReporter, deduplicator);
      ObservabilityAcceptanceEvent.emit(
        reporter: errorReporter,
        config: observabilityConfig,
      );

      final config = AppConfigFactory.fromEnvironment(
        environment: environment,
        allowMissingNativeEnvironment: allowMissingNativeEnvironment,
      );
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
