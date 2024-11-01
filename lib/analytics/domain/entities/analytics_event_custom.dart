class AnalyticsEventCustom {
  final String name;
  final int amount;
  final Map<String, Object?>? params;

  const AnalyticsEventCustom({
    required this.name,
    required this.params,
    required this.amount,
  });

  String get key => '$name-${params?.values.join(',')}';

  AnalyticsEventCustom increment() => AnalyticsEventCustom(
        name: name,
        params: params,
        amount: amount + 1,
      );
}
