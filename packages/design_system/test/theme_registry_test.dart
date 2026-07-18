import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final defaultId = DsThemeId('default');
  final oceanId = DsThemeId('ocean');

  group('DsThemeRegistry', () {
    test('Theme ID 使用 canonical lowercase contract', () {
      expect(DsThemeId('default'), DsThemeId('default'));
      expect(DsThemeId('default').hashCode, DsThemeId('default').hashCode);
      expect(() => DsThemeId(''), throwsArgumentError);
      expect(() => DsThemeId('   '), throwsArgumentError);
      expect(() => DsThemeId(' default'), throwsArgumentError);
      expect(() => DsThemeId('default '), throwsArgumentError);
      expect(() => DsThemeId('Default'), throwsArgumentError);
      expect(() => DsThemeId('default.theme'), throwsArgumentError);
      expect(DsThemeId('brand_v2'), DsThemeId('brand_v2'));
      expect(DsThemeId('brand-v2'), DsThemeId('brand-v2'));
    });

    test('Theme metadata 會拒絕空白 display name', () {
      expect(
        () => DsThemeMetadata(id: defaultId, displayName: ''),
        throwsArgumentError,
      );
      expect(
        () => DsThemeMetadata(id: defaultId, displayName: '   '),
        throwsArgumentError,
      );
    });

    test('會拒絕空的 definitions', () {
      expect(
        () => DsThemeRegistry(
          definitions: <DsThemeDefinition>[],
          defaultThemeId: defaultId,
        ),
        throwsArgumentError,
      );
    });

    test('會拒絕不存在的 default theme', () {
      expect(
        () => DsThemeRegistry(
          definitions: <DsThemeDefinition>[
            _FakeThemeDefinition(id: oceanId, name: 'Ocean'),
          ],
          defaultThemeId: defaultId,
        ),
        throwsArgumentError,
      );
    });

    test('會拒絕重複 Theme ID', () {
      expect(
        () => DsThemeRegistry(
          definitions: <DsThemeDefinition>[
            _FakeThemeDefinition(id: defaultId, name: 'Default A'),
            _FakeThemeDefinition(id: defaultId, name: 'Default B'),
          ],
          defaultThemeId: defaultId,
        ),
        throwsArgumentError,
      );
    });

    test('會拒絕 definition ID 與 metadata ID 不一致', () {
      expect(
        () => DsThemeRegistry(
          definitions: <DsThemeDefinition>[
            _MismatchedThemeDefinition(id: defaultId, metadataId: oceanId),
          ],
          defaultThemeId: defaultId,
        ),
        throwsArgumentError,
      );
    });

    test('未知 Theme ID 會 fallback 至 default theme', () {
      final registry = DsThemeRegistry(
        definitions: <DsThemeDefinition>[
          _FakeThemeDefinition(id: defaultId, name: 'Default'),
          _FakeThemeDefinition(id: oceanId, name: 'Ocean'),
        ],
        defaultThemeId: defaultId,
      );

      final resolved = registry.resolve(DsThemeId('removed'));

      expect(resolved.id, defaultId);
      expect(resolved.metadata.displayName, 'Default');
    });

    test('可列出 metadata 並建立 Light / Dark ThemeData', () {
      final registry = DsThemeRegistry(
        definitions: <DsThemeDefinition>[
          _FakeThemeDefinition(id: defaultId, name: 'Default'),
          _FakeThemeDefinition(id: oceanId, name: 'Ocean'),
        ],
        defaultThemeId: defaultId,
      );

      expect(
        registry.availableThemes.map((metadata) => metadata.id),
        <DsThemeId>[defaultId, oceanId],
      );
      expect(
        () => registry.availableThemes.add(
          DsThemeMetadata(id: DsThemeId('forest'), displayName: 'Forest'),
        ),
        throwsUnsupportedError,
      );
      expect(
        registry.resolve(oceanId).createLightTheme().brightness,
        Brightness.light,
      );
      expect(
        registry.resolve(oceanId).createDarkTheme().brightness,
        Brightness.dark,
      );
    });
  });
}

final class _MismatchedThemeDefinition implements DsThemeDefinition {
  _MismatchedThemeDefinition({required this.id, required DsThemeId metadataId})
    : metadata = DsThemeMetadata(id: metadataId, displayName: 'Mismatched');

  @override
  final DsThemeId id;

  @override
  final DsThemeMetadata metadata;

  @override
  ThemeData createDarkTheme() => ThemeData.dark(useMaterial3: true);

  @override
  ThemeData createLightTheme() => ThemeData.light(useMaterial3: true);
}

final class _FakeThemeDefinition implements DsThemeDefinition {
  _FakeThemeDefinition({required this.id, required String name})
    : metadata = DsThemeMetadata(id: id, displayName: name);

  @override
  final DsThemeId id;

  @override
  final DsThemeMetadata metadata;

  @override
  ThemeData createDarkTheme() => ThemeData.dark(useMaterial3: true);

  @override
  ThemeData createLightTheme() => ThemeData.light(useMaterial3: true);
}
