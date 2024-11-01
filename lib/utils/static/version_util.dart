mixin VersionUtil {
  static int versionValue(String? version) => int.tryParse(version?.replaceAll('.', '') ?? '1') ?? 1;
}
