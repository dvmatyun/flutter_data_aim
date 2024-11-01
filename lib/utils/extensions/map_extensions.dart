extension MapListValueExtensions<T, Y> on Map<T, List<Y>> {
  void addToList(T key, Y value) {
    if (containsKey(key)) {
      this[key]!.add(value);
    } else {
      this[key] = [value];
    }
  }
}

extension MapExtensions<T, Y> on Map<T, Y> {
  Y getOrAdd(T key, Y Function() create) {
    final stored = this[key];
    if (stored != null) {
      return stored;
    } else {
      final value = create();
      this[key] = value;
      return value;
    }
  }
}
