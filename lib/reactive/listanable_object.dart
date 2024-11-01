import 'package:flutter/foundation.dart';

class ListanableObject<T> extends ValueNotifier<T> implements ValueListenable<T> {
  ListanableObject(T defaultValue) : super(defaultValue);

  bool get anyListeners => hasListeners;

  // ignore: use_setters_to_change_properties
  void notifyValue(T newValue) {
    value = newValue;
  }
}
