import 'dart:convert';
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
    final environmentConfigs = [
      'development',
      'staging',
      'production',
    ].map(
      (environment) => File(
        '$root/ios/Flutter/Debug-$environment.xcconfig',
      ).readAsStringSync(),
    );

    expect(podfile, contains("platform :ios, '13.0'"));
    expect(
      RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = 13\.0;')
          .allMatches(project)
          .length,
      greaterThanOrEqualTo(3),
    );
    expect(
      environmentConfigs.join('\n'),
      contains('PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterarchitecture'),
    );
    expect(
      project,
      contains(
        'PRODUCT_BUNDLE_IDENTIFIER = '
        'com.example.flutterarchitecture.RunnerTests;',
      ),
    );
    expect(environmentConfigs.join('\n'), contains('APP_DISPLAY_NAME = Flutter Architecture'));
    expect(
      RegExp(r'SWIFT_VERSION = 5\.0;').allMatches(project).length,
      greaterThanOrEqualTo(6),
    );
    expect(infoPlist, contains(r'<string>$(APP_DISPLAY_NAME)</string>'));
    expect(project, isNot(contains('DEVELOPMENT_TEAM =')));
    expect(project, isNot(contains('PROVISIONING_PROFILE_SPECIFIER')));
    expect(project, isNot(contains('PROVISIONING_PROFILE =')));
  });

  test('iOS native plugins固定Face ID與Keychain契約', () {
    final root = Directory.current.path;
    final infoPlist = File('$root/ios/Runner/Info.plist').readAsStringSync();
    final project = File(
      '$root/ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    final debugProfileEntitlements = File(
      '$root/ios/Runner/DebugProfile.entitlements',
    ).readAsStringSync();
    final releaseEntitlements = File(
      '$root/ios/Runner/Release.entitlements',
    ).readAsStringSync();
    final registrant = File(
      '$root/ios/Runner/GeneratedPluginRegistrant.m',
    ).readAsStringSync();
    final pluginDependencies = jsonDecode(
      File('$root/.flutter-plugins-dependencies').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(infoPlist, contains('<key>NSFaceIDUsageDescription</key>'));
    expect(
      infoPlist,
      contains(
        '<string>Use Face ID to verify the current user before unlocking '
        'the local signed-in session.</string>',
      ),
    );

    for (final entitlements in [
      debugProfileEntitlements,
      releaseEntitlements,
    ]) {
      expect(entitlements, contains('<key>keychain-access-groups</key>'));
      expect(
        entitlements,
        contains(
          r'<string>$(AppIdentifierPrefix)$(CFBundleIdentifier)</string>',
        ),
      );
      expect(entitlements, isNot(contains('com.apple.security.application-groups')));
      expect(entitlements, isNot(contains('aps-environment')));
    }

    expect(
      RegExp(r'CODE_SIGN_ENTITLEMENTS = Runner/DebugProfile\.entitlements;')
          .allMatches(project)
          .length,
      6,
    );
    expect(
      RegExp(r'CODE_SIGN_ENTITLEMENTS = Runner/Release\.entitlements;')
          .allMatches(project)
          .length,
      3,
    );

    for (final plugin in [
      'FlutterSecureStorageDarwinPlugin',
      'LocalAuthPlugin',
      'SharedPreferencesPlugin',
      'SqflitePlugin',
    ]) {
      expect(registrant, contains('$plugin registerWithRegistrar'));
    }

    final iosPlugins = ((pluginDependencies['plugins'] as Map<String, dynamic>)['ios']
            as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final pathProvider = iosPlugins.singleWhere(
      (plugin) => plugin['name'] == 'path_provider_foundation',
    );
    expect(pathProvider['native_build'], isFalse);
    expect(registrant, isNot(contains('PathProviderPlugin')));
  });

  test('repository提供environment-aware unsigned iOS build scripts', () {
    final root = Directory.current.path;
    final compatibilityScript = File(
      '$root/../../tools/ci/build_ios_simulator.sh',
    ).readAsStringSync();
    final developmentScript = File(
      '$root/../../tools/ci/build_ios_development.sh',
    ).readAsStringSync();
    final productionScript = File(
      '$root/../../tools/ci/build_ios_production.sh',
    ).readAsStringSync();
    final environmentScript = File(
      '$root/../../tools/ci/build_ios_environment.sh',
    ).readAsStringSync();

    expect(compatibilityScript, contains('build_ios_development.sh'));
    expect(
      developmentScript,
      contains(
        'development Development Debug-development iphonesimulator '
        'lib/main_development.dart mock',
      ),
    );
    expect(
      productionScript,
      contains(
        'production Production Release-production iphoneos '
        'lib/main_production.dart real',
      ),
    );
    expect(productionScript, isNot(contains('lib/main.dart')));
    expect(environmentScript, contains('flutter pub get'));
    expect(environmentScript, contains('pod install'));
    expect(environmentScript, contains('CODE_SIGNING_ALLOWED=NO'));
    expect(environmentScript, contains('plutil -extract CFBundleIdentifier'));
    expect(environmentScript, contains('distribution=not production-ready'));
  });
}
