import 'dart:async';

import 'package:flutter_architecture/app/connectivity/connectivity_adapter.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_controller.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectivityController', () {
    test('initial state固定為unknown', () {
      final controller = ConnectivityController(_FakeConnectivityAdapter());

      expect(controller.state, ConnectivityState.unknown);
    });

    test('先訂閱stream再套用snapshot，較新的event不被舊snapshot覆蓋', () async {
      final snapshot = Completer<ConnectivityState>();
      final adapter = _FakeConnectivityAdapter(snapshot: snapshot.future);
      final controller = ConnectivityController(adapter);

      final start = controller.start();
      adapter.emit(ConnectivityState.offline);
      snapshot.complete(ConnectivityState.online);
      await start;

      expect(controller.state, ConnectivityState.offline);
      await controller.dispose();
    });

    test('unknown到online不是reconnect', () async {
      final adapter = _FakeConnectivityAdapter(
        snapshot: Future<ConnectivityState>.value(ConnectivityState.online),
      );
      final controller = ConnectivityController(adapter);
      var reconnectCount = 0;
      final subscription = controller.reconnects.listen(
        (_) => reconnectCount++,
      );

      await controller.start();

      expect(controller.state, ConnectivityState.online);
      expect(reconnectCount, 0);
      await subscription.cancel();
      await controller.dispose();
    });

    test('offline到online只產生一次reconnect且state distinct', () async {
      final adapter = _FakeConnectivityAdapter(
        snapshot: Future<ConnectivityState>.value(ConnectivityState.offline),
      );
      final controller = ConnectivityController(adapter);
      final states = <ConnectivityState>[];
      var reconnectCount = 0;
      final stateSub = controller.states.listen(states.add);
      final reconnectSub = controller.reconnects.listen(
        (_) => reconnectCount++,
      );

      await controller.start();
      adapter
        ..emit(ConnectivityState.offline)
        ..emit(ConnectivityState.online)
        ..emit(ConnectivityState.online);

      expect(states, <ConnectivityState>[
        ConnectivityState.offline,
        ConnectivityState.online,
      ]);
      expect(reconnectCount, 1);
      await stateSub.cancel();
      await reconnectSub.cancel();
      await controller.dispose();
    });

    test('同時recheck共用single-flight', () async {
      final snapshot = Completer<ConnectivityState>();
      final adapter = _FakeConnectivityAdapter(snapshot: snapshot.future);
      final controller = ConnectivityController(adapter);

      final first = controller.recheck();
      final second = controller.recheck();
      snapshot.complete(ConnectivityState.online);
      await Future.wait<void>(<Future<void>>[first, second]);

      expect(adapter.readCount, 1);
      await controller.dispose();
    });

    test('snapshot error與stream error降級為unknown而不是offline', () async {
      final adapter = _FakeConnectivityAdapter(
        snapshot: Future<ConnectivityState>.error(StateError('snapshot')),
      );
      final controller = ConnectivityController(adapter);

      await controller.start();
      expect(controller.state, ConnectivityState.unknown);

      adapter.emit(ConnectivityState.online);
      expect(controller.state, ConnectivityState.online);
      adapter.emitError(StateError('stream'));
      expect(controller.state, ConnectivityState.unknown);
      await controller.dispose();
    });

    test('dispose取消subscription且不再接受操作', () async {
      final adapter = _FakeConnectivityAdapter();
      final controller = ConnectivityController(adapter);
      await controller.start();

      await controller.dispose();
      adapter.emit(ConnectivityState.online);

      expect(adapter.isDisposed, isTrue);
      expect(controller.recheck, throwsStateError);
    });
  });
}

final class _FakeConnectivityAdapter implements ConnectivityAdapter {
  _FakeConnectivityAdapter({Future<ConnectivityState>? snapshot})
    : _snapshot =
          snapshot ??
          Future<ConnectivityState>.value(ConnectivityState.unknown);

  final Future<ConnectivityState> _snapshot;
  final StreamController<ConnectivityState> _changes =
      StreamController<ConnectivityState>.broadcast(sync: true);
  int readCount = 0;
  bool isDisposed = false;

  void emit(ConnectivityState state) {
    if (_changes.isClosed) return;
    _changes.add(state);
  }

  void emitError(Object error) {
    if (_changes.isClosed) return;
    _changes.addError(error, StackTrace.current);
  }

  @override
  Future<ConnectivityState> readCurrentState() {
    readCount++;
    return _snapshot;
  }

  @override
  Stream<ConnectivityState> get stateChanges => _changes.stream;

  @override
  Future<void> dispose() async {
    isDisposed = true;
    await _changes.close();
  }
}
