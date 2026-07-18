import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('spacing scale 維持遞增且沒有負值', () {
    const values = <double>[
      DsSpace.xxs,
      DsSpace.xs,
      DsSpace.sm,
      DsSpace.md,
      DsSpace.lg,
      DsSpace.xl,
    ];

    expect(values.every((value) => value >= 0), isTrue);
    for (var index = 1; index < values.length; index++) {
      expect(values[index], greaterThan(values[index - 1]));
    }
  });

  test('radius、elevation 與 icon size tokens 為合法值', () {
    expect(DsRadius.sm, greaterThan(0));
    expect(DsRadius.md, greaterThan(DsRadius.sm));
    expect(DsRadius.lg, greaterThan(DsRadius.md));

    expect(DsElevation.none, 0);
    expect(DsElevation.low, greaterThan(DsElevation.none));

    expect(DsIconSize.hero, greaterThan(0));
  });

  test('semantic color roles 不暴露 raw palette 名稱', () {
    expect(DsSemanticColorRole.values, <DsSemanticColorRole>[
      DsSemanticColorRole.success,
      DsSemanticColorRole.warning,
      DsSemanticColorRole.info,
    ]);
  });
}
