part of 'profile_bloc.dart';

/// ProfileBloc 可接收的事件。
@freezed
class ProfileEvent with _$ProfileEvent {
  /// 讀取目前登入者 Profile。
  const factory ProfileEvent.requested() = ProfileRequested;
}
