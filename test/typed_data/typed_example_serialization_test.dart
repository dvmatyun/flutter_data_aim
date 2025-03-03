import 'package:custom_data/custom_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Typed example model serialization and deseralization test (no children)',
    () {
      final modelsList = [
        ExampleEntityParentModel(
          id: 1,
          name: 'abc/defs',
          children: [],
        ),
        ExampleEntityParentModel(
          id: 2,
          name: 'test',
          children: [],
        ),
        ExampleEntityParentModel(
          id: 3,
          name: 'test',
          children: [],
        ),
        ExampleEntityParentModel(
          id: 2,
          name: 'abc',
          children: [],
        ),
        ExampleEntityParentModel(
          id: 2,
          name: 'abc/defs',
          children: [],
        ),
      ];

      final serializer = ExampleSerializer();

      final typedData = serializer.serializeToDtoStorage(modelsList);
      final deserialized = serializer.deserializeFromStorage(typedData);
      expect(modelsList.length == deserialized.length, true, reason: 'Lengths are not equal');

      for (var i = 0; i < modelsList.length; i++){
        final model = modelsList[i];
        final deserializedModel = deserialized[i];

        expect(model.isSame(deserializedModel), true, reason: 'Models are not the same (i=$i)');
      } 
      
      
    },
  );
}
