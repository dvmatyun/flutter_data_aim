import 'dart:async';
import 'package:custom_data/analytics/domain/repositories/analytics_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:l/l.dart';

class FirebaseAnalyticsRepositoryWeb extends FirebaseAnalyticsRepository {
  FirebaseAnalyticsRepositoryWeb({required this.options});

  final FirebaseOptions options;
  @override
  Future<void> init() async {
    if (_completer.isCompleted) {
      return;
    }
    l.v(' > FirebaseAnalyticsRepositoryWeb init');
    await Firebase.initializeApp(options: options);
    l.v(' > FirebaseAnalyticsRepositoryWeb init [done]');
    _completer.complete();
  }
}

class FirebaseAnalyticsRepository implements IAnalyticsRepository {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _firebaseObserver = FirebaseAnalyticsObserver(analytics: _analytics);

  final _completer = Completer();

  @override
  Future<void> init() async {
    if (_completer.isCompleted) {
      return;
    }
    await Firebase.initializeApp();
    _completer.complete();
  }

  @override
  bool get isInnitted => _completer.isCompleted;

  @override
  Future<void> logEvent({required String name, Map<String, String>? parameters}) async {
    await _completer.future;

    try {
      await _analytics.logEvent(name: name.toLowerCase(), parameters: parameters);
      l.v(' > FirebaseAnalyticsRepository logged event: $name with parameters: $parameters');
    } on Object catch (e) {
      l.e(' > FirebaseAnalyticsRepository.logEvent: $e');
    }
  }

  @override
  NavigatorObserver? get navigatorObserver => isInnitted ? _firebaseObserver : null;

  @override
  Future<void> pushData() async {
    /// Not needed. Firebase does it itself
  }

  @override
  Future<void> setUserId(String id, {required String? name}) async {
    await _analytics.setUserId(id: id, callOptions: AnalyticsCallOptions(global: true));
    if (name != null) {
      await _analytics.setUserProperty(name: 'username', value: name);
    }
  }

  @override
  Future<void> close() async {}
}
