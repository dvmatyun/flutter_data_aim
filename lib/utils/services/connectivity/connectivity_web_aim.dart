import 'package:custom_data/utils/services/connectivity/connectivity_aim.dart';

/// Factory for platform HTML
IConnectivityAim createConnectivity() => ConnectivityWebAimImpl();

class ConnectivityWebAimImpl implements IConnectivityAim {
  @override
  Future<ConnectionStatusQyre> checkConnection({bool checkClientVersion = false}) async {
    return ConnectionStatusQyre.internet;
  }

  @override
  Future<void> close() async {}

  @override
  bool get connected => true;

  @override
  Stream<ConnectionStatusQyre> get connectionStatusStream => const Stream<ConnectionStatusQyre>.empty();

  @override
  ConnectionStatusQyre get lastStatus => ConnectionStatusQyre.internet;

  @override
  Future<ConnectionStatusQyre> waitInternetConnection({Duration lastCheckLag = const Duration(seconds: 5)}) async {
    return ConnectionStatusQyre.internet;
  }
}
