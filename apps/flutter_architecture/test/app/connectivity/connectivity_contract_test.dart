import 'package:flutter_architecture/app/connectivity/connectivity_adapter.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConnectivityState 保持最小且typed的三態contract', () {
    expect(
      ConnectivityState.values,
      const <ConnectivityState>[
        ConnectivityState.unknown,
        ConnectivityState.offline,
        ConnectivityState.online,
      ],
    );
  });

  test('ConnectivityAdapter 不需要provider-specific type', () async {
    final adapter = _FakeConnectivityAdapter();

    expect(await adapter.readCurrentState(), ConnectivityState.online);
    expect(await adapter.stateChanges.first, ConnectivityState.offline);

    await adapter.dispose();
    expect(adapter.isDisposed, isTrue);
  });
}

final class _FakeConnectivityAdapter implements ConnectivityAdapter {
  bool isDisposed = false;

  @override
  Future<ConnectivityState> readCurrentState() async =>
      ConnectivityState.online;

  @override
  Stream<ConnectivityState> get stateChanges =>
      Stream<ConnectivityState>.value(ConnectivityState.offline);

  @override
  Future<void> dispose() async {
    isDisposed = true;
  }
}
