import 'dart:async';

/// 序列化 Auth persistence 與 runtime Session 的複合修改。
class AuthStateMutationCoordinator {
  Future<void> _tail = Future<void>.value();

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
