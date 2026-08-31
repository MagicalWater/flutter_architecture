import 'package:auth/auth.dart';
import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Auth user string representations do not expose PII fields', () {
    const user = AuthUser(id: 'private-user-id', name: 'Private Name');
    const model = AuthUserModel(id: 'private-user-id', name: 'Private Name');

    for (final value in <Object>[user, model]) {
      final text = value.toString();
      expect(text, isNot(contains('private-user-id')));
      expect(text, isNot(contains('Private Name')));
    }
  });
}
