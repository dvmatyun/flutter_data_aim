import 'package:json_annotation/json_annotation.dart';
part 'analytics_event_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class AnalyticsEventDto {
  final String name;
  final int amount;

  String? str1;
  String? str2;
  String? str3;
  num? num1;
  num? num2;
  num? num3;

  AnalyticsEventDto({
    required this.name,
    required this.amount,
    this.str1,
    this.str2,
    this.str3,
    this.num1,
    this.num2,
    this.num3,
  });

  factory AnalyticsEventDto.fromJson(Map<String, dynamic> json) => _$AnalyticsEventDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsEventDtoToJson(this);
}
