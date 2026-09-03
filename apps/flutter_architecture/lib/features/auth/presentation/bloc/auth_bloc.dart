import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

/// 接收登入、OTP、登出等畫面事件，並把 Auth Repository 的結果整理成 [AuthState]。
///
/// Bloc 不直接呼叫 Dio 或 SQLite；它只決定「現在畫面該顯示哪個 Auth 階段」。
/// Session 在其他流程被清除時，也會把仍顯示登入中／OTP 中的 UI 收回未登入狀態。
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._authRepository,
    this._sessionManager,
    this._mutationCoordinator,
  ) : super(AuthState.initial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionCleared>(_onSessionCleared);

    _sessionSubscription = _sessionManager.sessionStream.listen((session) {
      if (session == null &&
          (state.isAuthenticated ||
              state.isLoading ||
              state.status == AuthPresentationStatus.otpRequired)) {
        add(const AuthEvent.sessionCleared());
      }
    });
  }

  final AuthRepository _authRepository;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;
  late final StreamSubscription<AuthSession?> _sessionSubscription;
  final OperationGeneration _presentationOperations = OperationGeneration();

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(
      state.copyWith(
        status: AuthPresentationStatus.submitting,
        isLoading: true,
        failure: null,
        failureOperation: null,
      ),
    );

    late final Result<AuthUser?> result;
    try {
      result = await _authRepository.restoreSession();
    } on AuthMutationSuperseded {
      return;
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: AuthPresentationStatus.unauthenticated,
          isLoading: false,
        ),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }

    result.when(
      success: (user) {
        emit(
          state.copyWith(
            status: user == null
                ? AuthPresentationStatus.unauthenticated
                : AuthPresentationStatus.authenticated,
            user: user,
            isLoading: false,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AuthPresentationStatus.unauthenticated,
            isLoading: false,
            failure: error,
            failureOperation: AuthFailureOperation.restore,
          ),
        );
      },
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final presentationGeneration = _presentationOperations.begin();
    emit(
      state.copyWith(
        status: AuthPresentationStatus.submitting,
        isLoading: true,
        user: null,
        otpChallenge: null,
        failure: null,
        failureOperation: null,
      ),
    );

    late final Result<AuthLoginResult> result;
    try {
      result = await _authRepository.login(
        account: event.account,
        password: event.password,
      );
    } on AuthMutationSuperseded {
      return;
    } catch (error, stackTrace) {
      if (_presentationOperations.isCurrent(presentationGeneration)) {
        emit(
          state.copyWith(
            status: AuthPresentationStatus.unauthenticated,
            isLoading: false,
          ),
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (!_presentationOperations.isCurrent(presentationGeneration)) return;

    result.when(
      success: (authResult) {
        authResult.when(
          authenticated: (authenticated) {
            emit(
              state.copyWith(
                status: AuthPresentationStatus.authenticated,
                isLoading: false,
                user: authenticated.user,
                otpChallenge: null,
              ),
            );
          },
          otpChallenge: (challenge) {
            emit(
              state.copyWith(
                status: AuthPresentationStatus.otpRequired,
                isLoading: false,
                user: null,
                otpChallenge: challenge,
              ),
            );
          },
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AuthPresentationStatus.unauthenticated,
            isLoading: false,
            failure: error,
            failureOperation: AuthFailureOperation.login,
          ),
        );
      },
    );
  }

  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    final challenge = state.otpChallenge;
    if (challenge == null) return;
    final generation = _presentationOperations.begin();
    emit(
      state.copyWith(
        status: AuthPresentationStatus.verifying,
        isLoading: true,
        failure: null,
        failureOperation: null,
      ),
    );
    late final Result<AuthAuthenticatedResult> result;
    try {
      result = await _authRepository.verifyOtp(
        challengeId: challenge.challengeId,
        code: event.code,
      );
    } on AuthMutationSuperseded {
      return;
    } catch (error, stackTrace) {
      if (_presentationOperations.isCurrent(generation) &&
          state.otpChallenge?.challengeId == challenge.challengeId) {
        emit(
          state.copyWith(
            status: AuthPresentationStatus.otpRequired,
            isLoading: false,
          ),
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    if (!_presentationOperations.isCurrent(generation) ||
        state.otpChallenge?.challengeId != challenge.challengeId) {
      return;
    }
    result.when(
      success: (authenticated) => emit(
        state.copyWith(
          status: AuthPresentationStatus.authenticated,
          isLoading: false,
          user: authenticated.user,
          otpChallenge: null,
        ),
      ),
      failure: (failure) => emit(
        state.copyWith(
          status: AuthPresentationStatus.otpRequired,
          isLoading: false,
          failure: failure,
          failureOperation: AuthFailureOperation.verifyOtp,
        ),
      ),
    );
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    final challenge = state.otpChallenge;
    if (challenge == null) return;
    final generation = _presentationOperations.begin();
    emit(
      state.copyWith(
        status: AuthPresentationStatus.resending,
        isLoading: true,
        failure: null,
        failureOperation: null,
      ),
    );
    late final Result<OtpChallenge> result;
    try {
      result = await _authRepository.resendOtp(
        challengeId: challenge.challengeId,
      );
    } on AuthMutationSuperseded {
      return;
    } catch (error, stackTrace) {
      if (_presentationOperations.isCurrent(generation) &&
          state.otpChallenge?.challengeId == challenge.challengeId) {
        emit(
          state.copyWith(
            status: AuthPresentationStatus.otpRequired,
            isLoading: false,
          ),
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    if (!_presentationOperations.isCurrent(generation) ||
        state.otpChallenge?.challengeId != challenge.challengeId) {
      return;
    }
    result.when(
      success: (replacement) => emit(
        state.copyWith(
          status: AuthPresentationStatus.otpRequired,
          isLoading: false,
          otpChallenge: replacement,
        ),
      ),
      failure: (failure) => emit(
        state.copyWith(
          status: AuthPresentationStatus.otpRequired,
          isLoading: false,
          failure: failure,
          failureOperation: AuthFailureOperation.resendOtp,
        ),
      ),
    );
  }

  void _onSessionCleared(AuthSessionCleared event, Emitter<AuthState> emit) {
    // Authoritative Session clear 必須同時讓 presentation completion 與仍在執行的
    // repository mutation lease 失效，避免舊 login / OTP 結果復活 UI state。
    _presentationOperations.invalidate();
    _mutationCoordinator.invalidateMutationLeases();
    emit(AuthState.initial());
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthPresentationStatus.submitting,
        isLoading: true,
        failure: null,
        failureOperation: null,
      ),
    );

    late final Result<void> result;
    try {
      result = await _authRepository.logout();
    } on AuthMutationSuperseded {
      return;
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: AuthPresentationStatus.unauthenticated,
          isLoading: false,
        ),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }

    result.when(
      success: (_) {
        emit(AuthState.initial());
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: state.isAuthenticated
                ? AuthPresentationStatus.authenticated
                : AuthPresentationStatus.unauthenticated,
            isLoading: false,
            failure: error,
            failureOperation: AuthFailureOperation.logout,
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
