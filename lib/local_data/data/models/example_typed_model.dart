import 'package:custom_data/local_data/data/models/typed_file_data_nested.dart';
import 'package:custom_data/local_data/data/models/typed_file_data_storage.dart';

class ExampleEntityParentModel implements IHasTypedDictionaryValues {
  ExampleEntityParentModel({
    required this.id,
    required this.name,
    required this.children,
  });

  factory ExampleEntityParentModel.deserializeStorageSingle(ITypedDictionaryReadOnly d, ITypedDataStorage s) {
    final id = s.dataInt[0];
    final name = d.getValueInDictionary('name', s.dataInt[1]);
    final children = ExampleEntityChildModel.deserializeStorageList(d, s);
    return ExampleEntityParentModel(id: id, name: name ?? '', children: children);
  }

  final int id;
  final String name;
  final List<ExampleEntityChildModel> children;

  @override
  Iterable<TypedDictionaryValue> get dictionaryValues sync* {
    yield TypedDictionaryValue('name', name);
    yield* children.expand((element) => element.dictionaryValues);
  }

  bool isEqual(ExampleEntityParentModel other) {
    if (id != other.id || name != other.name) {
      return false;
    }
    if (children.length != other.children.length) {
      return false;
    }
    for (var i = 0; i < children.length; i++) {
      if (!children[i].isEqual(other.children[i])) {
        return false;
      }
    }

    return true;
  }

  static const String _storageKey = 'enp';
  static bool isContainedInStorage(ITypedDataStorage storage) {
    return storage.dataString.length == 1 && storage.dataString[0] == _storageKey;
  }

  static void serializeStorageList(
    ITypedDictionaryReadOnly dictionary,
    TypedDynamicStorage builder,
    List<ExampleEntityParentModel> entities,
  ) {
    // adding identifier (to save some space and not to repeat the same string for each entity):
    builder.stringData.add(_storageKey);
    // adding each entity to it's own storage
    for (final e in entities) {
      builder.addChildFunc((b) => e.serializeStorageSingle(dictionary, b));
    }
  }

  // Add bytes for this object and all children
  static const int _intLength = 2;
  void serializeStorageSingle(
    ITypedDictionaryReadOnly dictionary,
    TypedDynamicStorage builder,
  ) {
    builder.intData.add(id);
    builder.intData.add(dictionary.getIndexInDictionary('name', name));
    // insert children:
    builder.addChildFunc((b) => ExampleEntityChildModel.serializeStorageList(dictionary, b, children));
  }

  static List<ExampleEntityParentModel> deserializeStorageList(
    ITypedDictionaryReadOnly dictionary,
    ITypedDataStorage storage,
  ) {
    final result = <ExampleEntityParentModel>[];
    final storages = storage.children.where(isContainedInStorage).toList();
    for (final s in storages.expand((v) => v.children)) {
      assert(s.dataInt.length == _intLength, 'Invalid storage type for ExampleEntityParentModel model');
      result.add(ExampleEntityParentModel.deserializeStorageSingle(dictionary, s));
    }

    return result;
  }
}

class ExampleEntityChildModel implements IHasTypedDictionaryValues {
  ExampleEntityChildModel({
    required this.id,
    required this.x,
    required this.y,
    required this.name,
    this.children = const <ExampleEntityChildModel>[],
  });

  factory ExampleEntityChildModel.deserializeStorageSingle(ITypedDictionaryReadOnly d, ITypedDataStorage s) {
    final id = s.dataInt[0];
    final x = s.dataInt[1];
    final y = s.dataInt[2];
    final name = d.getValueInDictionary('name', s.dataInt[3]);

    final children = ExampleEntityChildModel.deserializeStorageList(d, s);

    return ExampleEntityChildModel(id: id, x: x, y: y, name: name ?? '', children: children);
  }

  final int id;
  final int x;
  final int y;
  final String name;

  final List<ExampleEntityChildModel> children;

  @override
  Iterable<TypedDictionaryValue> get dictionaryValues sync* {
    yield TypedDictionaryValue('name', name);
  }

