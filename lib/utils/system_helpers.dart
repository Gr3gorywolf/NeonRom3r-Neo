import 'dart:io';

class SystemHelpers {
  static bool get isArm {
    return Platform.version.toLowerCase().contains("arm") ||
        Platform.version.toLowerCase().contains("aarch64");
  }

  static String get aria2cBinary {
    var aria2cBinary = "aria2c";
    if (Platform.isWindows) {
      aria2cBinary = "aria2c.exe";
    } else if ((Platform.isMacOS || Platform.isLinux) && SystemHelpers.isArm) {
      aria2cBinary = "aria2c-unix-arm";
    }
    return aria2cBinary;
  }
}
