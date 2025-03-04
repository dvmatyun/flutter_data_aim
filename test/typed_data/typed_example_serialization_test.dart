import 'package:custom_data/custom_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Serialization and deserialization of example models',
    () {
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

          for (var i = 0; i < modelsList.length; i++) {
            final model = modelsList[i];
            final deserializedModel = deserialized[i];

            expect(model.isEqual(deserializedModel), true, reason: 'Models are not the same (i=$i)');
          }
        },
      );

      test(
        'Typed example model serialization and deseralization test (with children)',
        () {
          final modelsList = [
            ExampleEntityParentModel(
              id: 1,
              name: 'abc/defs',
              children: [
                ExampleEntityChildModel(
                  id: 1,
                  x: 1,
                  y: 2,
                  name: 'test1',
                  children: [
                    ExampleEntityChildModel(
                      id: 2,
                      x: 3,
                      y: 4,
                      name: 'test2',
                      children: [
                        ExampleEntityChildModel(
                          id: 3,
                          x: 5,
                          y: 6,
                          name: 'test3',
                          children: [],
                        )
                      ],
                    )
                  ],
                ),
                ExampleEntityChildModel(
                  id: 2,
                  x: 3,
                  y: 4,
                  name: 'test2',
                  children: [],
                ),
                ExampleEntityChildModel(
                  id: 3,
                  x: 5,
                  y: 6,
                  name: 'test3',
                  children: [],
                ),
              ],
            ),
            ExampleEntityParentModel(
              id: 2,
              name: 'test',
              children: [
                ExampleEntityChildModel(
                  id: 2,
                  x: 3,
                  y: 4,
                  name: 'test2',
                  children: [],
                ),
                ExampleEntityChildModel(
                  id: 3,
                  x: 5,
                  y: 6,
                  name: 'test3',
                  children: [],
                ),
              ],
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

          for (var i = 0; i < modelsList.length; i++) {
            final model = modelsList[i];
            final deserializedModel = deserialized[i];

            expect(model.isEqual(deserializedModel), true, reason: 'Models are not the same (i=$i) (with children)');
          }
        },
      );
    },
  );
}
