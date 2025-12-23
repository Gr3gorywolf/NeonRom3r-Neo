import 'package:neonrom3r/models/setting.dart';

enum SettingsKeys {
  DOWNLOAD_PATH,
  PREFIX_CONSOLE_SLUG,
  ENABLE_IMAGE_CACHING,
  ENABLE_NOTIFICATIONS
}

Map<SettingsKeys, Setting> settingsRegistry = {
  SettingsKeys.DOWNLOAD_PATH: Setting<String>(
    key: 'dark_mode',
    type: SettingType.string,
    defaultValue: "",
  ),
  SettingsKeys.PREFIX_CONSOLE_SLUG: Setting<bool>(
    key: 'prefix_console_slug',
    type: SettingType.bool,
    defaultValue: false,
  ),
  SettingsKeys.ENABLE_IMAGE_CACHING: Setting<bool>(
    key: 'enable_image_caching',
    type: SettingType.bool,
    defaultValue: false,
  ),
  SettingsKeys.ENABLE_NOTIFICATIONS: Setting<bool>(
    key: 'enable_notifications',
    type: SettingType.bool,
    defaultValue: true,
  ),
};
