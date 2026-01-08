import 'package:flutter/services.dart';

class IntentsAndroidInterface {
  static const _channel = MethodChannel('yamata.launcher/methods');
  static String aria2cPath = "";
  static String certPath = "";

  static Future<bool?> grantUriPermission(
      String uri, String packageName) async {
    var result = await _channel.invokeMethod<bool>(
        'grantUriPermission', {'uri': uri, 'packageName': packageName});
    print("Intent URI: $result");
    return result;
  }

  static Future<String?> getIntentUri(String filePath) async {
    var result = await _channel
        .invokeMethod<String>('getIntentUriFromFile', {'path': filePath});
    print("Intent URI: $result");
    return result;
  }
}
