import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/protected/presentation/pages/protected_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProtectedPage 顯示通過 Route Guard 的內容', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProtectedPage(),
      ),
    );

    expect(find.text('Protected Page'), findsOneWidget);
    expect(find.text('你已通過 Route Guard'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
  });
}
