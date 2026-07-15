import 'package:api_client/src/api/profile_retrofit_api.dart';
import 'package:api_client/src/models/profile_response_dto.dart';

/// Profile API 的 Mock implementation。
class MockProfileApi implements ProfileApi {
  const MockProfileApi();

  @override
  Future<ProfileResponseDto> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return const ProfileResponseDto(
      id: 'user-001',
      name: 'Water Magical',
    );
  }
}
