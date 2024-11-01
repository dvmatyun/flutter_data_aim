import 'dart:async';

import 'package:custom_data/custom_data.dart';
import 'package:flutter/foundation.dart';

typedef AsyncCallbackAim = Future<void> Function();

class ControllerAim<T extends StateAim> {
  ControllerAim(T initialState) : _stateNotifier = ValueNotifier<T>(initialState);

  late final ValueNotifier<T> _stateNotifier;

  T get state => _stateNotifier.value;
  ValueListenable<T> get stateListenable => _stateNotifier;
  bool isClosed = false;

  // ignore: use_setters_to  _change_properties
  void emit(T state) {
    if (isClosed) {
      return;
    }
    _stateNotifier.value = state;
  }

  Future<void> internalCall(AsyncCallbackAim action, {bool isLoading = true}) async {
    await runZonedGuarded(() async {
      if (isLoading) {
        emit(state.copyWithBase(isLoading: true));
      }
      await action();
    }, (e, st) {
      if (e is IExceptionAim) {
        emit(state.copyWithBase(error: e));
      } else {
        emit(state.copyWithBase(error: ClientException(message: e.toString())));
      }
    });
    if (isLoading) {
      emit(state.copyWithBase(isLoading: false));
    }
  }

  void close() {
    isClosed = true;
    _stateNotifier.dispose();
  }
}

abstract class StateAim<T> {
  const StateAim();

  IExceptionAim? get error;
  bool get isLoading;

  T copyWithBase({
    IExceptionAim? error,
    bool? isLoading,
  });
}
