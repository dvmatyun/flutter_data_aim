extension StringExtension on String {
  String capitalizeFirst() => '${this[0].toUpperCase()}${substring(1)}';
  String lowerFirst() => '${this[0].toLowerCase()}${substring(1)}';
  String addColon() => '$this: ';
  String wrapBraces() => '($this)';
}
