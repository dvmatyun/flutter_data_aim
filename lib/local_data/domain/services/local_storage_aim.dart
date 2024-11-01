abstract class ILocalStorageAim {
  Future<void> initWarmUp();

  /// [current] version used to save all new data.
  /// [requiredMinimal] is used to check already stored data (returns null if not matched)
  void setVersions({String? current, String? requiredMinimal});

  Future<String?> getString(String key);
  Future<void> setString(String key, String value);

  Future<Map<String, dynamic>?> getJsonVersioned(String key);
  Future<void> setJsonVersioned(String key, Map<String, dynamic> json);

  Future<void> remove(String key);
}
