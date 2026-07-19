import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Auth login event does not expose credentials in toString', () {
    const event = AuthEvent.loginRequested(
      account: 'sensitive-account',
      password: 'sensitive-password',
    );

    final output = event.toString();

    expect(output, isNot(contains('sensitive-account')));
    expect(output, isNot(contains('sensitive-password')));
  });
}
