abstract class IExceptionAim implements Exception {
  const IExceptionAim();

  String get code;
  String get title;
  String get message;

  @override
  String toString() => 'Exception: [$title] $message';
}
