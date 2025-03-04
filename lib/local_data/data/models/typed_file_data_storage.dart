import 'dart:math';
import 'dart:typed_data';

import 'package:custom_data/custom_data.dart';

// Serializing object:
// 1. add all dictionaries
// 2. add all data

/// T is type of itself - DTO
/// E is type of entity itself
abstract class ITypedDataSerializer<T extends IHasTypedDictionaryValues> {
  ITypedDataStorage serializeToDtoStorage(List<T> allEntities);
  List<T> deserializeFromStorage(ITypedDataStorage storage);
}

abstract class IHasTypedDictionaryValues {
  // first we save this to dictionary
  // This should give all the values including children
  Iterable<TypedDictionaryValue> get dictionaryValues;

  
}

enum StoreType {
  int32,
  float32,
  string,
}

class TypedDictionaryValue {
  const TypedDictionaryValue(this.dictionary, this.value);

  final String dictionary;
  final String value;
}

abstract class ITypedDictionaryReadOnly {
  /// name of dictionary and index in dictionary
  String? getValueInDictionary(String name, int value);

  /// name of dictionary and String value in dictionary
  int getIndexInDictionary(String name, String value);
}

abstract class ITypedDictionary implements ITypedDictionaryReadOnly {}

class TypedStringDictionaryCreator {
  final _mapPrepare = <String, Set<String>>{};

  void addValue(TypedDictionaryValue value) {
    (_mapPrepare[value.dictionary] ??= <String>{}).add(value.value);
  }

  void addValues(Iterable<IHasTypedDictionaryValues> values) {
    for (final e in values) {
      e.dictionaryValues.forEach(addValue);
    }
  }

  void addFromStorage(ITypedDataStorage storage) {
    final name = storage.dataString[0];
    final data = storage.dataString.sublist(1);
    _mapPrepare[name] = data.toSet();
  }

  Iterable<ITypedDataStorage> get typedDictionaries =>
      _mapPrepare.entries.map((e) => StringDictionary.create(e.key, e.value));

  Iterable<StringTypedDictionaryMap> dictionaryHelpers(Iterable<ITypedDataStorage> typedDictionaries) =>
      typedDictionaries.map((e) {
        return StringTypedDictionaryMap()..addFromTypedData(e);
      });

  TypedDictionariesStorage getTypedDictionary() {
    final storage = TypedDictionariesStorage();
    for (final e in typedDictionaries) {
      storage.addDictionary(e.dataString[0], e.dataString.sublist(1));
    }
    return storage;
  }
}

class TypedDictionariesStorage implements ITypedDictionary {
  final _dictionaries = <String, ITypedDataStorage>{};
  final _dictionaryMaps = <String, StringTypedDictionaryMap>{};

  Iterable<ITypedDataStorage> get dictionaries => _dictionaries.values;

  void addDictionary(String name, List<String> data) {
    _dictionaries[name] = createDictionary(name, data);
  }

  ITypedDataStorage getDictionary(String name) {
    return _dictionaries[name]!;
  }

  @override
  int getIndexInDictionary(String name, String value) {
    if (!_dictionaryMaps.containsKey(name)) {
      final dictionary = _dictionaries[name];
      assert(dictionary != null, 'Dictionary $name not found');
      if (dictionary == null) return 0;
      _dictionaryMaps[name] = StringTypedDictionaryMap()..addFromTypedData(dictionary);
    }
    final dictionaryMap = _dictionaryMaps[name];
    final resultIdx = dictionaryMap?.getIndex(value) ?? 0;
    assert(resultIdx != 0, '0 is reserved for Dictionary name');
    return resultIdx;
  }

  @override
  String? getValueInDictionary(String name, int value) {
    if (!_dictionaryMaps.containsKey(name)) {
      final dictionary = _dictionaries[name];
      assert(dictionary != null, 'Dictionary $name not found');
      if (dictionary == null) return null;

      _dictionaryMaps[name] = StringTypedDictionaryMap()..addFromTypedData(dictionary);
    }
    final dictionaryMap = _dictionaryMaps[name];
    final result = dictionaryMap?.getValue(value);
    return result;
  }

  static ITypedDataStorage createDictionary(String name, List<String> data) {
    return StringDictionary.create(name, data);
  }
}

class StringTypedDictionaryMap {
  String dictionaryName = '';
  final _map = <String, int>{};
  final _mapReverse = <int, String>{};

  void addFromTypedData(ITypedDataStorage data) {
    assert(StringDictionary.isDictionary(data), 'Data is not a dictionary');
    dictionaryName = data.dataString[0];
    for (var i = 1; i < data.dataString.length; i++) {
      _map[data.dataString[i]] = i;
      _mapReverse[i] = data.dataString[i];
    }
  }

  ITypedDataStorage toTypedData() => StringDictionary.create(
        dictionaryName,
        _map.keys.toList(),
      );

  int? getIndex(String key) {
    return _map[key];
  }

  String? getValue(int index) {
    if (index == 0) return null;
    return _mapReverse[index];
  }
}

class StringDictionary extends TypedFileDataNested {
  StringDictionary({
    required super.dataInt,
    required super.dataDouble,
    required super.dataString,
    required super.children,
  });

  static const _intCodes = <int>[37, 19573, 23583, 96032];
  factory StringDictionary.create(String name, Iterable<String> data) {
    final intCodes = Int32List.fromList(_intCodes);
    return StringDictionary(
      dataInt: intCodes,
      dataDouble: Float32List(0),
      dataString: [name, ...data],
      children: [],
    );
  }
  static bool isDictionary(ITypedDataStorage storage) {
    return sameIntLists(storage.dataInt, _intCodes) && storage.dataDouble.isEmpty && storage.dataString.isNotEmpty;
  }

