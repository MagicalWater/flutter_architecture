part of 'profile_bloc.dart';

/// Profile 畫面發生錯誤時，標記當時正在做哪個動作。
enum ProfileFailureOperation {
  /// 載入會員資料失敗。
  load,

  /// 登出失敗。
  logout,
}

/// Profile 畫面需要的完整狀態。
///
/// [failureOperation] 用來區分「資料載入失敗」與「登出失敗」，避免畫面只能顯示
/// 一個不知道從哪裡來的 [failure]。
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
