import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/auth/presentation/auth_failure_localization.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps login 401 and hides diagnostic message', () async {
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final chinese = await AppLocalizations.delegate.load(
      const Locale('zh', 'TW'),
    );
    const failure = Failure(
      httpStatus: 401,
      message: 'server diagnostic must not reach UI',
    );

    expect(
      localizedAuthFailure(
        english,
        failure: failure,
        operation: AuthFailureOperation.login,
      ),
      'The account or password is incorrect.',
    );
    expect(
      localizedAuthFailure(
        chinese,
        failure: failure,
        operation: AuthFailureOperation.login,
      ),
      '帳號或密碼不正確。',
    );
  });

  test('does not treat login 403 as invalid credentials', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    const failure = Failure(
      httpStatus: 403,
      message: 'account may be forbidden',
    );

    expect(
      localizedAuthFailure(
        l10n,
        failure: failure,
        operation: AuthFailureOperation.login,
      ),
      'Unable to log in. Please try again.',
    );
  });

  test(
    'uses operation-specific localized fallback for unknown codes',
    () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      const failure = Failure(httpStatus: 599, message: 'technical detail');

      expect(
        localizedAuthFailure(
          l10n,
          failure: failure,
          operation: AuthFailureOperation.restore,
        ),
        'Unable to restore the previous session.',
      );
      expect(
        localizedAuthFailure(
          l10n,
          failure: failure,
          operation: AuthFailureOperation.logout,
        ),
        'Unable to log out. Please try again.',
      );
    },
  );
}
