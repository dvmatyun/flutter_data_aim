import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:l/l.dart';

import '../../domain/repositories/analytics_repository.dart';
import '../../domain/services/analytics_service.dart';

class FirebaseAnalyticsServiceImpl implements IAnalyticsService {
  final _repositories = <String, IAnalyticsRepository>{};

  @override
  void logEvent({required String name, Map<String, Object>? parameters}) {
    for (final r in _repositories.values) {
      try {
        r.logEvent(name: name, parameters: parameters);
      } on Object catch (e) {
        l.e(' > logEvent error: $e');
      }
    }
  }

  @override
  List<NavigatorObserver> get navigatorObservers =>
      _repositories.values.map((x) => x.navigatorObserver).whereType<NavigatorObserver>().toList();

  bool get _useAnalytics => useAnalyticsOverride;

  bool useAnalyticsOverride = kReleaseMode;

  @override
  Future<void> registerRepository(String name, IAnalyticsRepository analyticsRepo) async {
    _log('registerRepository: $name');
    if (!_useAnalytics) {
      return;
    }
    _repositories[name] = analyticsRepo;
    await analyticsRepo.init();
    _log('registerRepository: $name [done]');
  }

  @override
  Future<void> pushData() async {
    _log('push data');
    for (final r in _repositories.values) {
      try {
        await r.pushData();
      } on Object catch (e) {
        _logError(' > logEvent error: $e');
      }
    }
  }

  @override
  Future<void> removeRepository(String name) async {
    _repositories.remove(name);
  }

  @override
  Future<void> close() async {
    _log('closed');
    final repos = _repositories.values.toList();
    for (final r in repos) {
      await r.close();
    }
  }

  @override
  Future<void> setUserId(String id, {required String? name}) async {
    _log('user id: $id');
    for (final r in _repositories.values) {
      try {
        await r.setUserId(id, name: name);
      } on Object catch (e) {
        _logError(' > logEvent error: $e');
      }
    }
  }

  void _log(String msg) {
    l.v('> FirebaseAnalyticsServiceImpl: [$msg]');
  }

  void _logError(String msg) {
    l.e('> FirebaseAnalyticsServiceImpl: [$msg]');
  }
}
