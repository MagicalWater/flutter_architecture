import 'dart:collection';

import 'package:design_system/src/theme/ds_theme_definition.dart';
import 'package:design_system/src/theme/ds_theme_id.dart';
import 'package:design_system/src/theme/ds_theme_metadata.dart';

/// Theme definitions 的純 Dart registry，不處理 persistence 或 DI。
final class DsThemeRegistry {
  DsThemeRegistry({
    required Iterable<DsThemeDefinition> definitions,
    required this.defaultThemeId,
  }) {
    final definitionList = List<DsThemeDefinition>.of(definitions);
    if (definitionList.isEmpty) {
      throw ArgumentError.value(definitions, 'definitions', '不可為空');
    }

    final byId = <DsThemeId, DsThemeDefinition>{};
    for (final definition in definitionList) {
      final id = definition.metadata.id;
      if (byId.containsKey(id)) {
        throw ArgumentError.value(id, 'definitions', 'Theme ID 不可重複');
      }
      byId[id] = definition;
    }

    final defaultDefinition = byId[defaultThemeId];
    if (defaultDefinition == null) {
      throw ArgumentError.value(
        defaultThemeId,
        'defaultThemeId',
        'Default Theme 必須存在於 registry',
      );
    }

    _definitionsById = Map<DsThemeId, DsThemeDefinition>.unmodifiable(byId);
    _defaultDefinition = defaultDefinition;
    _availableThemes = List<DsThemeMetadata>.unmodifiable(
      definitionList.map((definition) => definition.metadata),
    );
  }

  final DsThemeId defaultThemeId;

  late final Map<DsThemeId, DsThemeDefinition> _definitionsById;
  late final DsThemeDefinition _defaultDefinition;
  late final List<DsThemeMetadata> _availableThemes;

  UnmodifiableListView<DsThemeMetadata> get availableThemes =>
      UnmodifiableListView<DsThemeMetadata>(_availableThemes);

  DsThemeDefinition resolve(DsThemeId id) =>
      _definitionsById[id] ?? _defaultDefinition;
}
