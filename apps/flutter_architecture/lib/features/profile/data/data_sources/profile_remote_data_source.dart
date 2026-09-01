import 'package:api_client/api_client_infrastructure.dart';

/// Profile 遠端資料來源。
///
/// 負責呼叫 Profile API abstraction，並在 transport boundary 將已知 HTTP
/// exception 映射為共用 AppException。
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._profileApi);

  final ProfileApi _profileApi;

  Future<ProfileResponseDto> getProfile() async {
    try {
      return await _profileApi.getProfile();
    } catch (error, stackTrace) {
      rethrowMappedTransportException(error, stackTrace);
    }
  }
}
