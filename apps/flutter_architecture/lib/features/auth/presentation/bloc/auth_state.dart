part of 'auth_bloc.dart';

enum AuthFailureOperation { restore, login, logout }

/// AuthBloc 的狀態。
///
/// State 代表「畫面目前應該如何呈現」。
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    required bool isLoading,
    required AuthUser? user,
    required Failure? failure,
    required AuthFailureOperation? failureOperation,
  }) = _AuthState;

  const AuthState._();

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      user: null,
      failure: null,
      failureOperation: null,
    );
  }

  bool get isAuthenticated => user != null;
}
