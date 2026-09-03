part of 'auth_bloc.dart';

/// 標記這次 Auth 錯誤是在哪個使用者流程發生，讓畫面能顯示正確提示。
enum AuthFailureOperation {
  /// App 啟動時還原既有登入狀態失敗。
  restore,

  /// 使用帳密登入失敗。
  login,

  /// 驗證 OTP 驗證碼失敗。
  verifyOtp,

  /// 重新發送 OTP 驗證碼失敗。
  resendOtp,

  /// 登出或清除登入狀態失敗。
  logout,
}

/// Auth 畫面目前正在呈現哪一個階段。
enum AuthPresentationStatus {
  /// 尚未登入，顯示登入畫面。
  unauthenticated,

  /// 正在提交登入資料，等待後端結果。
  submitting,

  /// 登入需要 OTP，等待使用者輸入驗證碼。
  otpRequired,

  /// 正在送出 OTP 驗證。
  verifying,

  /// 正在要求重新發送 OTP。
  resending,

  /// 已登入完成。
  authenticated,
}

/// Auth 畫面唯一使用的狀態資料。
///
/// [status] 決定目前流程階段；[user] 有值代表已建立登入 Session；
/// [failure] 搭配 [failureOperation] 告訴畫面「哪一步失敗」，避免只看到一個無來源的錯誤。
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthPresentationStatus.unauthenticated)
    AuthPresentationStatus status,
    required bool isLoading,
    required AuthUser? user,
    @Default(null) OtpChallenge? otpChallenge,
    required Failure? failure,
    required AuthFailureOperation? failureOperation,
  }) = _AuthState;

  const AuthState._();

  factory AuthState.initial() {
    return const AuthState(
      status: AuthPresentationStatus.unauthenticated,
      isLoading: false,
      user: null,
      otpChallenge: null,
      failure: null,
      failureOperation: null,
    );
  }

  bool get isAuthenticated => user != null;
}
