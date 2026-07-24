import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_plus_adapter.dart';
import 'package:flutter_architecture/app/di/register_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RegisterModule只在App composition建立connectivity adapter', () {
    final module = _RegisterModuleForTest();
    final connectivity = module.connectivity;

    expect(connectivity, isA<Connectivity>());
    expect(
      module.connectivityAdapter(connectivity),
      isA<ConnectivityPlusAdapter>(),
    );
  });
}

final class _RegisterModuleForTest extends RegisterModule {}
