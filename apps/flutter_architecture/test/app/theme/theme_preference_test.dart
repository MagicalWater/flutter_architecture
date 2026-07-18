import 'dart:async';
import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DsThemeRegistry registry;
  late ThemePreferenceCodec codec;

  setUp(() {
    registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[
        DefaultThemeDefinition(),
        OceanThemeDefinition(),
      ],
      defaultThemeId: DefaultThemeDefinition().id,
    );
    codec = ThemePreferenceCodec(registry);
  });

  test('version 1 round-trip preserves theme identity and mode', () {
    final preference = ThemePreference(
      themeId: OceanThemeDefinition().id,
      mode: AppThemeMode.dark,
    );
    expect(codec.decode(codec.encode(preference)), preference);
  });

  test('corrupted or unknown version falls back completely', () {
    final fallback = ThemePreference.defaults(registry);
    expect(codec.decode('{broken'), fallback);
    expect(
      codec.decode(
        jsonEncode(<String, Object>{
          'version': 9,
          'themeId': 'ocean',
          'mode': 'dark',
        }),
      ),
      fallback,
    );
  });

  test('unknown fields fall back independently', () {
    expect(
      codec.decode(
        jsonEncode(<String, Object>{
          'version': 1,
          'themeId': 'removed',
          'mode': 'dark',
        }),
      ),
      ThemePreference(
        themeId: DefaultThemeDefinition().id,
        mode: AppThemeMode.dark,
      ),
    );
    expect(
      codec.decode(
        jsonEncode(<String, Object>{
          'version': 1,
          'themeId': 'ocean',
          'mode': 'sepia',
        }),
      ),
      ThemePreference(
        themeId: OceanThemeDefinition().id,
        mode: AppThemeMode.system,
      ),
    );
    expect(
      codec.decode(
        jsonEncode(<String, Object>{
          'version': 1,
          'themeId': ' Ocean ',
          'mode': 'dark',
        }),
      ),
      ThemePreference(
        themeId: DefaultThemeDefinition().id,
        mode: AppThemeMode.dark,
      ),
    );
  });

  test(
    'read exception returns fallback diagnostic and does not write',
    () async {
      final storage = _FakeStorage(readError: StateError('read failed'));
      final result = await ThemePreferenceStore(storage, codec).restore();
      expect(result.preference, ThemePreference.defaults(registry));
      expect(result.diagnostic, isA<StateError>());
      expect(storage.writes, isEmpty);
    },
  );

  test(
    'runtime updates immediately and failed persistence does not roll back',
    () async {
      final storage = _FakeStorage(writeErrors: <Object>[StateError('failed')]);
      final controller = ThemeController(
        registry: registry,
        store: ThemePreferenceStore(storage, codec),
        initialPreference: ThemePreference.defaults(registry),
      );

      controller.selectTheme(OceanThemeDefinition().id);
      expect(controller.preference.themeId, OceanThemeDefinition().id);
      await controller.waitForPendingWrites();
      expect(controller.preference.themeId, OceanThemeDefinition().id);
      expect(controller.diagnostic, isA<StateError>());
    },
  );

  test(
    'serialized writes keep complete snapshots and latest preference wins',
    () async {
      final firstGate = Completer<void>();
      final storage = _FakeStorage(
        writeGates: <Future<void>>[firstGate.future],
      );
      final controller = ThemeController(
        registry: registry,
        store: ThemePreferenceStore(storage, codec),
        initialPreference: ThemePreference.defaults(registry),
      );

      controller.selectTheme(OceanThemeDefinition().id);
      controller.selectMode(AppThemeMode.dark);
      await Future<void>.delayed(Duration.zero);
      expect(storage.writes, hasLength(1));
      firstGate.complete();
      await controller.waitForPendingWrites();

      expect(storage.writes, hasLength(2));
      expect(codec.decode(storage.writes.last), controller.preference);
    },
  );

  test('a failed write does not block a newer preference', () async {
    final storage = _FakeStorage(writeErrors: <Object>[StateError('first')]);
    final controller = ThemeController(
      registry: registry,
      store: ThemePreferenceStore(storage, codec),
      initialPreference: ThemePreference.defaults(registry),
    );

    controller.selectTheme(OceanThemeDefinition().id);
    controller.selectMode(AppThemeMode.light);
    await controller.waitForPendingWrites();

    expect(storage.writes, hasLength(2));
    expect(codec.decode(storage.writes.last), controller.preference);
    expect(controller.diagnostic, isNull);
  });

  test(
    'an older failed write cannot overwrite a newer mutation diagnostic',
    () async {
      final firstGate = Completer<void>();
      final storage = _FakeStorage(
        writeErrors: <Object>[StateError('first')],
        writeGates: <Future<void>>[firstGate.future],
      );
      final controller = ThemeController(
        registry: registry,
        store: ThemePreferenceStore(storage, codec),
        initialPreference: ThemePreference.defaults(registry),
      );

      controller.selectTheme(OceanThemeDefinition().id);
      controller.selectMode(AppThemeMode.dark);
      firstGate.complete();
      await controller.waitForPendingWrites();

      expect(codec.decode(storage.writes.last), controller.preference);
      expect(controller.diagnostic, isNull);
    },
  );
}

final class _FakeStorage implements ThemePreferenceStorage {
  _FakeStorage({
    this.readError,
    List<Object>? writeErrors,
    List<Future<void>>? writeGates,
  }) : writeErrors = writeErrors ?? <Object>[],
       writeGates = writeGates ?? <Future<void>>[];

  final Object? readError;
  final List<Object> writeErrors;
  final List<Future<void>> writeGates;
  final List<String> writes = <String>[];
  int _writeIndex = 0;

  @override
  Future<String?> read() async {
    if (readError != null) throw readError!;
    return null;
  }

  @override
  Future<void> write(String value) async {
    final index = _writeIndex++;
    writes.add(value);
    if (index < writeGates.length) await writeGates[index];
    if (index < writeErrors.length) throw writeErrors[index];
  }
}
