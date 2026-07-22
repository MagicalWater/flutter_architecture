import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS scaffold固定原生識別與工具鏈契約', () {
    final root = Directory.current.path;
    final podfile = File('$root/ios/Podfile').readAsStringSync();
    final project = File(
      '$root/ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    final infoPlist = File('$root/ios/Runner/Info.plist').readAsStringSync();

    expect(podfile, contains("platform :ios, '13.0'"));
    expect(
      RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = 13\.0;')
          .allMatches(project)
          .length,
      greaterThanOrEqualTo(3),
    );
    expect(
      project,
      contains('PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterarchitecture;'),
    );
    expect(
      project,
      contains(
        'PRODUCT_BUNDLE_IDENTIFIER = '
        'com.example.flutterarchitecture.RunnerTests;',
      ),
    );
    expect(project, contains('PRODUCT_NAME = "Flutter Architecture";'));
    expect(
      RegExp(r'SWIFT_VERSION = 5\.0;').allMatches(project).length,
      greaterThanOrEqualTo(6),
    );
    expect(infoPlist, contains('<string>Flutter Architecture</string>'));
    expect(project, isNot(contains('DEVELOPMENT_TEAM =')));
    expect(project, isNot(contains('PROVISIONING_PROFILE_SPECIFIER')));
    expect(project, isNot(contains('PROVISIONING_PROFILE =')));
  });
}
