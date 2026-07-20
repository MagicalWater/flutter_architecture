import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Secure Storage dependency與Android安全contract保持一致', () {
    final root = Directory.current.path;
    final pubspec = File('$root/pubspec.yaml').readAsStringSync();
    final buildFile = File(
      '$root/android/app/build.gradle.kts',
    ).readAsStringSync();
    final manifest = File(
      '$root/android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(pubspec, contains('flutter_secure_storage: ^10.3.1'));
    expect(buildFile, contains('minSdk = maxOf(flutter.minSdkVersion, 23)'));
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, isNot(contains('android.permission.USE_BIOMETRIC')));
    expect(manifest, isNot(contains('android.permission.USE_FINGERPRINT')));
  });
}
