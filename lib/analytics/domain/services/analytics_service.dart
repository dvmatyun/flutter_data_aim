import 'package:flutter/material.dart';

import '../repositories/analytics_repository.dart';

abstract class IAnalyticsService {
  Future<void> removeRepository(String name);
  Future<void> registerRepository(String name, IAnalyticsRepository analyticsRepo);

  List<NavigatorObserver> get navigatorObservers;

  void logEvent({
    required String name,
    Map<String, String>? parameters,
  });

  Future<void> pushData();

  Future<void> setUserId(String id, {required String? name});

  Future<void> close();
}
