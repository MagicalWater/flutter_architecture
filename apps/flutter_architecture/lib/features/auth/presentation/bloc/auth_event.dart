part of 'auth_bloc.dart';

/// AuthBloc 可接收的事件。
///
/// Event 代表「發生了什麼事」。
@Freezed(toStringOverride: false)
sealed class AuthEvent with _$AuthEvent {
  /// App 啟動後檢查本地是否已有登入資訊。
  const factory AuthEvent.started() = AuthStarted;

  /// 使用者按下登入按鈕。
  const factory AuthEvent.loginRequested({
    required String account,
    required String password,
  }) = AuthLoginRequested;

  /// 使用者按下登出。
  const factory AuthEvent.logoutRequested() = AuthLogoutRequested;

  /// 跨 feature 登出或 session 清除後，同步 AuthBloc UI state。
  const factory AuthEvent.sessionCleared() = AuthSessionCleared;
}
