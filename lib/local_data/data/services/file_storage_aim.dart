// ignore_for_file: avoid_classes_with_only_static_members, cascade_invocations

import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';

class FileStorageAim {}

final _emptyInt = Int32List(0);
final _emptyFloat = Float32List(0);
const _emptyString = <String>[];
const _emptyChildren = <TypedFileDataNested>[];

class TypedFileDataNested extends TypedFileData {
  const TypedFileDataNested({
    required super.dataInt,
    required super.dataDouble,
    required super.dataString,
    required this.children,
  });

  TypedFileDataNested.intOnly(Int32List dataInt)
      : children = _emptyChildren,
        super(
          dataInt: dataInt,
          dataDouble: _emptyFloat,
          dataString: _emptyString,
        );

  TypedFileDataNested.doubleOnly(Float32List dataDouble)
      : children = _emptyChildren,
        super(
          dataInt: _emptyInt,
          dataDouble: dataDouble,
          dataString: _emptyString,
        );

  TypedFileDataNested.stringOnly(List<String> dataString)
      : children = _emptyChildren,
        super(
          dataInt: _emptyInt,
          dataDouble: _emptyFloat,
          dataString: dataString,
        );

  final List<TypedFileDataNested> children;

  Uint8List toBytes() {
    return TypedFileDataSerializer.toBytes(this);
  }

  static TypedFileDataNested fromBytes(Uint8List bytes) {
    return TypedFileDataSerializer.deserializeTypedFileDataNested(bytes);
  }
}

class TypedFileData {
  const TypedFileData({
    required this.dataInt,
    required this.dataDouble,
    required this.dataString,
  });

  final Int32List dataInt;
  final Float32List dataDouble;
  final List<String> dataString;
}

// Magic bytes to identify the file format (16 bytes)
const List<int> _magicBytes = [
  0x54, 0x46, 0x44, 0x4E, // "TFDN" (TypedFileDataNested)
  0x2A, 0x2B, 0x2C, 0x2D, // Random signature bytes
  0xAA, 0xBB, 0xCC, 0xDD, // More signature bytes
  0x11, 0x22, 0x33, 0x44 // More signature bytes
];

class TypedDataOperations {
  static const int _intBytes = 4;

  static Uint8List intToBytes(int value) {
    const minInt32 = -2147483648; // Minimum signed 32-bit int
    const maxInt32 = 2147483647; // Maximum signed 32-bit int

    if (value < minInt32 || value > maxInt32) {
      throw ArgumentError('Value $value is out of range for a 4-byte integer.');
    }

    final byteData = ByteData(_intBytes)..setInt32(0, value, Endian.little); // Store as little-endian 4 bytes
    return byteData.buffer.asUint8List();
  }
}

class TypedFileDataSerializer {
  // -------------------------
  // 🚀 SERIALIZATION
  // -------------------------

  static Uint8List toBytes(TypedFileDataNested obj) {
    final buffer = BytesBuilder()
      // Add magic bytes (first 16 bytes)
      ..add(_magicBytes);
    final offsetObj = _OffsetObject();
    // Serialize object
    _serializeNested(buffer, obj, offsetObj);

    return buffer.toBytes();
  }

  // ignore: unused_element
  static void _debugPrint(String msg, int bufferLen, _OffsetObject offsetObj) {
    // ignore: avoid_print
    print('$msg, [bytes=$bufferLen], [entityCount=${offsetObj.entitiesCount}], depth=${offsetObj.debugDepth}');
  }

