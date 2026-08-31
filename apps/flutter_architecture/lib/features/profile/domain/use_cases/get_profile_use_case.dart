import 'package:core/core.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/domain/repositories/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// 取得目前登入者 Profile。
///
/// ## Runtime Flow
///
/// ```txt
/// ProfilePage
///   ↓
/// ProfileBloc
///   ↓
/// GetProfileUseCase
///   ↓
/// ProfileRepository
/// ```
@injectable
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<Profile>> execute() {
    return _repository.getProfile();
  }
}
