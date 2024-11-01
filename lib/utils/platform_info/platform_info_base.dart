import 'package:custom_data/utils/platform_info/enums/platform_type_qyre.dart';
import 'package:custom_data/utils/platform_info/enums/window_ration_aim.dart';

import 'io/platform_mw_io.dart' if (dart.library.html) 'html/platform_mw_html.dart';

/// Universal platform websocket implementation
abstract class IPlatformInfo {
  Future<void> init();
  bool get isInitted;

  /// Pass null if you want to toggle fullscreen
  Future<bool> windowFullScreen({required bool? isFullScreen});
  bool get windowIsFullScreen;

  /// Minimize window (desktop only)
  Future<void> windowMinimize();

  /// Minimize window (desktop only)
  Future<void> windowClose();

  Future<void> setWindowFormat(WindowRatioAim windowRatio);

  String get localeName;

  PlatformTypeMw get platformType;

  String get operatingSystem;

  /// Create universal platform client
  factory IPlatformInfo.create() => create();
}
