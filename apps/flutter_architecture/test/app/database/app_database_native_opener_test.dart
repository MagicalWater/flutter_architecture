import 'dart:io';

import 'package:flutter_architecture/app/database/app_database_opener_native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('macOS production opener建立精確檔名且close可重複呼叫', () async {
    if (!Platform.isMacOS) return;
    final directory = await Directory.systemTemp.createTemp('drift-opener-');
    addTearDown(() => directory.delete(recursive: true));

    final database = await openAppDatabase(
      desktopDocumentsDirectory: () async => directory,
    );
    await database.customSelect('SELECT 1').getSingle();
    await database.close();
    await database.close();

    expect(
      File('${directory.path}/flutter_architecture.db').existsSync(),
      isTrue,
    );
  });
}
