import 'dart:convert';

import 'package:custom_data/custom_data.dart';
import 'package:custom_data/local_data/data/models/versioned_data_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageSingleKey {
  LocalStorageSingleKey(this.key, {ILocalStorageAim? storage}) : _storage = storage ?? LocalStorageAimImpl();

  final String key;
  final ILocalStorageAim _storage;

  Future<String?> getString() {
    return _storage.getString(key);
  }

  Future<void> setString(String value) {
    return _storage.setString(key, value);
  }
}

class LocalStorageAimImpl implements ILocalStorageAim {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async => _prefs ??= await SharedPreferences.getInstance();
  String? _currentVersion;
  String? _requiredMinimalVersion;

  @override
  Future<void> initWarmUp() async {
    await _getPrefs();
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  @override
  void setVersions({String? current, String? requiredMinimal}) {
    if (current != null) {
      _currentVersion = current;
    }
    if (requiredMinimal != null) {
      _requiredMinimalVersion = requiredMinimal;
    }
  }

  @override
  Future<Map<String, dynamic>?> getJsonVersioned(String key) async {
    try {
      final strObj = await getString(key);
      if (strObj == null) {
        return null;
      }
      final json = jsonDecode(strObj) as Map<String, dynamic>?;
      if (json == null) {
        return null;
      }
      final obj = VersionedDataImpl.fromJson(json);
      if (_requiredMinimalVersion == null) {
        return obj.json;
      }
      final curVersion = VersionUtil.versionValue(obj.version);
      final minVersion = VersionUtil.versionValue(_requiredMinimalVersion);
      if (curVersion < minVersion) {
        return null;
      }
      return obj.json;
    } on Object catch (_) {
      remove(key).ignore();
      rethrow;
    }
  }

  @override
  Future<void> setJsonVersioned(String key, Map<String, dynamic> json) async {
    if (kDebugMode) {
      return; // Do not use #cache for debug
    }
    final obj = VersionedDataImpl(version: _currentVersion ?? '1', json: json);
    final strObj = jsonEncode(obj.toJson());
    await setString(key, strObj);
  }
}
