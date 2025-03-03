import 'dart:typed_data';

import 'package:custom_data/local_data/data/models/typed_file_data_nested.dart';
import 'package:custom_data/local_data/data/models/typed_file_data_storage.dart';

class ExampleEntityParentModel implements IHasTypedDictionaryValues {
  ExampleEntityParentModel({
    required this.id,
    required this.name,
    required this.children,
  });

  final int id;
  final String name;
  final List<ExampleEntityChildModel> children;

  @override
  Iterable<TypedDictionaryValue> get dictionaryValues sync* {
    yield TypedDictionaryValue('name', name);
    yield* children.expand((element) => element.dictionaryValues);
  }

  bool isSame(ExampleEntityParentModel other) {
    if (id != other.id || name != other.name) {
      return false;
    }
    if (children.length != other.children.length) {
      return false;
    }

    return true;
  }
}

class ExampleEntityChildModel implements IHasTypedDictionaryValues {
  ExampleEntityChildModel({
    required this.id,
    required this.x,
    required this.y,
    required this.name,
  });

  final int id;
  final int x;
  final int y;
  final String name;

  @override
  Iterable<TypedDictionaryValue> get dictionaryValues sync* {
    yield TypedDictionaryValue('name', name);
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

    final int32 = Int32List(intLength * allEntities.length);
    for (var i = 0; i < allEntities.length; i += 1) {
      final j = i * intLength;
      final e = allEntities[i];
      int32[j + 0] = e.id;
      int32[j + 1] = dictionary.getIndexInDictionary('name', e.name);
    }

    final dictionariesToSave = dictionary.dictionaries.toList();
    final result = TypedFileDataNested.intOnly(int32, children: dictionariesToSave);

    return result;
  }

  @override
  List<ExampleEntityParentModel> deserializeFromStorage(ITypedDataStorage storage) {
    final helperDictionary = TypedStringDictionaryCreator();
    final dictionariesFound = storage.children.where(StringDictionary.isDictionary).toList();
    // ignore: cascade_invocations
    dictionariesFound.forEach(helperDictionary.addFromStorage);
    final dictionary = helperDictionary.getTypedDictionary();
    final result = <ExampleEntityParentModel>[];

    for (var i = 0; i < storage.dataInt.length; i += intLength) {
      final id = storage.dataInt[i + 0];
      final name = dictionary.getValueInDictionary('name', storage.dataInt[i + 1]);
      final children = <ExampleEntityChildModel>[];

      result.add(ExampleEntityParentModel(id: id, name: name ?? '', children: children));
    }

    return result;
  }
}
