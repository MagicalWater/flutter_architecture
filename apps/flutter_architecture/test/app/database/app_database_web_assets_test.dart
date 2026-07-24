import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drift Web assets存在且sqlite3.wasm符合resolved 3.5.0 hash', () async {
    final worker = File('web/drift_worker.js');
    final wasm = File('web/sqlite3.wasm');

    expect(worker.existsSync(), isTrue);
    expect(await worker.length(), greaterThan(1000));
    expect(wasm.existsSync(), isTrue);

    final result = await Process.run('shasum', <String>[
      '-a',
      '256',
      wasm.path,
    ]);
    expect(result.exitCode, 0);
    expect(
      (result.stdout as String).split(' ').first,
      '41cf968998241465d8b1dfffb1eb60dd10c35de5022a3647e14174ea3af84143',
    );
  });
}
