import 'dart:async';

import 'package:custom_data/analytics/data/models/analytics_event_dto.dart';
import 'package:flutter/material.dart';
import 'package:l/l.dart';

import '../../domain/entities/analytics_event_custom.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../data_sources/analytics_data_source.dart';

class CustomAnalyticsRepo implements IAnalyticsRepository {
  final _scheduledEvents = <String, AnalyticsEventCustom>{};
  IAnalyticsDataSource? _dataSource;

  Timer? _periodicReport;
  Duration _baseDuration = const Duration(minutes: 1);

  CustomAnalyticsRepo();

  Future<void> enable(IAnalyticsDataSource dataSource) async {
    _dataSource = dataSource;
    await _pushInternal();
    _periodicReport = Timer.periodic(_baseDuration, (_) async {
      await _pushInternal();
    });
  }

  Future<void> disable() async {
    _dataSource = null;
    _periodicReport?.cancel();
  }

  @override
  Future<void> init() async {}

  Future<void> _pushInternal() async {
    _periodicReport?.cancel();
    if (_dataSource == null) {
      return;
    }
    l.v(' > CustomAnalyticsRepo: pushing data by timer!');
    await pushData();
    if (_baseDuration.inMinutes < 5) {
      _baseDuration = Duration(minutes: _baseDuration.inMinutes + 1);
    }
    _periodicReport = Timer.periodic(_baseDuration, (_) async {
      await _pushInternal();
    });
  }

  @override
  bool get isInnitted => true;

  @override
  Future<void> logEvent({required String name, Map<String, String?>? parameters}) async {
    final key = '$name;${parameters?.values.join(',')}';
    final eventExist = _scheduledEvents[key];
    if (eventExist != null) {
      _scheduledEvents[key] = eventExist.increment();
    } else {
      _scheduledEvents[key] = AnalyticsEventCustom(name: name, params: parameters, amount: 1);
    }
  }

  @override
  NavigatorObserver? get navigatorObserver => null;

  bool _isPushing = false;
  @override
  Future<void> pushData() async {
    if (_dataSource == null) {
      return;
    }
    if (_isPushing) {
      return;
    }
    _isPushing = true;
    try {
      await _pushDataInternal();
    } on Object catch (e, st) {
      l.e(' > CustomAnalyticsRepo error: [$e]', st);
    } finally {
      _isPushing = false;
    }
  }

  Future<void> _pushDataInternal() async {
    final data = _scheduledEvents.values.toList();
    if (data.isEmpty) {
      return;
    }

    //_appHealthService

    final metaDataEvent = AnalyticsEventDto(
      name: 'analytics_metadata_custom',
      amount: 1,
      num1: data.length,
    );

    _scheduledEvents.clear();
    final dtoList = <AnalyticsEventDto>[metaDataEvent];
    for (final d in data) {
      final event = AnalyticsEventDto(name: d.name, amount: d.amount);
      for (final v in d.params?.values ?? const []) {
        if (v is num) {
          if (event.num1 == null) {
            event.num1 = v;
            continue;
          }
          if (event.num2 == null) {
            event.num2 = v;
            continue;
          }
          if (event.num3 == null) {
            event.num3 = v;
            continue;
          }
        }
        if (v is String) {
          if (event.str1 == null) {
            event.str1 = v;
            continue;
          }
          if (event.str2 == null) {
            event.str2 = v;
            continue;
          }
          if (event.str3 == null) {
            event.str3 = v;
            continue;
          }
        }
      }
      dtoList.add(event);
    }
    await _dataSource?.sendData(dtoList);
  }

  @override
  Future<void> close() async {
    await disable();
  }

  @override
  Future<void> setUserId(String id, {String? name}) async {}
}
