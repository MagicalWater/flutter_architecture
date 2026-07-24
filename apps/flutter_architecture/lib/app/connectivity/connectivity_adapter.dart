import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';

/// Platform connectivity provider 的 App-owned abstraction。
///
/// 實作不得暴露 provider enum，也不得在這個 boundary 執行 backend probe。
abstract interface class ConnectivityAdapter {
  Future<ConnectivityState> readCurrentState();

  Stream<ConnectivityState> get stateChanges;

  Future<void> dispose();
}
