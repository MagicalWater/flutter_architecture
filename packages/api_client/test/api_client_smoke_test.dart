import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  test('AuthApiClient.login 會回傳 mock token 與使用者資料', () async {
    final client = AuthApiClient();

    final response = await client.login(
      account: 'demo',
      password: 'password',
    );

    expect(response.accessToken, isNotEmpty);
    expect(response.userName, 'Water Magical');
  });
}
