import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Domain Layer 的使用者 Entity。
///
/// ## 為什麼不是 API Response？
///
/// Entity 是 App 業務真正需要的資料。
///
/// API Response 可能有很多後端欄位，但 UI / UseCase 不一定需要。
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String name,
  }) = _AuthUser;
}
