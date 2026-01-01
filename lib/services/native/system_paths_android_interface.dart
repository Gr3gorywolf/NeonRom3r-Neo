import 'package:flutter/services.dart';

class SystemPaths {
  String? externalSdCardPath;
  String internalPath;
  String? downloadsPath;
  String? documentsPath;
  SystemPaths({
    required this.externalSdCardPath,
    required this.internalPath,
    required this.downloadsPath,
    required this.documentsPath,
  });
}

class SystemPathsAndroidInterface {
  static const _channel = MethodChannel('yamata.launcher/methods');

  static Future<SystemPaths> getSystemPaths() async {
    var result = await _channel.invokeMethod<Map>('getSystemPaths');
    print("System Paths: $result");
    return SystemPaths(
      externalSdCardPath: result?['externalSdCardPath'],
      internalPath: result?['internalPath'] ?? "",
      downloadsPath: result?['downloadsPath'],
      documentsPath: result?['documentsPath'],
    );
  }
}
