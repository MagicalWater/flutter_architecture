import 'dart:async';

/// 序列化 Auth persistence 與 runtime Session 的複合修改。
class AuthStateMutationCoordinator {
  Future<void> _tail = Future<void>.value();
  int _lifecycleGeneration = 0;

  AuthLifecycleOperation beginLifecycleOperation() {
    _lifecycleGeneration += 1;
    return AuthLifecycleOperation._(this, _lifecycleGeneration);
  }

  /// 使目前仍在執行的 restore / login / logout operation 失效。
  ///
  /// 用於權威 Session clear 等不需要啟動新 Repository mutation，
  /// 但必須阻止舊 lifecycle operation 重新 commit Session 的情境。
  void invalidateLifecycleOperations() {
    _lifecycleGeneration += 1;
  }

  bool _isCurrent(int generation) => generation == _lifecycleGeneration;

  Future<T> runExclusive<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}

/// Auth restore / login / logout 的 latest-intent lease。
///
/// 較新的 lifecycle command 會使舊 lease 失效。失效 operation 必須停止
/// persistence、runtime Session 與 UI commit，而不是把 cancellation 映射成 Failure。
final class AuthLifecycleOperation {
  const AuthLifecycleOperation._(this._owner, this._generation);

  final AuthStateMutationCoordinator _owner;
  final int _generation;

  bool get isCurrent => _owner._isCurrent(_generation);

  void throwIfSuperseded() {
    if (!isCurrent) {
      throw const AuthLifecycleOperationSuperseded();
    }
  }
}

/// 較舊 Auth lifecycle command 被較新使用者意圖取代。
///
/// 這是 control flow，不是 operational failure，也不應進入 Failure state。
final class AuthLifecycleOperationSuperseded implements Exception {
  const AuthLifecycleOperationSuperseded();
}
