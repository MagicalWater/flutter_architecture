import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_architecture/features/profile/presentation/profile_failure_localization.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps profile 401 to localized expired-session copy', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh', 'TW'));
    const failure = Failure(code: '401', message: 'diagnostic only');

    expect(
      localizedProfileFailure(
        l10n,
        failure: failure,
        operation: ProfileFailureOperation.load,
      ),
      '登入狀態已失效，請重新登入。',
    );
  });

  test('does not treat profile 403 as an expired session', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    const failure = Failure(code: '403', message: 'forbidden diagnostic');

    expect(
      localizedProfileFailure(
        l10n,
        failure: failure,
        operation: ProfileFailureOperation.load,
      ),
      'Unable to load the profile. Please try again.',
    );
  });

  test('uses operation-specific generic fallback for unknown codes', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    const failure = Failure(code: '599', message: 'technical detail');

    expect(
      localizedProfileFailure(
        l10n,
        failure: failure,
        operation: ProfileFailureOperation.load,
      ),
      'Unable to load the profile. Please try again.',
    );
    expect(
      localizedProfileFailure(
        l10n,
        failure: failure,
        operation: ProfileFailureOperation.logout,
      ),
      'Unable to log out. Please try again.',
    );
  });
}
