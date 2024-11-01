import 'package:flutter/material.dart';

abstract class IAnalyticsRepository {
  Future<void> init();
  bool get isInnitted;

  NavigatorObserver? get navigatorObserver;

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });

  Future<void> pushData();

  Future<void> setUserId(String id, {required String? name});

  Future<void> close();
}
