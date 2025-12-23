import 'package:neonrom3r/constants/settings_constants.dart';
import 'package:neonrom3r/models/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<T> get<T>(SettingsKeys key) async {
    final prefs = await SharedPreferences.getInstance();
    final definition = settingsRegistry[key]!;

    switch (definition.type) {
      case SettingType.bool:
        return (prefs.getBool(definition.key) ?? definition.defaultValue) as T;

      case SettingType.int:
        return (prefs.getInt(definition.key) ?? definition.defaultValue) as T;

      case SettingType.double:
        return (prefs.getDouble(definition.key) ?? definition.defaultValue)
            as T;

      case SettingType.string:
        return (prefs.getString(definition.key) ?? definition.defaultValue)
            as T;
    }
  }

  Future<void> set<T>(SettingsKeys key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    final definition = settingsRegistry[key]!;

    switch (definition.type) {
      case SettingType.bool:
        await prefs.setBool(definition.key, value as bool);
        break;

      case SettingType.int:
        await prefs.setInt(definition.key, value as int);
        break;

      case SettingType.double:
        await prefs.setDouble(definition.key, value as double);
        break;

      case SettingType.string:
        await prefs.setString(definition.key, value as String);
        break;
    }
  }
}
