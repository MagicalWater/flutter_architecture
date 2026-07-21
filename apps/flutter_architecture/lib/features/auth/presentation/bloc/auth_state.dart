part of 'auth_bloc.dart';

enum AuthFailureOperation { restore, login, verifyOtp, resendOtp, logout }

enum AuthPresentationStatus {
  unauthenticated,
  submitting,
  otpRequired,
  verifying,
  resending,
  authenticated,
}

/// AuthBloc 的狀態。
///
/// State 代表「畫面目前應該如何呈現」。
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
