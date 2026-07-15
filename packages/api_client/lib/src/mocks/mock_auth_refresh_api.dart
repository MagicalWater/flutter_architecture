import 'package:api_client/src/api/auth_refresh_retrofit_api.dart';
import 'package:api_client/src/models/refresh_token_request_dto.dart';
import 'package:api_client/src/models/refresh_token_response_dto.dart';

class MockAuthRefreshApi implements AuthRefreshApi {
  const MockAuthRefreshApi();

  @override
  Future<RefreshTokenResponseDto> refresh(
    RefreshTokenRequestDto request,
  ) async {
    return const RefreshTokenResponseDto(
      accessToken: 'mock-refreshed-access-token',
      refreshToken: 'mock-rotated-refresh-token',
    );
  }
}
