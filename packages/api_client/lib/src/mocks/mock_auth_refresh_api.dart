import 'package:api_client/src/endpoints/auth_refresh_endpoint.dart';
import 'package:api_client/src/models/refresh_token_request_dto.dart';
import 'package:api_client/src/models/refresh_token_response_dto.dart';

/// Refresh endpoint 的 deterministic mock；只模擬 transport contract，不持有 Auth lifecycle。
class MockAuthRefreshApi implements AuthRefreshEndpoint {
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
