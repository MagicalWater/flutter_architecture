import 'package:flutter_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result.freezed.dart';

/// 登入成功後 Domain Layer 使用的結果。
///
/// token 會被 Repository 寫入 local storage，
/// 但 AuthBloc 仍需要知道目前登入者是誰。
@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult({
    required String accessToken,
    required AuthUser user,
  }) = _AuthResult;
}
