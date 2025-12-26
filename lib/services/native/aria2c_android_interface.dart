import 'package:flutter/services.dart';

class Aria2cAndroidInterface {
  static const _channel = MethodChannel('yamata.launcher/methods');
  static String aria2cPath = "";
  static String certPath = "";

  static Future<void> init() async {
    var result = await _channel.invokeMethod('initAria2c');
    aria2cPath = result['binaryPath'];
    certPath = result['certPath'];
  }
}
