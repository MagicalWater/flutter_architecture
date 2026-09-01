import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/domain/repositories/profile_repository.dart';
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
/// ProfileBloc
///   ↓
/// ProfileRepository / AuthRepository
///   ↓
/// Repository / SessionManager
/// ```
///
/// ProfileBloc 不直接呼叫 ProfileApi，也不直接依賴 AuthBloc。
///
/// 是否已登入由 SessionManager 判斷，登出則透過 AuthRepository 執行。
@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._profileRepository,
    this._authRepository,
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

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
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
          failure: null,
          failureOperation: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        isAuthenticated: true,
        logoutSucceeded: false,
        failure: null,
        failureOperation: null,
      ),
    );

    late final Result<Profile> result;
    try {
      result = await _profileRepository.getProfile();
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoading: false));
      Error.throwWithStackTrace(error, stackTrace);
    }

    final currentSession = _sessionManager.currentSession;
    // Profile response 只屬於 request 發出時的 Session lifecycle；logout / relogin
    // 後即使 userId 相同也不能讓舊 response commit 到新的 presentation state。
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
            failure: error,
            failureOperation: ProfileFailureOperation.load,
          ),
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, failure: null, failureOperation: null),
    );

    late final Result<void> result;
    try {
      result = await _authRepository.logout();
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoading: false));
      Error.throwWithStackTrace(error, stackTrace);
    }

    result.when(
      success: (_) {
        emit(ProfileState.initial().copyWith(logoutSucceeded: true));
      },
      failure: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            failure: error,
            failureOperation: ProfileFailureOperation.logout,
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
      emit(ProfileState.initial().copyWith(isAuthenticated: true));
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
