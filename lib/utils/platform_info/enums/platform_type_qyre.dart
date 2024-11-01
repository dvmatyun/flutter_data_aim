enum PlatformTypeMw {
  ios,
  android,
  web,
  windows,
  unknown;

  bool get isDesktop => this == PlatformTypeMw.windows;
  bool get isMobile => {PlatformTypeMw.ios, PlatformTypeMw.android}.contains(this);

  bool get supportsFirebase => {PlatformTypeMw.ios, PlatformTypeMw.android, PlatformTypeMw.web}.contains(this);
}