  static bool sameIntLists(Int32List a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class TypedDynamicStorage {
  TypedDynamicStorage({
    Int32List? intDataRaw,
    Float32List? floatDataRaw,
    List<String>? stringDataRaw,
    List<TypedDynamicStorage>? children,
  }) {
    intData = ListInt32DataWrapper(source: intDataRaw);
    floatData = ListFloat32DataWrapper(source: floatDataRaw);
    stringData = ListStringDataWrapper(source: stringDataRaw);
    this.children = children ?? <TypedDynamicStorage>[];
  }

  factory TypedDynamicStorage.fromSource({ITypedDataStorage? storage}) {
    if (storage != null) {
      return TypedDynamicStorage(
        intDataRaw: storage.dataInt,
        floatDataRaw: storage.dataDouble,
        stringDataRaw: storage.dataString,
        children: storage.children.map((e) => TypedDynamicStorage.fromSource(storage: e)).toList(),
      );
    }
    return TypedDynamicStorage();
  }

  late final ListInt32DataWrapper intData;
  late final ListFloat32DataWrapper floatData;
  late final ListStringDataWrapper stringData;
  late final List<TypedDynamicStorage> children;

  void addChild(TypedDynamicStorage child) {
    children.add(child);
  }

  void addChildFunc(void Function(TypedDynamicStorage) func) {
    final childStorage = TypedDynamicStorage();
    func(childStorage);
    addChild(childStorage);
  }

  ITypedDataStorage toTypedStorage({List<ITypedDataStorage>? children}) {
    final childrenTyped = [...?children, ...this.children.map((e) => e.toTypedStorage())];
    return TypedFileDataNested(
      dataInt: intData.dataShrinked,
      dataDouble: floatData.dataShrinked,
      dataString: stringData.dataShrinked,
      children: childrenTyped,
    );
  }
}

abstract class IListDataWrapper<T, Y> {
  T get data; // list, like Int32List
  T get dataShrinked;

  int get lengthUsed;

  void addData(T data);
  void add(Y value); // value, like int
}

class ListInt32DataWrapper implements IListDataWrapper<Int32List, int> {
  ListInt32DataWrapper({Int32List? source}) {
    if (source != null) {
      addData(source);
    }
  }

  @override
  void add(int value) {
    final lenRequired = _lengthUsed + 1;
    _resizeIfNeeded(lenRequired);
    data[_lengthUsed] = value;
    _lengthUsed = lenRequired;
  }

  @override
  void addData(Int32List data) {
    final lenRequired = _lengthUsed + data.length;
    _resizeIfNeeded(lenRequired);
    data.setAll(_lengthUsed, data);
    _lengthUsed = lenRequired;
  }

  void _resizeIfNeeded(int lengthRequired) {
    if (lengthRequired > data.length) {
      final newData = Int32List(max(lengthRequired * 2, (lengthRequired ~/ 2) * 4))..setAll(0, data);
      data = newData;
    }
  }

  @override
  Int32List data = Int32List(0);

  @override
  Int32List get dataShrinked => Int32List.fromList(data.sublist(0, _lengthUsed));

  @override
  int get lengthUsed => _lengthUsed;
  int _lengthUsed = 0;
}

class ListFloat32DataWrapper implements IListDataWrapper<Float32List, double> {
  ListFloat32DataWrapper({Float32List? source}) {
    if (source != null) {
      addData(source);
    }
  }

  @override
  void add(double value) {
    final lenRequired = _lengthUsed + 1;
    _resizeIfNeeded(lenRequired);
    data[_lengthUsed] = value;
    _lengthUsed = lenRequired;
  }

  @override
  void addData(Float32List data) {
    final lenRequired = _lengthUsed + data.length;
    _resizeIfNeeded(lenRequired);
    data.setAll(_lengthUsed, data);
    _lengthUsed = lenRequired;
  }

  void _resizeIfNeeded(int lengthRequired) {
    if (lengthRequired > data.length) {
      final newData = Float32List(max(lengthRequired * 2, (lengthRequired ~/ 2) * 4))..setAll(0, data);
      data = newData;
    }
  }

  @override
  Float32List data = Float32List(0);

  @override
  Float32List get dataShrinked => Float32List.fromList(data.sublist(0, _lengthUsed));

  @override
  int get lengthUsed => _lengthUsed;
  int _lengthUsed = 0;
}

class ListStringDataWrapper implements IListDataWrapper<List<String>, String> {
  ListStringDataWrapper({List<String>? source}) {
    if (source != null) {
      addData(source);
    }
  }

  @override
  void add(String value) {
    final lenRequired = _lengthUsed + 1;
    _resizeIfNeeded(lenRequired);
    data[_lengthUsed] = value;
    _lengthUsed = lenRequired;
  }

  @override
  void addData(List<String> data) {
    final lenRequired = _lengthUsed + data.length;
    _resizeIfNeeded(lenRequired);
    data.setAll(_lengthUsed, data);
    _lengthUsed = lenRequired;
  }

  void _resizeIfNeeded(int lengthRequired) {
    if (lengthRequired > data.length) {
      final newData = List<String>.filled(max(lengthRequired * 2, (lengthRequired ~/ 2) * 4), '')..setAll(0, data);
      data = newData;
    }
  }

  @override
  List<String> data = <String>[];

  @override
  List<String> get dataShrinked => data.sublist(0, _lengthUsed);

  @override
  int get lengthUsed => _lengthUsed;
  int _lengthUsed = 0;
}
