import 'dart:io';

class SystemHelpers {
  static bool get isArm {
    return Platform.version.toLowerCase().contains("arm") ||
        Platform.version.toLowerCase().contains("aarch64");
  }

  static String get aria2cOutputBinary {
    var binary = "aria2c";
    if (Platform.isWindows) {
      binary = "aria2c.exe";
    }
    return binary;
  }

  static String get aria2cAssetBinary {
    var aria2cBinary = "aria2c";
    if (Platform.isWindows) {
      aria2cBinary = "aria2c.exe";
    } else if (Platform.isMacOS) {
      aria2cBinary = "aria2c-macos-${isArm ? 'arm' : 'x86'}";
    } else if (Platform.isLinux) {
      aria2cBinary = "aria2c-linux-${isArm ? 'arm' : 'x86'}";
    } else if (Platform.isAndroid) {
      aria2cBinary = "aria2c-android";
    }
    return aria2cBinary;
  }
}
