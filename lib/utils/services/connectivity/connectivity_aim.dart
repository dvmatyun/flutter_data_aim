import 'dart:async';

import 'connectivity_io_aim.dart' if (dart.library.html) 'connectivity_web_aim.dart';

enum ConnectionStatusQyre {
  none,
  internet,
  other;

  bool get isConnected => this != none;
}

abstract class IConnectivityAim {
  ConnectionStatusQyre get lastStatus;
  Stream<ConnectionStatusQyre> get connectionStatusStream;

  bool get connected;

  Future<ConnectionStatusQyre> waitInternetConnection({Duration lastCheckLag = const Duration(seconds: 5)});
  Future<ConnectionStatusQyre> checkConnection({bool checkClientVersion = false});
  Future<void> close();

  /// Create universal platform client
  factory IConnectivityAim.create() => createConnectivity();
}
