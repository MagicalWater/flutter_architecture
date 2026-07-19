import 'package:core/src/errors/failure.dart';

/// 表示一個操作結果。
///
/// ## 為什麼需要 Result？
///
/// 在 Clean Architecture 裡面，Domain Layer 不應該直接處理 DioException、
/// Sqflite Exception 這類外部實作細節。
///
/// 因此我們用 [Result] 把成功與失敗統一包起來。
sealed class Result<T> {
  const Result();

  /// 根據目前結果執行對應 callback。
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final onFailure = failure;
    return switch (this) {
      Success<T>(:final data) => success(data),
      FailureResult<T>(:final failure) => onFailure(failure),
    };
  }
}

/// 成功結果。
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// 失敗結果。
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