  bool isEqual(ExampleEntityChildModel other) {
    if (id != other.id || name != other.name || x != other.x || y != other.y) {
      return false;
    }
    if (children.length != other.children.length) {
      return false;
    }
    for (var i = 0; i < children.length; i++) {
      if (!children[i].isEqual(other.children[i])) {
        return false;
      }
    }

    return true;
  }

  static const int _intLength = 4;
  void serializeStorageSingle(ITypedDictionaryReadOnly dictionary, TypedDynamicStorage builder) {
    // inserting data:
    builder.intData
      ..add(id)
      ..add(x)
      ..add(y)
      ..add(dictionary.getIndexInDictionary('name', name));

    // insert children:
    builder.addChildFunc((b) => ExampleEntityChildModel.serializeStorageList(dictionary, b, children));
  }

  static const String _storageKey = 'enc';
  static bool isContainedInStorage(ITypedDataStorage storage) {
    return storage.dataString.length == 1 && storage.dataString[0] == _storageKey;
  }

  static void serializeStorageList(
    ITypedDictionaryReadOnly dictionary,
    TypedDynamicStorage builder,
    List<ExampleEntityChildModel> entities,
  ) {
    // adding identifier:
    builder.stringData.add(_storageKey);
    // adding children
    for (final e in entities) {
      builder.addChildFunc((b) => e.serializeStorageSingle(dictionary, b));
    }
  }

  static List<ExampleEntityChildModel> deserializeStorageList(
    ITypedDictionaryReadOnly dictionary,
    ITypedDataStorage storage,
  ) {
    final result = <ExampleEntityChildModel>[];
    final storages = storage.children.where(isContainedInStorage).toList();
    for (final s in storages.expand((v) => v.children)) {
      assert(s.dataInt.length == _intLength, 'Invalid storage type for ExampleEntityParentModel model');
      result.add(ExampleEntityChildModel.deserializeStorageSingle(dictionary, s));
    }

    return result;
  }
}

class ExampleDtoParentModel {
  ExampleDtoParentModel({
    required this.id,
    required this.nameIdx,
    required this.children,
  });

  final int id;
  final int nameIdx;
  final List<ExampleEntityChildModel> children;
}

class ExampleDtoChildModel {
  ExampleDtoChildModel({
    required this.id,
    required this.x,
    required this.y,
    required this.nameIdx,
  });

  final int id;
  final int x;
  final int y;
  final int nameIdx;
}

class ExampleSerializer implements ITypedDataSerializer<ExampleEntityParentModel> {
  static const intLength = 2;

  @override
  ITypedDataStorage serializeToDtoStorage(List<ExampleEntityParentModel> allEntities) {
    final helperDictionary = TypedStringDictionaryCreator()..addValues(allEntities);
    final dictionary = helperDictionary.getTypedDictionary();

    final builder = TypedDynamicStorage()
      ..addChildFunc((b) => ExampleEntityParentModel.serializeStorageList(dictionary, b, allEntities));

    final dictionariesToSave = dictionary.dictionaries.toList();

    return builder.toTypedStorage(children: dictionariesToSave);
  }

  @override
  List<ExampleEntityParentModel> deserializeFromStorage(ITypedDataStorage storage) {
    final helperDictionary = TypedStringDictionaryCreator();
    final dictionariesFound = storage.children.where(StringDictionary.isDictionary).toList();
    // ignore: cascade_invocations
    dictionariesFound.forEach(helperDictionary.addFromStorage);
    final dictionary = helperDictionary.getTypedDictionary();

    final result = ExampleEntityParentModel.deserializeStorageList(dictionary, storage);
    /*
    final result = <ExampleEntityParentModel>[];

    for (var i = 0; i < storage.dataInt.length; i += intLength) {
      final id = storage.dataInt[i + 0];
      final name = dictionary.getValueInDictionary('name', storage.dataInt[i + 1]);
      final children = <ExampleEntityChildModel>[];

      result.add(ExampleEntityParentModel(id: id, name: name ?? '', children: children));
    }
    */

    return result;
  }
}
