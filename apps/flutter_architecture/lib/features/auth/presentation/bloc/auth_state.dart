part of 'auth_bloc.dart';

/// AuthBloc 的狀態。
///
/// State 代表「畫面目前應該如何呈現」。
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    required bool isLoading,
    required AuthUser? user,
    required String? errorMessage,
  }) = _AuthState;

  const AuthState._();

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      user: null,
      errorMessage: null,
    );
  }

  bool get isAuthenticated => user != null;
}
