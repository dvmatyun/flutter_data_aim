import 'dart:async';
import 'package:flutter/material.dart';
import 'package:l/l.dart';
import '../../domain/repositories/analytics_repository.dart';

class DebugLogAnalyticsRepo implements IAnalyticsRepository {
  const DebugLogAnalyticsRepo();

  void _log(String message) {
    l.vv(' > [ANALYTICS DEBUG] $message');
  }

  @override
  Future<void> close() async {
    _log('closed');
  }

  @override
  Future<void> init() async {
    _log('init');
  }

  @override
  bool get isInnitted => true;

  @override
  Future<void> logEvent({required String name, Map<String, String>? parameters}) async {
    _log('logEvent: {$name, $parameters}');
  }

  @override
  NavigatorObserver? get navigatorObserver => null;

  @override
  Future<void> pushData() async {
    _log('pushData');
  }

  @override
  Future<void> setUserId(String id, {required String? name}) async {
    _log('setUserId (id=$id, name=$name)');
  }
}
