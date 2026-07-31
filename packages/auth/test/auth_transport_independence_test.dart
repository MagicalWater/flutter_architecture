import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth package source, tests, and pubspec do not depend on Dio', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final dartFiles = <File>[
      ...Directory('lib').listSync(recursive: true).whereType<File>(),
      ...Directory('test').listSync(recursive: true).whereType<File>(),
    ].where(
      (file) =>
          file.path.endsWith('.dart') &&
          !file.path.endsWith('auth_transport_independence_test.dart'),
    ).toList();

    expect(pubspec, isNot(contains(RegExp(r'^\s+dio:', multiLine: true))));
    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('package:dio/dio.dart')),
        reason: file.path,
      );
      expect(source, isNot(contains('DioException')), reason: file.path);
      expect(source, isNot(contains('DioExceptionType')), reason: file.path);
    }
  });

  test('auth data sources consume transport-neutral endpoint interfaces', () {
    final authSource = File(
      'lib/src/data/data_sources/auth_remote_data_source.dart',
    ).readAsStringSync();
    final refreshSource = File(
      'lib/src/data/data_sources/auth_refresh_remote_data_source.dart',
    ).readAsStringSync();

    expect(authSource, contains('final AuthEndpoint _authEndpoint;'));
    expect(refreshSource, contains('final AuthRefreshEndpoint _endpoint;'));
  });
}
