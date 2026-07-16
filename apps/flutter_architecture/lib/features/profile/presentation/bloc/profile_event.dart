part of 'profile_bloc.dart';

/// ProfileBloc 可接收的事件。
@freezed
sealed class ProfileEvent with _$ProfileEvent {
  /// 讀取目前登入者 Profile。
  const factory ProfileEvent.requested() = ProfileRequested;

  /// 使用者從 Profile 頁面按下登出。
  const factory ProfileEvent.logoutRequested() = ProfileLogoutRequested;

  /// Refresh credential 失效或其他 feature 清除 Session 時同步 UI。
  const factory ProfileEvent.sessionCleared() = ProfileSessionCleared;
}
