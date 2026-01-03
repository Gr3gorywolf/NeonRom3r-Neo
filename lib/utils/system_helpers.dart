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

  static String getFileExtension(String fileName) {
    return fileName.split('.').last;
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

  static String get SevenZipOutputBinary {
    var sevenZipBinary = "7z";
    if (Platform.isWindows) {
      sevenZipBinary = "7z.exe";
    }
    return sevenZipBinary;
  }

  static String get SevenZipAssetBinary {
    var sevenZipBinary = "7z";
    if (Platform.isWindows) {
      sevenZipBinary = "7z.exe";
    } else if (Platform.isMacOS) {
      sevenZipBinary = "7z-macos";
    } else if (Platform.isLinux) {
      sevenZipBinary = "7z-linux-${isArm ? 'arm' : 'x86'}";
    }
    return sevenZipBinary;
  }
}
