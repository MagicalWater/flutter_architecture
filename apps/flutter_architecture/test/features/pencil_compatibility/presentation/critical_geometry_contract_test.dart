import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'critical geometry uses actual RenderBox evidence rather than source constants',
    (tester) async {
      const declaredHeight = 27.0;
      const constrainedHeight = 25.8;
      const targetKey = ValueKey<String>('criticalGeometryTarget');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: constrainedHeight,
              child: SizedBox(key: targetKey, height: declaredHeight, width: 161),
            ),
          ),
        ),
      );

      final actualSize = tester.getSize(find.byKey(targetKey));

      expect(actualSize.height, constrainedHeight);
      expect(actualSize.height, isNot(declaredHeight));
      expect(actualSize.width, 161);
    },
  );
}
