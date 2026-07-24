import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_adapter.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';

typedef ConnectivitySnapshotReader =
    Future<List<ConnectivityResult>> Function();

/// `connectivity_plus` 的 App-owned adapter。
///
/// Provider-specific connection types在此被收斂成最小typed state；呼叫方不會
/// 知道Wi-Fi、mobile、ethernet或其他provider enum。
final class ConnectivityPlusAdapter implements ConnectivityAdapter {
  ConnectivityPlusAdapter({
    Connectivity? connectivity,
    ConnectivitySnapshotReader? snapshotReader,
    Stream<List<ConnectivityResult>>? changeStream,
  }) : assert(
         connectivity != null ||
             (snapshotReader != null && changeStream != null),
         'Must provide Connectivity or both test seams',
       ),
       _snapshotReader = snapshotReader ?? connectivity!.checkConnectivity,
       _changeStream = changeStream ?? connectivity!.onConnectivityChanged;

  final ConnectivitySnapshotReader _snapshotReader;
  final Stream<List<ConnectivityResult>> _changeStream;
  bool _isDisposed = false;

  @override
  Future<ConnectivityState> readCurrentState() async {
    _ensureActive();
    return mapResults(await _snapshotReader());
  }

  @override
  Stream<ConnectivityState> get stateChanges {
    _ensureActive();
    return _changeStream.map(mapResults);
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
  }

  static ConnectivityState mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      return ConnectivityState.offline;
    }
    return ConnectivityState.online;
  }

  void _ensureActive() {
    if (_isDisposed) {
      throw StateError('ConnectivityPlusAdapter has been disposed');
    }
  }
}
