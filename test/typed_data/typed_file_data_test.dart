import 'dart:math';
import 'dart:typed_data';

import 'package:custom_data/local_data/data/services/file_storage_aim.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';

void main() {
  test(
    'Typed file data short INT Serialization tests',
    () {
      final intList = Int32List.fromList(
        [1, 2, 3, 4, 5],
      );
      final data = TypedFileDataNested.intOnly(intList);
      final serialized = data.toBytes();
      final deserialized = TypedFileDataNested.fromBytes(serialized);

      final intListDeserialized = deserialized.dataInt;
      final isSame = const ListEquality().equals(intList, intListDeserialized);

      expect(isSame, true);
    },
  );

  test(
    'Typed file data short DOUBLE Serialization tests',
    () {
      final doubleList = Float32List.fromList(
        [1.1, 2.3, 3.3, 4.7, 5],
      );
      final data = TypedFileDataNested.doubleOnly(doubleList);
      final serialized = data.toBytes();
      final deserialized = TypedFileDataNested.fromBytes(serialized);

      final doubleListDeserialized = deserialized.dataDouble;
      final isSame = const ListEquality().equals(doubleList, doubleListDeserialized);

      expect(isSame, true);
    },
  );

  test(
    'Typed file data short STRING Serialization tests',
    () {
      final stringList = <String>['One', 'Two', 'Three', 'Four', 'Five'];
      final data = TypedFileDataNested.stringOnly(stringList);
      final serialized = data.toBytes();
      final deserialized = TypedFileDataNested.fromBytes(serialized);

      final dataString = deserialized.dataString;
      final isSame = const ListEquality().equals(stringList, dataString);

      expect(isSame, true);
    },
  );

  test(
    'Typed file data long INT Serialization tests',
    () {
      final intRaw = <int>[1, 2, 3, 4, 5];
      for (var i = 0; i < 100; i++) {
        for (var j = 0; j < 100; j++) {
          intRaw.add((i + j) * (j + 2 * i));
        }
      }
      final intList = Int32List.fromList(intRaw);

      final data = TypedFileDataNested.intOnly(intList);
      final serialized = data.toBytes();
      final deserialized = TypedFileDataNested.fromBytes(serialized);

      final intListDeserialized = deserialized.dataInt;
      final isSame = const ListEquality().equals(intList, intListDeserialized);

      expect(isSame, true);
    },
  );

  test(
    'Typed file data long DOUBLE Serialization tests',
    () {
      final doubleRaw = <double>[1.1, 2.3, 3.3, 4.7, 5];

      for (var i = 0; i < 100; i++) {
        for (var j = 0; j < 100; j++) {
          doubleRaw.add((i + j) * (j + 2 * i) * 0.1);
        }
      }

      final doubleList = Float32List.fromList(doubleRaw);

      final data = TypedFileDataNested.doubleOnly(doubleList);
      final serialized = data.toBytes();
      final deserialized = TypedFileDataNested.fromBytes(serialized);

      final doubleListDeserialized = deserialized.dataDouble;
      final isSame = const ListEquality().equals(doubleList, doubleListDeserialized);

      expect(isSame, true);
    },
  );

  test(
    'Typed file data long STRING Serialization tests',
    () {
      final listSource = <String>['assets', 'item_test.png', 'another-test.png', 'folder_name', 'test'];
      final stringList = <String>['One', 'Two', 'Three', 'Four', 'Five'];
      for (var i = 0; i < 1000; i++) {
        final sb = StringBuffer();
        for (var j = 0; j < 20; j++) {
          sb.write('/${listSource[(i + j) % 5]}');
        }
        stringList.add(sb.toString());
      }

      final data = TypedFileDataNested.stringOnly(stringList);
      final serialized = data.toBytes();
      final deserialized = TypedFileDataNested.fromBytes(serialized);

      final dataString = deserialized.dataString;
      final isSame = const ListEquality().equals(stringList, dataString);

      expect(isSame, true);
    },
  );

  test(
    'Typed file data with all attributes',
    () {
      final stringList = <String>['One', 'Two', 'Three', 'Four', 'Five'];
      final doubleRaw = <double>[1.1, 2.3, 3.3, 4.7, 5];
      final intRaw = <int>[1, 2, 3, 4, 5];

      TypedFileDataNested generateTypedData(int idx, {int childrenAmount = 0, int childrenDepth = 0}) {
        final children = <TypedFileDataNested>[];
        for (var i = 0; i < childrenAmount; i++) {
          children.add(
            generateTypedData(
              (i + idx) * (childrenDepth + 1),
              childrenAmount: childrenDepth,
              childrenDepth: childrenDepth - 1,
            ),
          );
        }
        final stringLocal = <String>[];
        final doubleLocal = <double>[];
        final intLocal = <int>[];

        for (var i = 0; i < max((idx + 37) * idx, 1024); i++) {
          stringLocal.add(stringList[(i + idx) % stringList.length]);
          doubleLocal.add(doubleRaw[(i + idx) % doubleRaw.length]);
          intLocal.add(intRaw[(i + idx) % intRaw.length]);
        }
        return TypedFileDataNested(
          dataInt: Int32List.fromList(intLocal),
          dataDouble: Float32List.fromList(doubleLocal),
          dataString: stringLocal,
          children: children,
        );
      }

      void compareData(TypedFileDataNested source, TypedFileDataNested target) {
        final isSameInt = const ListEquality().equals(source.dataInt, target.dataInt);
        final isSameDouble = const ListEquality().equals(source.dataDouble, target.dataDouble);
        final isSameStr = const ListEquality().equals(source.dataString, target.dataString);
        expect(isSameInt, true);
        expect(isSameDouble, true);
        expect(isSameStr, true);
      }

      TypedFileDataNested serializeAndBack(TypedFileDataNested source){
        final serialized = source.toBytes();
        final deserialized = TypedFileDataNested.fromBytes(serialized);
        return deserialized;
      }

      final noChild = generateTypedData(0);
      compareData(noChild, serializeAndBack(noChild));
      final oneChild = generateTypedData(1, childrenAmount: 1, childrenDepth: 0);
      compareData(oneChild, serializeAndBack(oneChild));
      final twoChildInDepth = generateTypedData(2, childrenAmount: 2, childrenDepth: 1);
      compareData(twoChildInDepth, serializeAndBack(twoChildInDepth));
    },
  );
}
