import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_plus_adapter.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectivityPlusAdapter', () {
    test('none與empty result映射為offline', () {
      expect(
        ConnectivityPlusAdapter.mapResults(const <ConnectivityResult>[]),
        ConnectivityState.offline,
      );
      expect(
        ConnectivityPlusAdapter.mapResults(const <ConnectivityResult>[
          ConnectivityResult.none,
        ]),
        ConnectivityState.offline,
      );
    });

    test('任一可用provider connection type映射為online', () {
      for (final result in ConnectivityResult.values.where(
        (value) => value != ConnectivityResult.none,
      )) {
        expect(
          ConnectivityPlusAdapter.mapResults(<ConnectivityResult>[result]),
          ConnectivityState.online,
          reason: '$result should mean an available interface',
        );
      }
    });

    test('snapshot與change stream都不洩漏provider type', () async {
      final changes = StreamController<List<ConnectivityResult>>();
      final adapter = ConnectivityPlusAdapter(
        snapshotReader: () async => const <ConnectivityResult>[
          ConnectivityResult.wifi,
        ],
        changeStream: changes.stream,
      );

      expect(await adapter.readCurrentState(), ConnectivityState.online);

      final firstChange = adapter.stateChanges.first;
      changes.add(const <ConnectivityResult>[ConnectivityResult.none]);
      expect(await firstChange, ConnectivityState.offline);

      await changes.close();
      await adapter.dispose();
    });

    test('dispose後拒絕新的snapshot與stream access', () async {
      final adapter = ConnectivityPlusAdapter(
        snapshotReader: () async => const <ConnectivityResult>[],
        changeStream: const Stream<List<ConnectivityResult>>.empty(),
      );

      await adapter.dispose();

      expect(adapter.readCurrentState, throwsStateError);
      expect(() => adapter.stateChanges, throwsStateError);
    });
  });
}
