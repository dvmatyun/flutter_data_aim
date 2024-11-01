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

enum AnalyticEvent {
  initialLoading('initial_loading'),
  codeUsed('code_used'),
  menuTabClicked('menu_tab_clicked'),
  buyUsingCoins('buy_using_coins'),
  buyUsingValor('buy_using_valor'),
  errorAim('error_aim'),
  emailSignIn('email_sign_in'),
  purchaseStatusChanged('purchase_status_changed'),
  purchaseRealShop('purchase_real_shop'),
  purchaseRealShopError('purchase_real_shop_error'),
  purchaseCompleteRealShop('purchase_real_shop'),
  purchaseCompleteRealShopError('purchase_complete_real_shop_error'),
  levelStarted('level_started_aim'),
  levelCompleted('level_completed_aim'),
  levelLost('level_lost_aim'),
  impLevelCompletedFirstTime('imp_level_completed_first_time_aim'),
  signIn('sign_in_aim'),
  signInMethod('sign_in_method_aim'),
  adWatchedRewarded('ad_watched_rewarded_aim'),
  adRewarded('ad_rewarded_aim'),
  ;

  const AnalyticEvent(this.fbValue);
  final String fbValue;
}

enum AnalyticParameterType {
  place('place_aim'), // Place on the screen where it was done
  platform('platform_aim'),
  key('key_aim'),
  additionalInfo('add_info_aim'),
  stepAim('step_aim'),
  amount('amount_aim'),
  ;

  const AnalyticParameterType(this.fbValue);
  final String fbValue;
}

enum AnalyticKeys {
  unknown('unknown'),
  google('google'),
  custom('custom'),
  ;

  const AnalyticKeys(this.fbValue);
  final String fbValue;
}