  static void _serializeNested(BytesBuilder buffer, TypedFileDataNested obj, _OffsetObject offsetObj) {
    offsetObj.entityCountAdd();

    // Store INTs
    //_debugPrint('add int', buffer.length, offsetObj);
    final intBytesLength = TypedDataOperations.intToBytes(obj.dataInt.length);
    buffer.add(intBytesLength);

    buffer.add(obj.dataInt.buffer.asUint8List());

    // Store DOUBLES
    //_debugPrint('add double', buffer.length, offsetObj);
    buffer
      ..add(TypedDataOperations.intToBytes(obj.dataDouble.length))
      ..add(obj.dataDouble.buffer.asUint8List());

    // Store STRINGS
    //_debugPrint('add string', buffer.length, offsetObj);
    buffer.add(TypedDataOperations.intToBytes(obj.dataString.length));
    for (final str in obj.dataString) {
      final encodedStr = Uint8List.fromList(utf8.encode(str));
      final emptyBytesCount = 4 - (encodedStr.length % 4);
      buffer
        ..add(TypedDataOperations.intToBytes(encodedStr.length))
        ..add(TypedDataOperations.intToBytes(emptyBytesCount))
        ..add(encodedStr)
        ..add(Uint8List(emptyBytesCount));
    }

    // Store CHILDREN
    //_debugPrint('add children', buffer.length, offsetObj);
    buffer.add(TypedDataOperations.intToBytes(obj.children.length));
    offsetObj.depthAdd();
    //print('adding children ${obj.children.length}, offset= ${buffer.length} depth=${offsetObj.debugDepth}');
    for (final child in obj.children) {
      _serializeNested(buffer, child, offsetObj);
      //_debugPrint('add child', buffer.length, offsetObj);
    }
    //print('added children ${obj.children.length}, offset= ${buffer.length} depth=${offsetObj.debugDepth}');
    offsetObj.depthSub();

    //return buffer.toBytes();
  }

  // -------------------------
  // 🚀 DESERIALIZATION
  // -------------------------
  static TypedFileDataNested deserializeTypedFileDataNested(Uint8List bytes) {
    final buffer = ByteData.sublistView(bytes);
    final offsetObj = _OffsetObject();

    // Validate magic bytes
    final magicCheck = bytes.sublist(0, 16);
    if (!const ListEquality().equals(magicCheck, Uint8List.fromList(_magicBytes))) {
      throw Exception('Invalid file format! Magic bytes do not match.');
    }
    offsetObj.add(16); // Skip magic bytes
    return _deserializeNested(buffer, offsetObj);
  }

  static TypedFileDataNested _deserializeNested(ByteData buffer, _OffsetObject offsetObj) {
    offsetObj.entityCountAdd();
    int offset() => offsetObj.offset;

    int readInt32() {
      final value = buffer.getUint32(offset(), Endian.little);
      offsetObj.add(4);
      return value;
    }

    // Read INTs
    //_debugPrint('read int', offsetObj.offset, offsetObj);
    final intLen = readInt32();
    final intData = buffer.buffer.asInt32List(offset(), intLen);
    offsetObj.add(intLen * 4);

    // Read DOUBLES
    //_debugPrint('read double', offsetObj.offset, offsetObj);
    final doubleLen = readInt32();

    final doubleData = buffer.buffer.asFloat32List(offset(), doubleLen);

    offsetObj.add(doubleLen * 4);

    // Read STRINGS
    //_debugPrint('read string', offsetObj.offset, offsetObj);
    final stringLen = readInt32();

    final stringData = <String>[];
    for (var i = 0; i < stringLen; i++) {
      final strLength = readInt32();
      final emptyBytes = readInt32();
      final str = utf8.decode(buffer.buffer.asUint8List(offset(), strLength));
      stringData.add(str);
      assert((strLength + emptyBytes) / 4 == (strLength + emptyBytes) ~/ 4, 'Offset must be divisible by 4');
      offsetObj.add(strLength + emptyBytes);
    }

    // Read CHILDREN
    //_debugPrint('read children', offsetObj.offset, offsetObj);
    final childrenLen = readInt32();

    final children = <TypedFileDataNested>[];
    offsetObj.depthAdd();

    for (var i = 0; i < childrenLen; i++) {
      children.add(_deserializeNested(buffer, offsetObj));
    }

    offsetObj.depthSub();

    return TypedFileDataNested(
      dataInt: intData,
      dataDouble: doubleData,
      dataString: stringData,
      children: children,
    );
  }
}

class _OffsetObject {
  int offset = 0;
  void add(int value) {
    assert(value / 4 == value ~/ 4, 'Offset must be divisible by 4');
    offset += value;
  }

  int debugDepth = 0;
  void depthAdd() => debugDepth++;
  void depthSub() => debugDepth--;

  int entitiesCount = 0;
  void entityCountAdd() => entitiesCount++;
}
