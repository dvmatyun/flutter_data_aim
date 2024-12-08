import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_data/exceptions/data/client_exceptions.dart';
import 'package:custom_data/utils/services/connectivity/connectivity_aim.dart';
import 'package:l/l.dart';

/// Factory for platform IO
IConnectivityAim createConnectivity() => ConnectivityAimImpl();

class ConnectivityAimImpl implements IConnectivityAim {
  ConnectivityAimImpl() {
    _initSubs();
  }

  final connectivity = Connectivity();
  late final StreamSubscription _connectionSub;
  final _connectionSc = StreamController<ConnectionStatusQyre>.broadcast();

  StreamSubscription? _periodicCheck;

  Future<void> _initSubs() async {
    _connectionSub = connectivity.onConnectivityChanged.map(_mapStatus).listen(_connectivityListener);
    _lastStatus ??= await _checkStaticConnectivity();
    _periodicCheck = Stream.periodic(const Duration(seconds: 5)).listen((_) {
      checkConnection();
    });
  }

  Future<void> _connectivityListener(ConnectionStatusQyre status) async {
    if (status == ConnectionStatusQyre.none) {
      // immediatly showing that internet is not available
      _lastStatus = status;
    }
    _lastStatus = await waitInternetConnection(lastCheckLag: Duration.zero);
  }

  Future<ConnectionStatusQyre> _checkStaticConnectivity() async {
    final result = await connectivity.checkConnectivity();
    return _mapStatus(result);
  }

  @override
  bool get connected => lastStatus != ConnectionStatusQyre.none;

  ConnectionStatusQyre? _lastStatusValue;
  ConnectionStatusQyre? get _lastStatus => _lastStatusValue;
  set _lastStatus(ConnectionStatusQyre? value) {
    if (value == _lastStatusValue) {
      return;
    }
    _connectionSc.add(value ?? ConnectionStatusQyre.internet);
    _lastStatusValue = value ?? ConnectionStatusQyre.internet;
  }

  @override
  ConnectionStatusQyre get lastStatus => _lastStatus ?? ConnectionStatusQyre.internet;

  @override
  Stream<ConnectionStatusQyre> get connectionStatusStream => _connectionSc.stream;

  ConnectionStatusQyre _mapStatus(List<ConnectivityResult> libResult) {
    if (libResult.any((e) => !{ConnectivityResult.none, ConnectivityResult.bluetooth}.contains(e))) {
      return ConnectionStatusQyre.internet;
    }
    return ConnectionStatusQyre.none;
  }

  /*
  ConnectionStatusQyre _mapStatus(ConnectivityResult libResult) {
    if (libResult != ConnectivityResult.none) {
      return ConnectionStatusQyre.internet;
    }
    return ConnectionStatusQyre.none;
  }
  */
  bool _closed = false;

  @override
  Future<void> close() async {
    _closed = true;
    await _periodicCheck?.cancel();
    await _connectionSub.cancel();
    await _connectionSc.close();
  }

  void _throwIfClosed() {
    if (_closed) {
      l.e(' > ConnectivityQyre IS ALREADY CLOSED');
      throw const ClientException(
        title: 'Connectivity closed',
        message: 'Connectivity is already closed.',
      );
    }
  }

  //
  Completer<ConnectionStatusQyre>? _completerConnection;

  /*
  Future<T> performInternetAction<T>(
    AsyncValueQyre<T> action, {
    Duration lastCheckLag = const Duration(seconds: 5),
    int retryAttempts = 3,
  }) {}
  */

  @override
  Future<ConnectionStatusQyre> waitInternetConnection({Duration lastCheckLag = const Duration(seconds: 5)}) async {
    if (connected && (lastCheckLag.inSeconds > _intervalBetweenLastCheck.inSeconds)) {
      return lastStatus;
    }
    _throwIfClosed();
    final completer = _completerConnection;
    if (completer != null) {
      await completer.future;
      return lastStatus;
    }

    final completerNew = Completer<ConnectionStatusQyre>();
    _completerConnection ??= completerNew;
    try {
      var connectivityStatus = await checkConnection();

      if (connectivityStatus == ConnectionStatusQyre.none) {
        for (var i = 0; i < 100; ++i) {
          l.s(' > ConnectivityQyre NO INTERNET CONNECTION, WAITING...');
          final staticConnection = await _checkStaticConnectivity();
          if (staticConnection == ConnectionStatusQyre.none) {
            await Future.delayed(const Duration(seconds: 4));
          }
          await Future.delayed(const Duration(seconds: 2));
          _throwIfClosed();
          _lastStatus = connectivityStatus = await checkConnection();
          if (connectivityStatus != ConnectionStatusQyre.none) {
            break;
          }
        }
      }

      completerNew.complete(connectivityStatus);
    } on Object catch (e) {
      l.e(' > ConnectivityQyre waitInternetConnection ERROR: $e');
      completerNew.complete(ConnectionStatusQyre.none);
    } finally {
      _completerConnection = null;
    }
    return lastStatus;
  }

  DateTime _lastCheckTime = DateTime(2000);
  Duration get _intervalBetweenLastCheck {
    return DateTime.now().difference(_lastCheckTime);
  }

  @override
  Future<ConnectionStatusQyre> checkConnection({bool checkClientVersion = true}) async {
    /*
    try {
      //final dio = Dio();
      //final response = await dio.get('https://dart.dev');
      //debugPrint(' > response: $response');
      // Checking connection && qyre #version #mismatch
      l.v(' > Connectivity Qyre checkConnection');
      await _pingClient.ping();
      _lastStatus = ConnectionStatusQyre.internet;
    } on ClientVersionUpdateRequiredException catch (_) {
      _lastStatus = ConnectionStatusQyre.internet;
      if (checkClientVersion) {
        _eventService.addEvent(
          const QyreEvent(
            type: QyreEventType.contextlessModal,
            data: $onUpdateAppRequiredModalName,
          ), //#version #mismatch #update_required
        );
        //await $showUpdateAppVersionDialog(); //#version #mismatch #update_required
      }
    } on Object catch (_) {
      _lastStatus = ConnectionStatusQyre.none;
    }
    */
    _lastStatus = ConnectionStatusQyre.internet;
    _connectionSc.add(ConnectionStatusQyre.internet);
    _lastCheckTime = DateTime.now();
    return lastStatus;
  }
}
