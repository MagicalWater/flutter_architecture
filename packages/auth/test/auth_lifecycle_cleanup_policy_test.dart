import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

const _accessSentinel = 'M19_ACCESS_SECRET_7f4a';
const _refreshSentinel = 'M19_REFRESH_SECRET_2c91';
const _passwordSentinel = 'M19_PASSWORD_SECRET_11de';
const _pluginSentinel = 'M19_PLUGIN_SECRET_a63b';

void main() {
  test('cleanup attempts secure legacy and user in order', () async {
    final operations = <String>[];
    final policy = AuthLifecycleCleanupPolicy(
      secureCredentialStore: _CredentialStore(operations),
      legacyCredentialStore: _LegacyStore(operations),
      userStore: _UserStore(operations),
    );

    final result = await policy.clearAllUnlocked();

    expect(result.isSuccess, isTrue);
    expect(result.diagnostics, isEmpty);
    expect(operations, <String>['secure', 'legacy', 'user']);
  });

  test('unknown error outranks expected local storage error', () async {
    final expected = AppException(
      kind: AppExceptionKind.localStorage,
      message: 'secure unavailable',
    );
    final expectedStack = StackTrace.current;
    final unknown = StateError('legacy bug');
    final unknownStack = StackTrace.current;
    final operations = <String>[];
    final policy = AuthLifecycleCleanupPolicy(
      secureCredentialStore: _CredentialStore(
        operations,
        error: expected,
        stackTrace: expectedStack,
      ),
      legacyCredentialStore: _LegacyStore(
        operations,
        error: unknown,
        stackTrace: unknownStack,
      ),
      userStore: _UserStore(operations),
    );

    final result = await policy.clearAllUnlocked();

    expect(operations, <String>['secure', 'legacy', 'user']);
    expect(result.diagnostics, hasLength(2));
    expect(
      result.diagnostics[0].operation,
      AuthLifecycleDiagnosticOperation.secureCleanup,
    );
    expect(result.diagnostics[0].error, same(expected));
    expect(result.diagnostics[0].stackTrace, same(expectedStack));
    expect(
      result.diagnostics[1].operation,
      AuthLifecycleDiagnosticOperation.legacyCleanup,
    );
    expect(result.diagnostics[1].error, same(unknown));
    expect(result.diagnostics[1].stackTrace, same(unknownStack));

    try {
      result.throwIfFailed();
      fail('Expected cleanup failure');
    } catch (error, stackTrace) {
      expect(error, same(unknown));
      expect(stackTrace, same(unknownStack));
    }
  });

  test(
    'passive caller may report expected errors but rethrow unknown',
    () async {
      final expected = AppException(
        kind: AppExceptionKind.localStorage,
        message: 'user unavailable',
      );
      final policy = AuthLifecycleCleanupPolicy(
        secureCredentialStore: _CredentialStore(<String>[]),
        legacyCredentialStore: _LegacyStore(<String>[]),
        userStore: _UserStore(<String>[], error: expected),
      );

      final result = await policy.clearAllUnlocked();

      expect(result.hasUnexpectedFailure, isFalse);
      expect(() => result.throwIfUnexpected(), returnsNormally);
      expect(() => result.throwIfFailed(), throwsA(same(expected)));
    },
  );

  test('diagnostic toString does not expose plugin message', () {
    final diagnostic = AuthLifecycleDiagnostic(
      operation: AuthLifecycleDiagnosticOperation.userCleanup,
      error: StateError('plugin-secret'),
      stackTrace: StackTrace.current,
    );

    expect(diagnostic.toString(), isNot(contains('plugin-secret')));
  });

  test('cleanup result and diagnostics hide unified credential sentinels', () {
    final diagnostic = AuthLifecycleDiagnostic(
      operation: AuthLifecycleDiagnosticOperation.secureCleanup,
      error: StateError(
        '$_pluginSentinel $_accessSentinel $_refreshSentinel $_passwordSentinel',
      ),
      stackTrace: StackTrace.fromString(_pluginSentinel),
    );
    final result = AuthLifecycleCleanupResult(<AuthLifecycleDiagnostic>[
      diagnostic,
    ]);

    for (final value in <Object>[diagnostic, result]) {
      _expectNoCredentialSentinel(value.toString());
    }
  });

  test('cleanup diagnostics are immutable', () async {
    final policy = AuthLifecycleCleanupPolicy(
      secureCredentialStore: _CredentialStore(
        <String>[],
        error: StateError('secure failure'),
      ),
      legacyCredentialStore: _LegacyStore(<String>[]),
      userStore: _UserStore(<String>[]),
    );

    final result = await policy.clearAllUnlocked();

    expect(
      () => result.diagnostics.add(
        AuthLifecycleDiagnostic(
          operation: AuthLifecycleDiagnosticOperation.userCleanup,
          error: StateError('injected'),
          stackTrace: StackTrace.current,
        ),
      ),
      throwsUnsupportedError,
    );
  });
}

void _expectNoCredentialSentinel(String text) {
  expect(text, isNot(contains(_accessSentinel)));
  expect(text, isNot(contains(_refreshSentinel)));
  expect(text, isNot(contains(_passwordSentinel)));
  expect(text, isNot(contains(_pluginSentinel)));
}

base class _ClearStore {
  _ClearStore(this.operations, this.name, {this.error, this.stackTrace});

  final List<String> operations;
  final String name;
  final Object? error;
  final StackTrace? stackTrace;

  Future<void> clear() async {
    operations.add(name);
    final failure = error;
    if (failure != null) {
      Error.throwWithStackTrace(failure, stackTrace ?? StackTrace.current);
    }
  }
}

final class _CredentialStore extends _ClearStore
    implements AuthCredentialStore {
  _CredentialStore(
    List<String> operations, {
    Object? error,
    StackTrace? stackTrace,
  }) : super(operations, 'secure', error: error, stackTrace: stackTrace);

  @override
  Future<void> clearCredential() => clear();
  @override
  Future<AuthCredentialReadResult> readCredential() async =>
      const AuthCredentialReadAbsent();
  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {}
}

final class _LegacyStore extends _ClearStore
    implements AuthLegacyCredentialStore {
  _LegacyStore(List<String> operations, {Object? error, StackTrace? stackTrace})
    : super(operations, 'legacy', error: error, stackTrace: stackTrace);

  @override
  Future<void> clearLegacyCredential() => clear();
  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async =>
      const AuthCredentialReadAbsent();
}

final class _UserStore extends _ClearStore implements AuthUserStore {
  _UserStore(List<String> operations, {Object? error, StackTrace? stackTrace})
    : super(operations, 'user', error: error, stackTrace: stackTrace);

  @override
  Future<void> clearUser() => clear();
  @override
  Future<AuthUser?> readUser() async => null;
  @override
  Future<void> writeUser(AuthUser user) async {}
}
