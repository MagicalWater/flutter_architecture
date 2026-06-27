part of 'profile_bloc.dart';

/// ProfileBloc 可接收的事件。
@freezed
class ProfileEvent with _$ProfileEvent {
  /// 讀取目前登入者 Profile。
  const factory ProfileEvent.requested() = ProfileRequested;

  /// 使用者從 Profile 頁面按下登出。
  const factory ProfileEvent.logoutRequested() = ProfileLogoutRequested;
}
