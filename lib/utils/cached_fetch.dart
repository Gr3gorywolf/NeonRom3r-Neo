import 'dart:convert';
import 'package:neonrom3r/models/contracts/json_serializable.dart';
import 'package:neonrom3r/services/cache_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class CachedFetch {
  static _getFullkey(String key) {
    return "fetch-cache/" + key;
  }

  // Object fetcher
  static Future<T?> object<T extends JsonSerializable>({
    required String key,
    required Future<T?> Function() fetcher,
    required FromJson<T> fromJson,
    Duration? ttl,
  }) async {
    try {
      final cached = await CacheService.retrieveCacheFile(_getFullkey(key));
      if (cached != null) {
        return fromJson(json.decode(cached));
      }

      final result = await fetcher();
      if (result == null) return null;

      await CacheService.writeCacheFile(
        _getFullkey(key),
        json.encode(result.toJson()),
        ttl: ttl,
      );

      return result;
    } catch (e, st) {
      print('CachedFetch<object> [$key]: $e');
      print(st);
      return null;
    }
  }

  // List fetcher
  static Future<List<T>> list<T extends JsonSerializable>({
    required String key,
    required Future<List<T>> Function() fetcher,
    required FromJson<T> fromJson,
    Duration? ttl,
  }) async {
    try {
      final cached = await CacheService.retrieveCacheFile(_getFullkey(key));
      if (cached != null) {
        final decoded = json.decode(cached) as List;
        return decoded.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }

      final result = await fetcher();

      await CacheService.writeCacheFile(
        _getFullkey(key),
        json.encode(result.map((e) => e.toJson()).toList()),
        ttl: ttl,
      );

      return result;
    } catch (e, st) {
      print('CachedFetch<list> [$key]: $e');
      print(st);
      return [];
    }
  }
}
