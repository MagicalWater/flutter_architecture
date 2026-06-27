import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

/// Auth 的全域業務狀態管理。
///
/// ## Runtime Flow
///
/// ```txt
/// LoginPage
///   ↓ add(AuthLoginRequested)
/// AuthBloc  ← 目前所在位置
///   ↓
/// LoginUseCase
///   ↓
/// Repository
/// ```
///
/// Bloc 不直接呼叫 Dio，也不直接讀寫 SQLite。
/// 它只負責把 UI event 轉換成 UseCase 呼叫，再把結果轉成 UI state。
@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._loginUseCase,
    this._restoreSessionUseCase,
    this._logoutUseCase,
    this._sessionManager,
  ) : super(AuthState.initial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionCleared>(_onSessionCleared);

    _sessionSubscription = _sessionManager.sessionStream.listen((session) {
      if (session == null && state.isAuthenticated) {
        add(const AuthEvent.sessionCleared());
      }
    });
  }

  final LoginUseCase _loginUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final LogoutUseCase _logoutUseCase;
  final SessionManager _sessionManager;
  late final StreamSubscription<AuthSession?> _sessionSubscription;

  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _restoreSessionUseCase.execute();

    result.when(
      success: (user) {
        emit(
          state.copyWith(
            isLoading: false,
            user: user,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _loginUseCase.execute(
      account: event.account,
      password: event.password,
    );

    result.when(
      success: (authResult) {
        emit(
          state.copyWith(
            isLoading: false,
            user: authResult.user,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void _onSessionCleared(
    AuthSessionCleared event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthState.initial());
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _logoutUseCase.execute();

    result.when(
      success: (_) {
        emit(AuthState.initial());
      },
      failure: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _sessionSubscription.cancel();
    return super.close();
  }
}
