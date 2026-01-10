import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yamata_launcher/constants/settings_constants.dart';
import 'package:yamata_launcher/repository/emulator_intents_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:yamata_launcher/services/settings_service.dart';
import 'package:yamata_launcher/ui/pages/settings/console_sources/console_sources_page.dart';
import 'package:yamata_launcher/ui/pages/settings/download_sources/download_sources_page.dart';
import 'package:yamata_launcher/ui/pages/settings/emulator_settings/emulator_settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// App info
  String _appVersion = '---';

  /// Settings state
  String _downloadPath = '';
  bool _prefixConsoleSlug = false;
  bool _enableNotifications = false;
  bool _enableImageCaching = false;
  bool _extractRomsAfterDownload = false;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  Future<void> _loadInitialValues() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _appVersion = packageInfo.version;
      _downloadPath = FileSystemService.downloadsPath;
    });

    _prefixConsoleSlug =
        await SettingsService().get<bool>(SettingsKeys.PREFIX_CONSOLE_SLUG);
    _enableNotifications =
        await SettingsService().get<bool>(SettingsKeys.ENABLE_NOTIFICATIONS);
    _enableImageCaching =
        await SettingsService().get<bool>(SettingsKeys.ENABLE_IMAGE_CACHING);
    _extractRomsAfterDownload =
        await SettingsService().get<bool>(SettingsKeys.ENABLE_EXTRACTION);

    setState(() {});
  }

  Future<void> _setSetting<T>(SettingsKeys key, T value) async {
    await SettingsService().set<T>(key, value);

    setState(() {
      switch (key) {
        case SettingsKeys.DOWNLOAD_PATH:
          _downloadPath = value as String;
          break;
        case SettingsKeys.PREFIX_CONSOLE_SLUG:
          _prefixConsoleSlug = value as bool;
          break;
        case SettingsKeys.ENABLE_NOTIFICATIONS:
          _enableNotifications = value as bool;
          break;
        case SettingsKeys.ENABLE_IMAGE_CACHING:
          _enableImageCaching = value as bool;
          break;
        case SettingsKeys.ENABLE_EXTRACTION:
          _extractRomsAfterDownload = value as bool;
          break;
        default:
          break;
      }
    });

    if (key == SettingsKeys.DOWNLOAD_PATH) {
      await FileSystemService.setupDownloadsPath();
    }
  }

  Future<void> _pickDownloadPath() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) return;

    final testFile = File('$selectedDirectory/test');

    try {
      await testFile.writeAsString('test');
      await testFile.readAsString();
      await testFile.delete();

      await _setSetting<String>(
        SettingsKeys.DOWNLOAD_PATH,
        selectedDirectory,
      );
    } catch (_) {
      AlertsService.showErrorSnackbar(
          'Cannot write/read in the selected directory');
    }
  }

  Future<void> _updateEmulatorIntents() async {
    var loadingDialog = AlertsService.showLoadingAlert(
      context,
      'Updating emulator intents...',
      "Please wait",
    );
    final success =
        await EmulatorIntentsRepository().updateEmulatorIntentsFile();
    loadingDialog.close();
    if (success) {
      AlertsService.showSnackbar('Emulator intents updated successfully');
    } else {
      AlertsService.showErrorSnackbar(
        'Could not update the emulator intents',
      );
    }
  }

  Future<void> _clearCache() async {
    final deleted = await FileSystemService.deleteCachePath();

    if (deleted) {
      AlertsService.showSnackbar('Cache cleared successfully');
    } else {
      AlertsService.showErrorSnackbar(
        'Could not clear the cache',
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      AlertsService.showErrorSnackbar(
        'Could not launch the url',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sources section
            const _SectionHeader(title: 'Sources'),
            _NavigationTile(
              icon: Icons.download_sharp,
              title: 'Download Sources',
              subtitle: 'Manage your download sources',
              onTap: () => context.push("/settings/download-sources"),
            ),
            _NavigationTile(
              icon: Icons.gamepad,
              title: 'Console Sources',
              subtitle: 'Manage your console sources',
              onTap: () => context.push("/settings/console-sources"),
            ),
            const _SectionHeader(title: 'Notifications'),
            _SwitchTile(
              icon: Icons.notifications,
              title: 'Show notifications',
              subtitle:
                  'Enable or disable notifications for downloads and other events',
              value: _enableNotifications,
              onChanged: (v) =>
                  _setSetting(SettingsKeys.ENABLE_NOTIFICATIONS, v),
            ),
            // Path section
            const _SectionHeader(title: 'Paths'),
            ListTile(
              leading: const Icon(Icons.folder),
              trailing: const Icon(Icons.edit),
              title: const Text('Download path'),
              subtitle: Opacity(opacity: 0.7, child: Text(_downloadPath)),
              onTap: _pickDownloadPath,
            ),
            _SwitchTile(
              icon: Icons.drive_file_move,
              title: 'Add console name folder',
              subtitle:
                  "Put your roms in folders named after consoles e.g. 'nds/rom'",
              value: _prefixConsoleSlug,
              onChanged: (v) =>
                  _setSetting(SettingsKeys.PREFIX_CONSOLE_SLUG, v),
            ),
            // Downloads section
            const _SectionHeader(title: 'Downloads'),
            _SwitchTile(
              icon: Icons.drive_file_move,
              title: 'Extract roms after download',
              subtitle:
                  "If the downloaded file is compressed, it will be extracted automatically",
              value: _extractRomsAfterDownload,
              onChanged: (v) => _setSetting(SettingsKeys.ENABLE_EXTRACTION, v),
            ),
            // Roms & Emulators section
            const _SectionHeader(title: 'Roms & Emulators'),
            _NavigationTile(
              icon: Icons.gamepad,
              title: 'Emulator settings',
              subtitle: 'Manage your emulators for each console',
              onTap: () => context.push("/settings/emulator-settings"),
            ),
            if (Platform.isAndroid)
              ListTile(
                leading: const Icon(Icons.system_update_alt),
                title: const Text('Update Emulator Intents'),
                subtitle: Opacity(
                    opacity: 0.7,
                    child: const Text(
                        'The emulator intents are used to launch emulators on Android devices. Updating them may fix issues with launching emulators.')),
                onTap: _updateEmulatorIntents,
              ),
            const _SectionHeader(title: 'Cache Management'),
            _SwitchTile(
              icon: Icons.image,
              title: 'Enable image caching',
              subtitle:
                  'Download rom portraits for a better offline experience',
              value: _enableImageCaching,
              onChanged: (v) =>
                  _setSetting(SettingsKeys.ENABLE_IMAGE_CACHING, v),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Clear app cache'),
              subtitle: Opacity(
                  opacity: 0.7, child: const Text('Delete all cached files')),
              onTap: _clearCache,
            ),
            const _SectionHeader(title: 'About'),
            _NavigationTile(
              title: 'Github Repository',
              subtitle: 'Know more about the project or contribute',
              trailing: Icons.open_in_new,
              onTap: () => _launchUrl(
                'https://github.com/Gr3gorywolf/Yamata-launcher',
              ),
            ),
            _NavigationTile(
              title: 'App Developed by Gr3gorywolf',
              subtitle: 'Check out my website',
              trailing: Icons.open_in_new,
              onTap: () => _launchUrl('https://gregoryc.dev'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'App version: $_appVersion',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData? icon;
  final IconData? trailing;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavigationTile({
    this.icon,
    this.trailing = Icons.chevron_right,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      trailing: Icon(trailing),
      title: Text(title),
      subtitle: Opacity(opacity: 0.7, child: Text(subtitle)),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
      title: Text(title),
      subtitle: Opacity(opacity: 0.7, child: Text(subtitle)),
    );
  }
}
