import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// Profile Entity。
///
/// 代表 App 畫面真正需要的使用者資料。
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
  }) = _Profile;
}
