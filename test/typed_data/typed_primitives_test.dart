//ListInt32DataWrapperimport 'dart:math';
import 'dart:typed_data';

import 'package:custom_data/custom_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';

void main() {
  test(
    'ListInt32DataWrapper tests',
    () {
      final intStorage = ListInt32DataWrapper();
      intStorage.add(3);
      intStorage.add(1);
      intStorage.add(2);
      intStorage.add(3);
      intStorage.addData(Int32List.fromList([31, 43, 54]));
      

      expect(intStorage.lengthUsed == 7, true);
    },
  );
}
