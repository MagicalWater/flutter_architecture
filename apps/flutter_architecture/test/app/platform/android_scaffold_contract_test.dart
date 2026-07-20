import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android scaffold固定application與native baseline contract', () {
    final root = Directory.current.path;
    final buildFile = File('$root/android/app/build.gradle.kts').readAsStringSync();
    final manifest = File(
      '$root/android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final activity = File(
      '$root/android/app/src/main/kotlin/com/example/flutterarchitecture/MainActivity.kt',
    ).readAsStringSync();

    expect(buildFile, contains('applicationId = "com.example.flutterarchitecture"'));
    expect(buildFile, contains('minSdk = maxOf(flutter.minSdkVersion, 23)'));
    expect(buildFile, contains('targetSdk = flutter.targetSdkVersion'));
    expect(manifest, contains('android.permission.INTERNET'));
    expect(manifest, contains('android:value="2"'));
    expect(activity, contains('class MainActivity : FlutterActivity()'));
  });
}
