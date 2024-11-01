// ignore: one_member_abstracts
abstract class ILoggerImportantAim {
  void logImportant(String key, String message);
  void logError(String key, String message);

  void logImportantMultiple(String key, String message, {String? step, String? amount});
}
