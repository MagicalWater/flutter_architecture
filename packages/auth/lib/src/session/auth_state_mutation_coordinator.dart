import 'dart:async';

import 'package:core/core.dart';

/// 避免兩個登入／登出／還原流程同時改 Auth state，導致舊結果蓋掉新結果。
///
/// [runExclusive] 讓實際 persistence mutation 一次只執行一個；[beginMutationLease]
/// 則用 generation 判斷某個較早開始的流程是否已經過期。
class AuthStateMutationCoordinator {
  Future<void> _tail = Future<void>.value();
  final OperationGeneration _lifecycleOperations = OperationGeneration();

  AuthMutationLease beginMutationLease() {
    return AuthMutationLease._(this, _lifecycleOperations.begin());
  }

  /// 直接讓目前仍在執行的 restore／login／logout 流程失效。
  ///
  /// 例如 Session 被外部 clear 時，不需要再啟動新的 repository mutation，
  /// 但一定要阻止舊流程稍後把已清掉的 Session 寫回來。
  void invalidateMutationLeases() {
    _lifecycleOperations.invalidate();
  }

  bool _isCurrent(int generation) => _lifecycleOperations.isCurrent(generation);

  Future<T> runExclusive<T>(Future<T> Function() action) {
    // 這裡只序列化 state mutation；network request 不應持有此 queue，避免慢 I/O
    // 阻塞較新的 login / logout intent。
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

/// 某一次 Auth 操作的「有效票據」。
///
/// 只要之後又開始新的登入／登出／還原，舊票據就會失效；持有舊票據的流程必須停止
/// 寫 storage、Session 或 UI，而不是把「被新操作取代」誤報成真正的錯誤。
final class AuthMutationLease {
  const AuthMutationLease._(this._owner, this._generation);

  final AuthStateMutationCoordinator _owner;
  final int _generation;

  bool get isCurrent => _owner._isCurrent(_generation);

  void throwIfSuperseded() {
    if (!isCurrent) {
      throw const AuthMutationSuperseded();
    }
  }
}

/// 表示這個 Auth 操作已被較新的操作取代，現在的結果不能再套用。
///
/// 這是正常的流程控制，不是系統故障，也不應顯示成使用者錯誤。
final class AuthMutationSuperseded implements Exception {
  const AuthMutationSuperseded();
}
