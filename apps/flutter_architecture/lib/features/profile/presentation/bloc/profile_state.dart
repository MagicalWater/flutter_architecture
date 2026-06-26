part of 'profile_bloc.dart';

/// ProfileBloc 的 UI 狀態。
@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required bool isLoading,
    required Profile? profile,
    required String? errorMessage,
  }) = _ProfileState;

  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      profile: null,
      errorMessage: null,
    );
  }
}
