import 'package:custom_data/local_data/domain/entities/versioned_data.dart';

class VersionedDataImpl implements IVersionedData {
  const VersionedDataImpl({required this.version, required this.json});

  @override
  final String version;

  @override
  final Map<String, dynamic> json;

  factory VersionedDataImpl.fromJson(Map<String, dynamic> json) => VersionedDataImpl(
        version: json['version'] as String,
        json: json['json'] as Map<String, dynamic>? ?? <String, dynamic>{},
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'json': json,
      };
}
