import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('local_auth Android native contract符合官方setup', () {
    final root = Directory.current.path;
    final pubspec = File('$root/pubspec.yaml').readAsStringSync();
    final manifest = File(
      '$root/android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final activity = File(
      '$root/android/app/src/main/kotlin/com/example/flutterarchitecture/MainActivity.kt',
    ).readAsStringSync();
    final lightStyles = File(
      '$root/android/app/src/main/res/values/styles.xml',
    ).readAsStringSync();
    final darkStyles = File(
      '$root/android/app/src/main/res/values-night/styles.xml',
    ).readAsStringSync();

    expect(pubspec, contains('local_auth: ^3.0.2'));
    expect(
      activity,
      contains('import io.flutter.embedding.android.FlutterFragmentActivity'),
    );
    expect(activity, contains('class MainActivity : FlutterFragmentActivity()'));
    expect(manifest, contains('android.permission.USE_BIOMETRIC'));
    expect(manifest, isNot(contains('android.permission.USE_FINGERPRINT')));
    expect(
      lightStyles,
      contains(
        'name="LaunchTheme" parent="Theme.AppCompat.DayNight.NoActionBar"',
      ),
    );
    expect(
      darkStyles,
      contains(
        'name="LaunchTheme" parent="Theme.AppCompat.DayNight.NoActionBar"',
      ),
    );
  });
}
