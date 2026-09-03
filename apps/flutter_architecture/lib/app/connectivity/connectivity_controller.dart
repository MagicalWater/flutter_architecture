import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_adapter.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';

/// App-owned connectivity state authority，作為 App 內連線狀態的唯一 runtime authority。
///
/// 它只協調本機介面訊號、lifecycle recheck與真正的offline→online transition；
/// 不執行backend probe，也不自動重送任何request。
final class ConnectivityController {
  ConnectivityController(this._adapter);

  final ConnectivityAdapter _adapter;
  final StreamController<ConnectivityState> _stateController =
      StreamController<ConnectivityState>.broadcast(sync: true);
  final StreamController<void> _reconnectController =
      StreamController<void>.broadcast(sync: true);

  ConnectivityState _state = ConnectivityState.unknown;
  StreamSubscription<ConnectivityState>? _subscription;
  Future<void>? _recheckFuture;
  final OperationGeneration _observations = OperationGeneration();
  bool _started = false;
  bool _disposed = false;

  ConnectivityState get state => _state;

  Stream<ConnectivityState> get states => _stateController.stream;

  Stream<void> get reconnects => _reconnectController.stream;

  Future<void> start() async {
    _ensureActive();
    if (_started) return;
    _started = true;

    _subscription = _adapter.stateChanges.listen(
      _onAdapterState,
      onError: _onAdapterError,
      onDone: _onAdapterDone,
    );

    await recheck();
  }

  Future<void> recheck() {
    _ensureActive();
    final existing = _recheckFuture;
    if (existing != null) return existing;

    // 同一時間只允許一個 snapshot recheck；stream event 仍可先更新目前狀態。
    // recheck 開始時捕捉目前 generation，之後若收到 live event 就會失效，避免舊 snapshot
    // 較晚完成後反向覆蓋更新的 observation。
    final revisionAtStart = _observations.current;
    final future = _runRecheck(revisionAtStart);
    _recheckFuture = future;
    return future.whenComplete(() {
      if (identical(_recheckFuture, future)) {
        _recheckFuture = null;
      }
    });
  }

  Future<void> _runRecheck(int revisionAtStart) async {
    try {
      final snapshot = await _adapter.readCurrentState();
      if (_disposed || !_observations.isCurrent(revisionAtStart)) return;
      _applyState(snapshot);
    } on Object {
      if (_disposed || !_observations.isCurrent(revisionAtStart)) return;
      _applyState(ConnectivityState.unknown);
    }
  }

  void _onAdapterState(ConnectivityState next) {
    if (_disposed) return;
    // 每個 live observation 都讓尚未完成的 readCurrentState snapshot 失效。
    _observations.invalidate();
    _applyState(next);
  }

  void _onAdapterError(Object error, StackTrace stackTrace) {
    if (_disposed) return;
    _observations.invalidate();
    _applyState(ConnectivityState.unknown);
  }

  void _onAdapterDone() {
    if (_disposed) return;
    _observations.invalidate();
    _applyState(ConnectivityState.unknown);
  }

  void _applyState(ConnectivityState next) {
    if (_disposed || next == _state) return;
    final previous = _state;
    _state = next;
    _stateController.add(next);
    if (previous == ConnectivityState.offline &&
        next == ConnectivityState.online) {
      _reconnectController.add(null);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _subscription?.cancel();
    await _adapter.dispose();
    // Widget teardown 期間 outward-facing broadcast stream 可能仍有 presentation
    // listener；close Future 不應反向阻塞 App dispose。
    unawaited(_stateController.close());
    unawaited(_reconnectController.close());
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('ConnectivityController has been disposed');
    }
  }
}
