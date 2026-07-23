import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/observability/release_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReleaseIdentity保留native package metadata與optional commit SHA', () {
    final identity = ReleaseIdentity(
      environment: AppEnvironment.staging,
      version: '1.8.0',
      buildNumber: '42',
      platform: ReleasePlatform.android,
      nativeConfiguration: 'staging',
      commitSha: 'abc123',
    );

    expect(identity.environment, AppEnvironment.staging);
    expect(identity.version, '1.8.0');
    expect(identity.buildNumber, '42');
    expect(identity.platform, ReleasePlatform.android);
    expect(identity.nativeConfiguration, 'staging');
    expect(identity.commitSha, 'abc123');
  });

  test('ReleaseIdentity拒絕空白必填欄位與空白commit SHA', () {
    expect(
      () => ReleaseIdentity(
        environment: AppEnvironment.production,
        version: ' ',
        buildNumber: '1',
        platform: ReleasePlatform.ios,
        nativeConfiguration: 'Production',
      ),
      throwsArgumentError,
    );
    expect(
      () => ReleaseIdentity(
        environment: AppEnvironment.production,
        version: '1.8.0',
        buildNumber: '1',
        platform: ReleasePlatform.ios,
        nativeConfiguration: 'Production',
        commitSha: ' ',
      ),
      throwsArgumentError,
    );
  });

  test('ReleaseIdentity toString不展開commit SHA', () {
    final identity = ReleaseIdentity(
      environment: AppEnvironment.production,
      version: '1.8.0',
      buildNumber: '1',
      platform: ReleasePlatform.ios,
      nativeConfiguration: 'Production',
      commitSha: 'secret-build-reference',
    );

    expect(identity.toString(), isNot(contains('secret-build-reference')));
    expect(identity.toString(), contains('hasCommitSha: true'));
  });
}
