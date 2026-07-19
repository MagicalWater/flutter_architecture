import 'dart:async';

import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/navigation/auth_navigation_coordinator.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:flutter_architecture/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_architecture/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_architecture/features/protected/presentation/pages/protected_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await configureDependencies(
      AppConfigFactory.fromValues(
        environment: AppEnvironment.development,
        apiModeValue: 'mock',
        apiBaseUrlValue: '',
      ),
      const NoopErrorReporter(),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'App-mounted router完成Login→Profile，Protected上返回Login且不重複Shell',
    (tester) async {
      final defaultTheme = DefaultThemeDefinition();
      final registry = DsThemeRegistry(
        definitions: <DsThemeDefinition>[defaultTheme],
        defaultThemeId: defaultTheme.id,
      );
      final themeController = ThemeController(
        registry: registry,
        store: ThemePreferenceStore(
          const _MemoryThemePreferenceStorage(),
          ThemePreferenceCodec(registry),
        ),
        initialPreference: ThemePreference.defaults(registry),
        errorReporter: const NoopErrorReporter(),
      );
      final localeController = LocaleController(
        store: const LocalePreferenceStore(
          _MemoryLocalePreferenceStorage(),
          LocalePreferenceCodec(),
        ),
        initialPreference: AppLocalePreference.english,
        errorReporter: const NoopErrorReporter(),
      );

      await tester.pumpWidget(
        HookedBlocConfigProvider(
          injector: () => getIt.get,
          child: ArchitectureApp(
            themeController: themeController,
            localeController: localeController,
          ),
        ),
      );
      await _pumpFrames(tester);

      expect(find.byType(LoginPage), findsOneWidget);

      final router = getIt<AppRouter>();
      await reconcileAuthDestination(
        router,
        AuthNavigationDestination.profile,
      );
      await _pumpFrames(tester);

      expect(find.byType(ProfilePage), findsOneWidget);
      expect(router.stack.where((route) => route.name == ShellRoute.name), hasLength(1));

      getIt<SessionManager>().setAuthenticated(
        accessToken: 'access-token',
        userId: 'user-1',
      );
      unawaited(router.push(const ProtectedRoute()));
      await _pumpFrames(tester);
      expect(find.byType(ProtectedPage), findsOneWidget);

      await reconcileAuthDestination(
        router,
        AuthNavigationDestination.login,
      );
      await _pumpFrames(tester);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ProtectedPage), findsNothing);
      expect(router.stack.where((route) => route.name == ShellRoute.name), hasLength(1));
    },
  );
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var index = 0; index < 20; index += 1) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

final class _MemoryThemePreferenceStorage implements ThemePreferenceStorage {
  const _MemoryThemePreferenceStorage();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {}
}

final class _MemoryLocalePreferenceStorage implements LocalePreferenceStorage {
  const _MemoryLocalePreferenceStorage();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {}
}
