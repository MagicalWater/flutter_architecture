part of 'profile_bloc.dart';

enum ProfileFailureOperation { load, logout }

/// ProfileBloc 的 UI 狀態。
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required bool isLoading,
    required bool isAuthenticated,
    required bool logoutSucceeded,
    required Profile? profile,
    required Failure? failure,
    required ProfileFailureOperation? failureOperation,
  }) = _ProfileState;

  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      isAuthenticated: false,
      logoutSucceeded: false,
      profile: null,
      failure: null,
      failureOperation: null,
    );
  }
}
