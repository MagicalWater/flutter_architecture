import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot:
      (
        String screenshotName,
        List<int> screenshotBytes, [
        Map<String, Object?>? args,
      ]) async {
        final output = File('build/runtime-screenshots/$screenshotName.png');
        await output.parent.create(recursive: true);
        await output.writeAsBytes(screenshotBytes, flush: true);
        return true;
      },
);
