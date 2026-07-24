import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_adapter.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_controller.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_scope.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_status_banner.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('offline顯示English banner並保留child', (tester) async {
    final adapter = _FakeAdapter(ConnectivityState.offline);
    final controller = ConnectivityController(adapter);
    await controller.start();

    await tester.pumpWidget(
      _TestApp(controller: controller, locale: const Locale('en')),
    );

    expect(
      find.text('You are offline. Some content may be out of date.'),
      findsOneWidget,
    );
    expect(find.text('content'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    unawaited(controller.dispose());
  });

  testWidgets('unknown與online不誤顯示offline', (tester) async {
    final adapter = _FakeAdapter(ConnectivityState.unknown);
    final controller = ConnectivityController(adapter);
    await controller.start();
    await tester.pumpWidget(_TestApp(controller: controller));

    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);

    adapter.emit(ConnectivityState.online);
    await tester.pump();
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    unawaited(controller.dispose());
  });

  testWidgets('zh_TW與large text窄畫面不overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = ConnectivityController(
      _FakeAdapter(ConnectivityState.offline),
    );
    await controller.start();
    await tester.pumpWidget(
      _TestApp(
        controller: controller,
        locale: const Locale('zh', 'TW'),
        textScaler: const TextScaler.linear(2),
      ),
    );

    expect(find.text('目前沒有網路連線，部分內容可能不是最新資料。'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    unawaited(controller.dispose());
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.controller,
    this.locale = const Locale('en'),
    this.textScaler = TextScaler.noScaling,
  });

  final ConnectivityController controller;
  final Locale locale;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: ConnectivityScope(
          controller: controller,
          child: const ConnectivityStatusBanner(
            child: Scaffold(body: Center(child: Text('content'))),
          ),
        ),
      ),
      home: const SizedBox.shrink(),
    );
  }
}

final class _FakeAdapter implements ConnectivityAdapter {
  _FakeAdapter(this.snapshot);

  final ConnectivityState snapshot;
  final StreamController<ConnectivityState> _changes =
      StreamController<ConnectivityState>.broadcast(sync: true);

  void emit(ConnectivityState state) => _changes.add(state);

  @override
  Future<ConnectivityState> readCurrentState() async => snapshot;

  @override
  Stream<ConnectivityState> get stateChanges => _changes.stream;

  @override
  Future<void> dispose() => _changes.close();
}
