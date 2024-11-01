import 'dart:async';

typedef FutureVoidCallback = FutureOr<void> Function();

class DebouncerAim<T> {
  DebouncerAim({
    this.timeout = const Duration(milliseconds: 350),
  });

  final Duration timeout;
  Timer? _debounceTimer;

  Future<bool> valueChanged(FutureVoidCallback callback) async {
    cancel();
    var started = false;
    var isDone = false;
    _debounceTimer = Timer(timeout, () async {
      started = true;
      await callback();
      isDone = true;
    });
    while (!isDone && (started || (_debounceTimer?.isActive ?? false))) {
      await Future<void>.delayed(timeout);
    }
    await Future<void>.delayed(timeout);
    return isDone;
  }

  void cancel() {
    _debounceTimer?.cancel();
  }
}

class ThrottlerAim<T> {
  ThrottlerAim({
    this.timeout = const Duration(milliseconds: 2000),
  });

  final Duration timeout;
  Timer? _debounceTimer;

  FutureVoidCallback? _latestCallback;

  Future<void> valueChanged(FutureVoidCallback callback) async {
    if (_debounceTimer == null) {
      _debounceTimer = Timer(timeout, () async {
        _debounceTimer = null;
        final latestCallback = _latestCallback;
        if (latestCallback != null) {
          _latestCallback = null;
          await valueChanged(callback);
        }
      });
      await callback();
    } else {
      _latestCallback = callback;
    }
  }

  void cancel() {
    _debounceTimer?.cancel();
  }
}
