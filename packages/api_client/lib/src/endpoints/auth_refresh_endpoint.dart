import 'package:api_client/src/models/refresh_token_request_dto.dart';
import 'package:api_client/src/models/refresh_token_response_dto.dart';

/// Refresh consumer-facing endpoint boundary。
abstract interface class AuthRefreshEndpoint {
  Future<RefreshTokenResponseDto> refresh(
    RefreshTokenRequestDto request,
  );
}
