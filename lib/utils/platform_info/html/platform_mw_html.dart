// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:custom_data/utils/platform_info/enums/platform_type_qyre.dart';
import 'package:custom_data/utils/platform_info/enums/window_ration_aim.dart';
import 'package:custom_data/utils/platform_info/platform_info_base.dart';

/// Factory for platform HTML ws client
IPlatformInfo create() => PlatformQyreHtml();

class PlatformQyreHtml implements IPlatformInfo {
  @override
  Future<void> init({bool isInMemory = false}) async {}

  @override
  bool get isInitted => false;

  @override
  String get localeName => 'us';

  @override
  PlatformTypeMw get platformType => PlatformTypeMw.web;

  @override
  String get operatingSystem {
    return 'web ${html.window.navigator.platform}';
  }

  @override
  Future<bool> windowFullScreen({required bool? isFullScreen}) async {
    return false;
  }

  @override
  Future<void> windowClose() async {}

  @override
  bool get windowIsFullScreen => false;

  @override
  Future<void> windowMinimize() async {}

  @override
  Future<void> setWindowFormat(WindowRatioAim windowRatio) async {}
}
