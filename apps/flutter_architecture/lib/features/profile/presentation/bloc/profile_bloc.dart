import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'profile_bloc.freezed.dart';
part 'profile_event.dart';
part 'profile_state.dart';

/// Profile 頁面的狀態管理。
///
/// ## Runtime Flow
///
/// ```txt
/// ProfilePage
///   ↓ add(ProfileRequested / ProfileLogoutRequested)
/// ProfileBloc  ← 目前所在位置
///   ↓
/// GetProfileUseCase / LogoutUseCase
///   ↓
/// Repository / SessionManager
/// ```
///
/// ProfileBloc 不直接呼叫 ProfileApi，也不直接依賴 AuthBloc。
///
/// 是否已登入由 SessionManager 判斷，登出則透過 LogoutUseCase 執行。
@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._getProfileUseCase,
    this._logoutUseCase,
    this._sessionManager,
  ) : super(ProfileState.initial()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileLogoutRequested>(_onLogoutRequested);
    on<ProfileSessionCleared>(_onSessionCleared);

    _sessionSubscription = _sessionManager.sessionStream.listen((session) {
      if (session == null && state.isAuthenticated) {
        add(const ProfileEvent.sessionCleared());
      }
    });
  }

  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final SessionManager _sessionManager;
  late final StreamSubscription<AuthSession?> _sessionSubscription;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final requestSession = _sessionManager.currentSession;
    if (requestSession == null) {
      emit(
        state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          logoutSucceeded: false,
          profile: null,
          errorMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        isAuthenticated: true,
        logoutSucceeded: false,
        errorMessage: null,
      ),
    );

    final result = await _getProfileUseCase.execute();

    final currentSession = _sessionManager.currentSession;
    if (currentSession == null ||
        currentSession.generation != requestSession.generation ||
        currentSession.userId != requestSession.userId) {
      if (!_sessionManager.isAuthenticated) {
        emit(ProfileState.initial());
      }
      return;
    }

    result.when(
      success: (profile) {
        emit(
          state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            profile: profile,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _logoutUseCase.execute();

    result.when(
      success: (_) {
        emit(
          ProfileState.initial().copyWith(logoutSucceeded: true),
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
    ProfileSessionCleared event,
    Emitter<ProfileState> emit,
  ) {
    if (_sessionManager.isAuthenticated) {
      emit(
        ProfileState.initial().copyWith(
          isAuthenticated: true,
        ),
      );
      add(const ProfileEvent.requested());
      return;
    }
    emit(ProfileState.initial());
  }

  @override
  Future<void> close() async {
    await _sessionSubscription.cancel();
    return super.close();
  }
}
