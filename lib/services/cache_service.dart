import 'dart:io';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _signaturePrefix = "cache-signature-";
  static const _expiryPrefix = "cache-expiry-";

  static Future<String?> getCacheSignature(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_signaturePrefix + key);
  }

  static Future<void> setCacheSignature(String key, String signature) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signaturePrefix + key, signature);
  }

  static Future<void> writeCacheFile(
    String fileName,
    String content, {
    Duration? ttl,
  }) async {
    final file = File("${FileSystemService.cachePath}/$fileName");
    await file.writeAsString(content);

    if (ttl != null) {
      final prefs = await SharedPreferences.getInstance();
      final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;

      await prefs.setInt(_expiryPrefix + fileName, expiry);
    }
  }

  static Future<String?> retrieveCacheFile(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    final file = File("${FileSystemService.cachePath}/$fileName");

    if (!file.existsSync()) {
      _removeExpiry(fileName);
      return null;
    }

    final expiry = prefs.getInt(_expiryPrefix + fileName);

    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      await _invalidate(fileName);
      return null;
    }

    return await file.readAsString();
  }

  static Future<void> invalidate(String fileName) async {
    await _invalidate(fileName);
  }

  static Future<void> _invalidate(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    final file = File("${FileSystemService.cachePath}/$fileName");

    if (file.existsSync()) {
      await file.delete();
    }

    await prefs.remove(_expiryPrefix + fileName);
    await prefs.remove(_signaturePrefix + fileName);
  }

  static Future<void> _removeExpiry(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expiryPrefix + fileName);
  }
}
