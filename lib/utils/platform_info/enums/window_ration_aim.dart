enum WindowRatioAim {
  none,
  format16x9,
  format9x16;

  static WindowRatioAim fromString(String value) {
    switch (value) {
      case '16_9':
        return WindowRatioAim.format16x9;
      case '9_16':
        return WindowRatioAim.format9x16;
      default:
        return WindowRatioAim.none;
    }
  }

  String toStringHuman() {
    switch (this) {
      case WindowRatioAim.format16x9:
        return '16:9';
      case WindowRatioAim.format9x16:
        return '9:16';
      default:
        return 'none';
    }
  }

  String toShortString() {
    switch (this) {
      case WindowRatioAim.format16x9:
        return '16_9';
      case WindowRatioAim.format9x16:
        return '9_16';
      default:
        return 'none';
    }
  }
}
