import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:custom_data/utils/platform_info/enums/window_ration_aim.dart';
import 'package:window_manager/window_manager.dart';

import '../enums/platform_type_qyre.dart';
import '../platform_info_base.dart';

/// Factory for platform HTML ws client
IPlatformInfo create() => PlatformIo();

class PlatformIo implements IPlatformInfo {
  bool _initted = false;

  final _windowListener = WindowListenerAim();

  @override
  Future<void> init({bool isInMemory = false}) async {
    final platform = platformType;
    if (platform.isDesktop) {
      await windowManager.ensureInitialized();
    }
    if (!_initted) {
      windowManager.addListener(_windowListener);
    }
    _initted = true;
  }

  @override
  bool get isInitted => _initted;

  @override
  String get localeName => Platform.localeName;

  PlatformTypeMw? _platformTypeQyre;

  @override
  PlatformTypeMw get platformType {
    final type = _platformTypeQyre;
    if (type != null) {
      return type;
    }

    if (Platform.isIOS) {
      _platformTypeQyre = PlatformTypeMw.ios;
      return PlatformTypeMw.ios;
    }
    if (Platform.isAndroid) {
      _platformTypeQyre = PlatformTypeMw.android;
      return PlatformTypeMw.android;
    }
    if (Platform.isWindows) {
      _platformTypeQyre = PlatformTypeMw.windows;
      return PlatformTypeMw.windows;
    }
    return PlatformTypeMw.unknown;
  }

  @override
  String get operatingSystem => Platform.operatingSystem;

  @override
  bool get windowIsFullScreen => _windowIsFullScreen;
  bool _windowIsFullScreen = false;

  @override
  Future<bool> windowFullScreen({required bool? isFullScreen}) async {
    if (!platformType.isDesktop) {
      return false;
    }

    final makeFullScreen = isFullScreen ?? !(await windowManager.isFullScreen());
    _windowIsFullScreen = makeFullScreen;
    await windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    await windowManager.setFullScreen(makeFullScreen);
    return makeFullScreen;
  }

  @override
  Future<void> windowMinimize() async {
    return windowManager.minimize();
  }

  @override
  Future<void> windowClose() {
    return windowManager.close();
  }

  @override
  Future<void> setWindowFormat(WindowRatioAim windowRatio) async {
    await _windowListener.setWindowFormat(windowRatio);
  }
}

class WindowListenerAim extends WindowListener {
  WindowRatioAim _windowFormat = WindowRatioAim.none;
  final _resizeDebouncer = Debouncer(delayMs: 1000);

  Future<void> setWindowFormat(WindowRatioAim windowRatio) async {
    _windowFormat = windowRatio;
    onWindowResize();
  }

  @override
  void onWindowResize() {
    if (_windowFormat == WindowRatioAim.none) {
      return;
    }
    _resizeDebouncer.run(_onWindowResize);
  }

  Future<void> _onSetScreenSize(Size newSize) async {
    log(' > _onSetScreenSize (_windowFormat=$_windowFormat): $newSize');
    await windowManager.setSize(newSize);
  }

  Size _lastSize = const Size(0, 0);
  Future<void> _onWindowResize() async {
    final isFullScreen = await windowManager.isFullScreen();
    if (isFullScreen) {
      await windowManager.setFullScreen(false);
    }
    final size = await windowManager.getSize();
    switch (_windowFormat) {
      case WindowRatioAim.format16x9:
        late final double newWidth;
        late final double newHeight;
        //_lastSize
        if (size.height - _lastSize.height > 4) {
          newHeight = size.height;
          newWidth = size.height * 16 / 9;
          final diff = (newWidth - size.width).abs();
          if (diff < 2) {
            return;
          }
        } else {
          newWidth = size.width;
          newHeight = size.width * 9 / 16;
          final diff = (newHeight - size.height).abs();
          if (diff < 2) {
            return;
          }
        }

        await _onSetScreenSize(Size(newWidth, newHeight));
        break;
      case WindowRatioAim.format9x16:
        late final double newWidth;
        late final double newHeight;
        if (size.height - _lastSize.height > 4) {
          newHeight = size.height;
          newWidth = size.height * 9 / 16;
          final diff = (newWidth - size.width).abs();
          if (diff < 2) {
            return;
          }
        } else {
          newWidth = size.width;
          newHeight = size.width * 16 / 9;
          final diff = (newHeight - size.height).abs();
          if (diff < 2) {
            return;
          }
        }
        await _onSetScreenSize(Size(newWidth, newHeight));
        break;
      default:
        break;
    }
    _lastSize = size;
  }
}

class Debouncer {
  final int delayMs;

  Timer? _timer;

  Debouncer({required this.delayMs});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delayMs), action);
  }

  void stop() {
    _timer?.cancel();
  }
}
