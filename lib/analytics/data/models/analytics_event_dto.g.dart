// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsEventDto _$AnalyticsEventDtoFromJson(Map<String, dynamic> json) => AnalyticsEventDto(
      name: json['name'] as String,
      amount: (json['amount'] as num).toInt(),
      str1: json['str1'] as String?,
      str2: json['str2'] as String?,
      str3: json['str3'] as String?,
      num1: json['num1'] as num?,
      num2: json['num2'] as num?,
      num3: json['num3'] as num?,
    );

Map<String, dynamic> _$AnalyticsEventDtoToJson(AnalyticsEventDto instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'amount': instance.amount,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('str1', instance.str1);
  writeNotNull('str2', instance.str2);
  writeNotNull('str3', instance.str3);
  writeNotNull('num1', instance.num1);
  writeNotNull('num2', instance.num2);
  writeNotNull('num3', instance.num3);
  return val;
}
