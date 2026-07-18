import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_architecture/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'ProfileView maps unauthenticated loading error and content states',
    (tester) async {
      final theme = OceanThemeDefinition().createDarkTheme();

      await tester.pumpWidget(
        _TestApp(
          theme: theme,
          child: ProfileView(
            isAuthenticated: false,
            isLoading: false,
            onRetry: _noop,
            onLogout: _noop,
          ),
        ),
      );
      expect(find.byType(DsMessageState), findsOneWidget);

      await tester.pumpWidget(
        _TestApp(
          theme: theme,
          child: ProfileView(
            isAuthenticated: true,
            isLoading: true,
            onRetry: _noop,
            onLogout: _noop,
          ),
        ),
      );
      expect(find.byType(DsLoadingState), findsOneWidget);

      await tester.pumpWidget(
        _TestApp(
          theme: theme,
          child: ProfileView(
            isAuthenticated: true,
            isLoading: false,
            failureMessage: 'network failed',
            failureOperation: ProfileFailureOperation.load,
            onRetry: _noop,
            onLogout: _noop,
          ),
        ),
      );
      expect(find.byType(DsBlockingErrorState), findsOneWidget);

      await tester.pumpWidget(
        _TestApp(
          theme: theme,
          child: ProfileView(
            isAuthenticated: true,
            isLoading: false,
            profile: const Profile(id: '1', name: 'Demo'),
            onRetry: _noop,
            onLogout: _noop,
          ),
        ),
      );
      expect(find.text('目前登入用戶：Demo'), findsOneWidget);
      expect(find.byType(DsConstrainedContent), findsOneWidget);
    },
  );

  testWidgets('ProfileView keeps content for logout progress and failure', (
    tester,
  ) async {
    final profile = const Profile(id: '1', name: 'Demo');

    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        child: ProfileView(
          isAuthenticated: true,
          isLoading: true,
          profile: profile,
          onRetry: _noop,
          onLogout: _noop,
        ),
      ),
    );

    expect(find.text('目前登入用戶：Demo'), findsOneWidget);
    expect(find.byType(DsLoadingState), findsNothing);
    expect(find.bySemanticsLabel('登出進度'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        child: ProfileView(
          isAuthenticated: true,
          isLoading: false,
          failureMessage: 'logout failed',
          failureOperation: ProfileFailureOperation.logout,
          profile: profile,
          onRetry: _noop,
          onLogout: _noop,
        ),
      ),
    );

    expect(find.text('目前登入用戶：Demo'), findsOneWidget);
    expect(find.byType(DsBlockingErrorState), findsNothing);
    expect(find.byType(DsStatusBanner), findsOneWidget);
    expect(find.text('logout failed'), findsOneWidget);
  });

  testWidgets('ProfileView wires retry and logout callbacks', (tester) async {
    var retryCount = 0;
    var logoutCount = 0;

    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        child: ProfileView(
          isAuthenticated: true,
          isLoading: false,
          failureMessage: 'network failed',
          failureOperation: ProfileFailureOperation.load,
          onRetry: () => retryCount += 1,
          onLogout: () => logoutCount += 1,
        ),
      ),
    );
    await tester.tap(find.text('重試'));
    expect(retryCount, 1);

    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        child: ProfileView(
          isAuthenticated: true,
          isLoading: false,
          profile: const Profile(id: '1', name: 'Demo'),
          onRetry: () => retryCount += 1,
          onLogout: () => logoutCount += 1,
        ),
      ),
    );
    await tester.tap(find.text('登出'));
    expect(logoutCount, 1);
  });

  testWidgets('ProfileView supports narrow viewport and 2.0 text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        textScaler: const TextScaler.linear(2),
        child: ProfileView(
          isAuthenticated: true,
          isLoading: false,
          profile: const Profile(id: '1', name: 'A very long profile name'),
          onRetry: _noop,
          onLogout: _noop,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

void _noop() {}

final class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.theme,
    required this.child,
    this.textScaler = TextScaler.noScaling,
  });

  final ThemeData theme;
  final Widget child;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      locale: const Locale('zh', 'TW'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(body: child),
      ),
    );
  }
}
