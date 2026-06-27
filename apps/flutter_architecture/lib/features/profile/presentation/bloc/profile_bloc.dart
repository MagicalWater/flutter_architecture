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
/// 它不直接呼叫 ProfileApiClient，而是透過 GetProfileUseCase。
@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._getProfileUseCase,
    this._logoutUseCase,
    this._sessionManager,
  ) : super(ProfileState.initial()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final SessionManager _sessionManager;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (!_sessionManager.isAuthenticated) {
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
}
