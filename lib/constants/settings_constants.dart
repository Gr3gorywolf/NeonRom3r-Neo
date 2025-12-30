import 'package:yamata_launcher/models/setting.dart';
import 'package:yamata_launcher/services/files_system_service.dart';

enum SettingsKeys {
  DOWNLOAD_PATH,
  PREFIX_CONSOLE_SLUG,
  ENABLE_IMAGE_CACHING,
  ENABLE_NOTIFICATIONS,
  ENABLE_EXTRACTION,
  MAX_CONCURRENT_EXTRACTIONS
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
  SettingsKeys.ENABLE_EXTRACTION: Setting<bool>(
    key: 'enable_extraction',
    type: SettingType.bool,
    defaultValue: true,
  ),
  SettingsKeys.MAX_CONCURRENT_EXTRACTIONS: Setting<int>(
    key: 'max_concurrent_extractions',
    type: SettingType.int,
    defaultValue: FileSystemService.isDesktop ? 4 : 2,
  ),
};
